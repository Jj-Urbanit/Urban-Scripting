# This PowerShell script is designed to demonstrate how to run a query
# against a database and dump to a csv
#
# Usage:  Save this file as C:\sandbox\powershell\databaseQuery.ps1
# Start Powershell (Win-R, powershell)
# Execute the script (C:\sandbox\powershell\databaseQuery.ps1)

#
# If the above fails due to
# "cannot be loaded because the execution of scripts is disabled on this system"
# run this command within Powershell
# Set-ExecutionPolicy RemoteSigned
# See also http://technet.microsoft.com/en-us/library/ee176949.aspx


# http://www.vistax64.com/powershell/190352-executing-sql-queries-powershell.html
$logpath = "D:\CW-Export-logs\Export-Agreements.log"
$server = "localhost"
$database = "cwwebapp_themissinglink"
$query = "SELECT AGR_Type_Desc FROM dbo.AGR_Type where AGR_Inactive_Flag like '0'
ORDER BY AGR_Type_Desc ASC"

# powershell raw/verbatim strings are ugly
# Update this with the actual path where you want data dumped
$extractFile = @"
D:\CW-Export\cw-agreements.csv
"@

# If you have to use users and passwords, my condolences
$connectionTemplate = "Data Source={0};Integrated Security=SSPI;Initial Catalog={1};"
$connectionString = [string]::Format($connectionTemplate, $server, $database)
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$command = New-Object System.Data.SqlClient.SqlCommand
$command.CommandText = $query
$command.Connection = $connection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $command
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$connection.Close()

# dump the data to a csv
# http://technet.microsoft.com/en-us/library/ee176825.aspx
$DataSet.Tables[0] | Export-Csv $extractFile
if
(!(Test-Path $extractFile))
{
    $Time = Get-Date
    "$time - $extractFile FAILED to export" | out-file $logpath -Append
}
else
{ if
 ((Get-Item $extractFile).length -gt 0kb)
 {
    $Time = Get-Date
    "$time - $extractFile SUCCESSFULLY exported" | out-file $logpath -Append
    }
    else
    {$Time = Get-Date
    "$time - $extractFile file at 0KB, FAILED export" | out-file $logpath -Append
}
}