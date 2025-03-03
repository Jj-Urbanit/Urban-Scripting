#When connected to Exchange Online
#WARNING: This will PERMANENETLY delete the user account from Office 365. No recovery. 

connect-msolservice

remove-msoluser -userprincipalname UID@UPN.com
remove-msoluser -userprincipalname UID@UPN.com -RemoveFromRecyclebin