#gives access rights to a calendar in a mailbox. 
#For access levels and info see here: https://technet.microsoft.com/en-us/library/ff522363(v=exchg.150).aspx
set-mailboxfolderpermission -identity username@themissinglink.com.au:\calendar -User Default -Accessrights


