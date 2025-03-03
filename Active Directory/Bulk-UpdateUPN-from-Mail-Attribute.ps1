#
# Bulk_UpdateUPN_from_Mail_Attribute.ps1
#
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
Import-Module ActiveDirectory
$mbxs = get-mailbox -resultsize unlimited
$count=0
foreach ($mailbox in $mbxs)
{
    $mbxsmtp = $mailbox.primarysmtpaddress
    if ($mailbox.userprincipalname -ne $mailbox.primarysmtpaddress)
    {
		write-host ==============================================================================
		write-host ==============================================================================
		$user = get-aduser -Identity $mailbox.DistinguishedName
		write-host Primary SMTP Address is $mailbox.WindowsEmailAddress
		write-host "Setting "$mailbox.DisplayName"'s UPN ("$mailbox.userprincipalname") to match SMTP address "$mailbox.WindowsEmailAddress
		Set-ADUser -Identity $mailbox.DistinguishedName -UserPrincipalName $mailbox.WindowsEmailAddress
		start-sleep -Milliseconds 300
		$newupn = get-aduser -Identity $mailbox.DistinguishedName
		write-host $mailbox.DisplayName"'s new UPN is "$newupn.userprincipalname
		$count ++
	}
}
Write-Host updated $count mailboxes