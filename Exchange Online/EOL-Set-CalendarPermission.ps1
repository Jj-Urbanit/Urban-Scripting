#
# EOL_Set_CalendarPermission.ps1
#
$permissionlevel = Reviewer
Get-Mailbox -ResultSize unlimited -Filter {RecipientTypeDetails -eq 'UserMailbox'} | ForEach-Object {
	Set-MailboxFolderPermission $_":\Calendar" -User default -AccessRights $permissionlevel
	Write-Host $_.Name has had the set default calendar permissions set to $permissionlevel
}