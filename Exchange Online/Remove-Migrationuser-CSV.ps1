#
# Remove_Migrationuser_CSV.ps1
#
# Checks a CSV with mailboxes marked for deletion and removes them from any migration batches
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session

$csv = "C:\temp\DeleteUsers.csv"
$all = Import-Csv -Path $csv
$count = 0
foreach ($mb in $all)
{
    if ($mb.action -eq "Delete")
    {
        #write-host $mb.displayname is to be deleted
        remove-migrationuser -Identity $mb.primarysmtpaddress -Confirm:$false
        $count ++
    }
}
write-host removing $count users from migration batches