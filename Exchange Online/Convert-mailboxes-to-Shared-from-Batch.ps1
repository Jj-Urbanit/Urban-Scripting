#
# Convert-mailboxes-to-Shared-from-Batch.ps1
#
#outputs all completed batches and converts all mailboxes to shared
#$credentials = get-credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
#Import-PSSession $Session
#connect-msolservice -credential $credentials
Get-MigrationBatch -status Completed
$batch = read-host -Prompt "enter batch to license"
$count = 0
$users = get-migrationuser -batchid $batch
Foreach ($user in $users)
{
    $mbx = get-mailbox -Identity $user.Identity
    if ($mbx.recipienttypedetails -eq "Usermailbox")
    {
        write-host =============================================================
        write-host Converting $user.MailboxEmailAddress
        set-mailbox -Identity $user.identity -type Shared
        $count ++
    }
    else
    {
        write-host $user.Identity is already shared
    }
}
$count