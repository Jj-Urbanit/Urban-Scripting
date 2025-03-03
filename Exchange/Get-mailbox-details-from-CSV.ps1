#
# Get_mailbox_details_from_CSV.ps1
#
#Used to read a CSV of users and pull further attributes from Exchange/AD and write to another CSV
import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$mbxs = get-mailbox
$sharedcount = 0
$regusercount = 0
$sharedarray = @()
$disabledarray =@()
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
        $disableduser = $mbx | select displayname,primarysmtpaddress,RecipientTypeDetails
        $sharedarray += $disableduser
    }
    if ($curuser.enabled -eq $false -and $mbx.RecipientTypeDetails -eq "UserMailbox")
    {
        write-host $curuser.name has $mbx.RecipientTypeDetails type mailbox
        $regusercount ++
        $disableduser = $mbx | select displayname,primarysmtpaddress,RecipientTypeDetails
        $disabledarray += $disableduser
    }        
}
write-host found $sharedcount users with sharedmailboxes
write-host found $regusercount users with regular mailboxes
$sharedarray | Export-Csv -Path c:\temp\shared.csv -NoTypeInformation
$disabledarray | Export-Csv -Path c:\temp\disabled.csv -NoTypeInformation