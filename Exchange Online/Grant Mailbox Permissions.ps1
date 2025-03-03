Get-Mailbox | ForEach-Object {Set-MailboxFolderPermission $_”:\calendar” -User Default -AccessRights Reviewer}

#This script will grant all users reviewer permission for all mailboxes in an organisation.