#
# EOL_Stop_Running_Migrationbatches.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
$batches = Get-MigrationBatch -Status syncing
foreach ($batch in $batches)
{
    write-host "======================================"
    Stop-MigrationBatch -Identity ($batch.Identity).id -Confirm:$false
    write-host ($batch.Identity).name stopping
    do{
        sleep 5
        $status = Get-MigrationBatch ($batch.Identity).id
        write-host ($batch.identity).name is still stopping
    } until (($status.status).value -eq "stopped")
    write-host ($batch.identity).name has stopped
    write-host "+++++++++++++++++++++++++++++++++++++++"
}