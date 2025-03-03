#
# Instructions_for_these_scripts.ps1
#
Pulled from https://blog.kloud.com.au/2017/11/05/a-tool-to-find-mailbox-permission-dependencies/
    The first pre-requisite for Find_MailboxPermissions_Dependencies.ps1 are the four output files from Roman Zarka’s Export-MailboxPermissions.ps1 script (MailboxAccess.csv, MailboxFolderDelegate.csv, MailboxSendAs.csv, MaiboxSendOnBehalf.csv)
    The next pre-requisite is details about the on-premises mailboxes. The on-premises Exchange environment must be queried and the details output into a csv file with the name OnPrem_Mbx_Details.csv. The csv must contain the following information (along the following column headings)“DisplayName, UserPrincipalName, PrimarySmtpAddress, RecipientTypeDetails, Department, Title, Office, State, OrganizationalUnit”
    The last pre-requisite is information about mailboxes that are already in Office 365. Use PowerShell to connect to Exchange Online and then run the following command (where O365_Mbx_Details.csv is the output file)

    Get-Mailbox -ResultSize unlimited | Select DisplayName,UserPrincipalName,EmailAddresses,WindowsEmailAddress,RecipientTypeDetails | Export-Csv -NoTypeInformation -Path O365_Mbx_Details.csv 

    If there are no mailboxes in Office 365, then create a blank file and put the following column headings in it “DisplayName”, “UserPrincipalName”, “EmailAddresses”, “WindowsEmailAddress”, “RecipientTypeDetails”. Save the file as O365_Mbx_Details.csv
    Next, put the above files in the same folder and then update the variable $root_dir in the script with the path to the folder (the path must end with a \ )
    It is assumed that the above files have the following names
        MailboxAccess.csv
        MailboxFolderDelegate.csv
        MailboxSendAs.csv
        MailboxSendOnBehalf.csv
        O365_Mbx_Details.csv
        OnPrem_Mbx_Details.csv
     Now, that all the inputs have been taken care of, run the script.
    The first task the script does is to validate if the input files are present. If any of them are not found, the script outputs an error and terminates.
    Next, the files are read and stored in memory
    Now for the heart of the script. It goes through each of the mailboxes in the OnPrem_Mbx_Details.csv file and finds the following
        all mailboxes that have been given SendOnBehalf permissions to this mailbox
        all mailboxes that this mailbox has been given SendOnBehalf permissions on
        all mailboxes that have been given SendAs permissions to this mailbox
        all mailboxes that this mailbox has been given SendAs permissions on
        all mailboxes that have been given Delegate permissions to this mailbox
        all mailboxes that this mailbox has been given Delegate permissions on
        all mailboxes that have been given Mailbox Access permissions on this mailbox
        all mailboxes that this mailbox has been given Mailbox Access permissions on
        if the mailbox that this mailbox has given the above permissions to or has got permissions on has already been migrated to Office 365
    The results are then output to a csv file (the name of the output file is of the format Find_MailboxPermissions_Dependencies_{timestamp of when script was run}_csv.csv
    The columns in the output file are explained below

Column Name 	Description
PermTo_OtherMbx_Or_FromOtherMbx? 	This is Y if the mailbox has given permissions to or has permissions on other mailboxes. Is N if there are no permission dependencies for this mailbox
PermTo_Or_PermFrom_O365Mbx? 	This is TRUE if the mailbox that this mailbox has given permissions to or has permissions on is  already in Office 365
Migration Readiness 	This is a color code based on the migration readiness of this permission. This will be further explained below
DisplayName 	The display name of the on-premises mailbox for which the permission dependency is being found
UserPrincipalName 	The userprincipalname of the on-premises mailbox for which the permission dependency is being found
PrimarySmtp 	The primarySmtp of the on-premises mailbox  for which the permission dependency is being found
MailboxType 	The mailbox type of the on-premises mailbox  for which the permission dependency is being found
Department 	This is the department the on-premises mailbox belongs to (inherited from Active Directory object)
Title 	This is the title that this on-premises mailbox has (inherited from Active Directory object)
SendOnBehalf_GivenTo 	emailaddress of the mailbox that has been given SendOnBehalf permissions to this on-premises mailbox
SendOnBehalf_GivenOn 	emailaddress of the mailbox that this on-premises mailbox has been given SendOnBehalf permissions to
SendAs_GivenTo 	emailaddress of the mailbox that has been given SendAs permissions to this on-premises mailbox
SendAs_GivenOn 	emailaddress of the mailbox that this on-premises mailbox has been given SendAs permissions on
MailboxFolderDelegate_GivenTo 	emailaddress of the mailbox that has been given Delegate access to this on-premises mailbox
MailboxFolderDelegate_GivenTo_FolderLocation 	the folders of the on-premises mailbox that the delegate access has been given to
MailboxFolderDelegate_GivenTo_DelegateAccess 	the type of delegate access that has been given on this on-premises mailbox
MailboxFolderDelegate_GivenOn 	email address of the mailbox that this on-premises mailbox has been given Delegate Access to
MailboxFolderDelegate_GivenOn_FolderLocation 	the folders that this on-premises mailbox has been given delegate access to
MailboxFolderDelegate_GivenOn_DelegateAccess 	the type of delegate access that this on-premises mailbox has been given
MailboxAccess_GivenTo 	emailaddress of the mailbox that has been given Mailbox Access to this on-premises mailbox
MailboxAccess_GivenTo_DelegateAccess 	the type of Mailbox Access that has been given on this on-premises mailbox
MailboxAccess_GivenOn 	emailaddress of the mailbox that this mailbox has been given Mailbox Access to
MailboxAccess_GivenOn_DelegateAccess 	the type of Mailbox Access that this on-premises mailbox has been given
OrganizationalUnit 	the Organizational Unit for the on-premises mailbox

The color codes in the column Migration Readiness correspond to the following

    LightBlue – this on-premises mailbox has no permission dependencies and can be migrated
    DarkGreen  – this on-premises mailbox has got a Mailbox Access permission dependency to another mailbox. It can be migrated while the other mailbox can remain on-premises, without experiencing any issues as Mailbox Access permissions are supported cross-premises.
    LightGreen – this on-premises mailbox can be migrated without issues as the permission dependency is on a mailbox that is already in Office 365
    Orange – this on-premises mailbox has SendAs permissions given to/or on another on-premises mailbox. If both mailboxes are not migrated at the same time, the SendAs capability will be broken. Lately, it has been noticed that this capability can be restored by re-applying the SendAs permissions to both the migrated and on-premises mailbox post migration
    Pink – the on-premises mailbox has FolderDelegate given to/or on another on-premises mailbox. If both mailboxes are not migrated at the same time, the FolderDelegate capability will be broken. A possible workaround is to replace the FolderDelegate permission with Full Mailbox access as this works cross-premises, however there are privacy concerns around this workaround as this will enable the delegate to see all the contents of the mailbox instead of just the folders they had been given access on.
    Red – the on-premises mailbox has SendOnBehalf permissions given to/or on another on-premises mailbox. If both mailboxes are not migrated at the same time, the SendOnBehalf capability will be broken. A possible workaround could be to replace SendOnBehalf with SendAs however the possible implications of this change must be investigated

Yay, the output has now been generated. All we need to do now is to make it look pretty in Excel ??

Carry out the following steps

    Import the output csv file into Excel, using the semi-colon “;” as the delimiter (I couldn’t use commas as the delimiter as sometimes department,titles etc fields use them and this causes issues with the output file)
    Create Conditional Formatting rules for the column Migration Readiness so that the fill color of this cell corresponds to the word in this column (for instance, if the word is LightBlue then create a rule to apply a light blue fill to the cell)
