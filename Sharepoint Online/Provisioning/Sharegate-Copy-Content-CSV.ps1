#
# Sharegate_Copy_Content_CSV.ps1
#
# Used to copy content using Sharegate, specifying the source and destinations by CSV
Import-Module Sharegate
$copysettings = New-CopySettings -OnContentItemExists IncrementalUpdate
$date=get-date -Format yyyy-MM-dd
$password = read-host -AsSecureString -Prompt "Enter password for admin@implementedportfolios.onmicrosoft.com"
$logfile = "c:\temp\content-copy.xlsx"
$csvpath = Read-Host -Prompt "Enter the path to the CSV holding migration paths"
$csv = Import-Csv $csvpath
foreach ($folder in $csv)
{
    $name = $folder.Name
    $logfile = "c:\temp\"+$date+'-'+$name+".xlsx"
    $dstSite = Connect-Site -Url $folder.host -UserName "admin@implementedportfolios.onmicrosoft.com" -Password $password
    $dstList = Get-List -Site $dstSite -name $folder.name
    $result = Import-Document -DestinationList $dstList -SourceFolder $folder.fullname -CopySettings $copysettings
    #$result | Out-File -Filepath $logfile -Append
    Export-Report -CopyResult $result -Path $logfile
}