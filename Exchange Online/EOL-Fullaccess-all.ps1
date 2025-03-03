#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session -AllowClobber
$mailboxes = get-msoluser | select -expandproperty userprincipalname
foreach ($mailbox in $mailboxes)
{write-host $mailbox
add-MailboxPermission -Identity $mailbox -User itadmin@wem.com.au -AutoMapping:$False -AccessRights fullaccess -InheritanceType all
add-MailboxPermission -Identity $mailbox -User gragg@wem.com.au -AutoMapping:$False -AccessRights fullaccess -InheritanceType all
}