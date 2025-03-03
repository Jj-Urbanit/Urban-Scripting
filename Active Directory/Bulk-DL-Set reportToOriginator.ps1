#
# DL_reportToOriginator.ps1
#
# grabs dist groups from a CSV and sets the reportToOriginator flag on all
$csv = import-csv -path "c:\dls.csv"
foreach ($dl in $csv)
{
    Get-ADGroup -Identity $dl.name | Set-ADGroup -Add @{reportToOriginator=$True}
}