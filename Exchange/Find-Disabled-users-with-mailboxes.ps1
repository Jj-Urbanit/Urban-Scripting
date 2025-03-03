#
# Find_Disabled_users_with_mailboxes.ps1
#
#used to find disabled users who also have a mailbox. Could be shared mailbox or otherwise
import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$mbxs = get-mailbox
$sharedcount = 0
$regusercount = 0
foreach ($mbx in $mbxs)
{
    #write-host mailbox is $mbx.DisplayName
    $curuser = Get-ADuser -Identity $mbx.samaccountname
    #write-host current user is $curuser.Name
    if ($curuser.enabled -eq $false -and $mbx.RecipientTypeDetails -ne "UserMailbox")
    {
        #write-host $mbx.DisplayName is a disabled user with a mailbox
        write-host $curuser.name has $mbx.RecipientTypeDetails type mailbox
        $sharedcount ++
    }
    if ($curuser.enabled -eq $false -and $mbx.RecipientTypeDetails -eq "UserMailbox")
    {
        write-host $curuser.name has $mbx.RecipientTypeDetails type mailbox
        $regusercount ++
    }        
}
write-host found $sharedcount users with sharedmailboxes
write-host found $regusercount users with regular mailboxes