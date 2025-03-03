# Modify_users_by_CSV.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
#Connect-msolservice -credential $UserCredential

$path = "c:\temp"
$csvfile = $path + "\hg-fullaccess.csv"
$logs = $path + "\hg-fullaccess.log"

Import-Csv -path $csvfile | `

#ForEach-Object {
#	Add-mailboxPermission -identity $_.identity -AccessRights fullaccess -user $_.user
#}
get-mailbox | Add-MailboxPermission -AccessRights fullaccess -User amy.macgregor -AutoMapping:$False
get-mailbox | Add-MailboxPermission -AccessRights fullaccess -User administrator -AutoMapping:$False

#get-pssession | Remove-PSSession
# below for helpdesk accesss everyone NOT directors. turn off automap
get-mailbox | where {($_.name -ne "philip.macgregor") -AND ($_.name -ne "bill.mason") -AND ($_.name -ne "geoff.macgregor") -AND ($_.name -ne "peter.macgregor") -AND ($_.name -ne "bvpayroll") -AND ($_.name -ne "amy.macgregor")} |ForEach-Object {
	get-mailbox | Add-MailboxPermission -AccessRights fullaccess -User amy.macgregor -AutoMapping:$False
}