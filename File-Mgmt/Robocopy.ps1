#
# Robocopy.ps1
#
$csv = "C:\temp\folders.csv"
$imported = Import-Csv -path $csv
foreach ($folder in $imported)
{
    $logfile = $folder.BaseName+".log"
    robocopy $folder.source $folder.dest *.* /e /b /copyall /r:6 /w:5 /MT:64 /xd DfsrPrivate /tee /v /log+:$logfile
}