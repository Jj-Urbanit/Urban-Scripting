#
# Disable_Mailbox_from_CSV.ps1
#
# Reads CSV and disables all mailboxes marked for deletion
import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$csv = "C:\temp\DeleteUsers.csv"
$all = Import-Csv -Path $csv
$count = 0
foreach ($mb in $all)
{
    if ($mb.action -eq "Delete")
    {
        #write-host $mb.displayname is to be deleted
        disable-mailbox -Identity $mb.primarysmtpaddress -Confirm:$false
        $count ++
    }
}
write-host deleting $count mailboxes