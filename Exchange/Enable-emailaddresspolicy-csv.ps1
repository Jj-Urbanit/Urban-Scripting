#
# Enable_emailaddresspolicy_csv.ps1
#
#CSV provided with mailboxes marked by column called "action". Setting change to enable email address policy and bypass others
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$csv = import-csv -path "c:\temp\ignite.csv"
foreach ($mb in $csv)
{
    if ($mb.action -eq "change")
    {
        write-host $mb.displayname need to be changed
        set-remotemailbox $mb.emailaddress -emailaddresspolicyenabled:$true
    }
    else
    {
        write-host $mb.DisplayName "isn't being changed"
    }
}