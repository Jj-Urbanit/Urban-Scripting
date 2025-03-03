param(
[int]$waitseconds = 60
)
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$batchnames = Get-MailboxExportRequest | select batchname -ExpandProperty batchname | Get-Unique -asstring | where {$_.batchname -ne ""}
$maxConcurrentExports = 8
while($true)
{
    foreach ($batchname in $batchnames)
    
     {
			Write-host "============================================"
			Write-host "Waiting for the exports to complete"
			$unfinished = (get-mailboxexportrequest -batchname $batchname | where {$_.status -ne "completed"}).count
			$finished = (get-mailboxexportrequest -batchname $batchname | where {$_.status -eq "completed"}).count
			$inprogress = (get-mailboxexportrequest -batchname $batchname | where {$_.status -eq "inprogress"}).count
			Write-host "============================================"
			Write-Host " "
			#Write-Host  -ForegroundColor Green "Finished mailbox Exports for $batchname = $finished"
			#Write-Host " "
			Write-Host  -ForegroundColor Red "Still waiting on $unfinished exports in $batchname"
			Write-Host " "
			Write-Host  -ForegroundColor yellow "$inprogress exports currently running for $batchname"
            write-host $batchname
            if ($inprogress -lt $maxConcurrentExports){
                Get-MailboxExportRequest -Status Completed | Remove-MailboxExportRequest -Confirm:$false
				get-mailboxexportrequest -batchname $batchname -Resultsize $maxConcurrentExports | resume-mailboxexportrequest
            }
		}
    sleep $waitseconds
    clear
    get-date
    }
    