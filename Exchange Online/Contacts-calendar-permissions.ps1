#
# Contacts_calendar_permissions.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
$meetingrooms = Get-Mailbox -Filter {Recipienttypedetails -eq 'Roommailbox'}
$permissionlevel = "Reviewer"
foreach ($room in $meetingrooms)
{
    Set-CalendarProcessing -Identity $room.name -ProcessExternalMeetingMessages $true
    #$contacts = Get-MailContact
    #ForEach ($contact in $contacts)
    #{
	    #Set-MailboxFolderPermission -Identity $room":\Calendar" -User $contact.name -AccessRights $permissionlevel
	    #Write-Host $room.Name has had the set default calendar permissions set to $permissionlevel for user $contact.Name
	#}
}
