#
# Delicense_Shared_Room_Mailboxes.ps1
#
#Script to search for mailboxes of type RoomMailbox and RoomMailbox and remove license if present
$credentials = get-credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession $Session
connect-msolservice -credential $credentials
$mailboxes = get-mailbox
foreach ($mailbox in $mailboxes)
{
	$userdet = get-msoluser -UserPrincipalName $mailbox.UserPrincipalName
    if ($mailbox.RecipientTypeDetails -ne "UserMailbox" -AND $userdet.islicensed -eq $true)
	{
		write-host $mailbox.userprincipalname "($Mailbox) has a license and doesn't need it, removing all license types"
		$Skus = $userdet.licenses.AccountSkuId
		Set-MsolUserLicense -UserPrincipalName $userdet.UserPrincipalName -RemoveLicenses $Skus
	}
        
}