#
# new_migrationbatch_by_csv.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session

$folder = "C:\temp\"
$csvname = Read-Host -Prompt "Enter the CSV filename excluding extention"
$endpointname = read-host -Prompt "Enter the name of the migration endpoint"
$csvfile = $folder+$csvname+".csv"
$FileExists = Test-Path $csvfile
$endpointnames = Get-MigrationEndpoint
if (!(($endpointnames|Select-Object -ExpandProperty Identity) -contains $endpointname))
{
    write-host "migration endpoint name is incorrect. Please check and try again"
    exit
}

if ($FileExists -eq $True) 
{
    write-host "CSV file exists"
    #write-host $csvfile
    New-MigrationBatch -CSVData ([System.IO.File]::ReadAllBytes( $csvfile)) -name $csvname -BadItemLimit 1000 -LargeItemLimit 1000 -AllowIncrementalSyncs $true -SourceEndpoint $endpointname `
    -TargetDeliveryDomain ppg4.mail.onmicrosoft.com -AllowUnknownColumnsInCsv $true -NotificationEmails cturner@themissinglink.com.au -AutoStart
}
else
{
    write-host "CSV filename incorrect. Try again"
    exit
}