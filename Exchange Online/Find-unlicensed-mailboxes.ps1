#
# Find_unlicensed_mailboxes.ps1
#
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

$mailboxes = get-mailbox
foreach ($mailbox in $mailboxes)
{
	$user = get-msoluser -UserPrincipalName $mailbox.userprincipalname
    if ($user.islicensed -eq $False -and $mailbox.RecipientTypeDetails -eq "UserMailbox")
    {
        write-host $user.userprincipalname needs a license
    }
}