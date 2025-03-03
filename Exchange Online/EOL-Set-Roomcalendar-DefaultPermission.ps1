#
# EOL_Set_Roomcalendar_DefaultPermission.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
#set level of permissions required. For description of permission roles and types see this link.
#https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/set-mailboxfolderpermission?view=exchange-ps
$permissionlevel = "PublishingAuthor"
$cals = Get-Mailbox -ResultSize unlimited -Filter {RecipientTypeDetails -eq 'Roommailbox'}
ForEach ($cal in $cals)
{
	Set-MailboxFolderPermission $cal":\Calendar" -User default -AccessRights $permissionlevel
	$newperm = Get-MailboxFolderPermission $cal":\Calendar" | where {$_.User -match "Default"}
    Write-Host $cal.Name now has the default calendar permissions set to $newperm.AccessRights
}