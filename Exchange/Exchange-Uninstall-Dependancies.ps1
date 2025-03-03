#
# Exchange_Uninstall_Dependancies.ps1
#
#Remove default Public folders
Get-PublicFolder "\" -Recurse -ResultSize:Unlimited | 
Remove-PublicFolder -Recurse -ErrorAction:SilentlyContinue

#Remove system Public folders
Get-PublicFolder "\Non_Ipm_Subtree" -Recurse -ResultSize:Unlimited | 
Remove-PublicFolder -Recurse -ErrorAction:SilentlyContinue

#Remove Offline Address Book
Get-OfflineAddressBook | Remove-OfflineAddressBook

#Remove send connectors
Get-SendConnector | Remove-SendConnector

#Remove Public Folder database (SBS 2011/Exchange 2010 Only)
Get-PublicFolderDatabase | Remove-PublicFolderDatabase

#Remove arbitration mailboxes (SBS 2011/Exchange 2010 Only)
Get-Mailbox -Arbitration | Disable-Mailbox -Arbitration -DisableLastArbitrationMailboxAllowed

#Remove mailboxes
Get-Mailbox | Disable-Mailbox