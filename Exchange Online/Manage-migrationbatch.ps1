#
# Manage_migrationbatch.ps1
#
Set-ExecutionPolicy unrestricted

#Define variables
$notificationemail = "o365migration@gtlaw.com.au"
$baditemcount = 1000

#Define functions
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function Show-Menu
{
     cls
     Write-Host "================ Migration Menu ================"
     Write-Host ""
     Write-Host "Press '1' for 'Create a new migration batch'"
     Write-Host "Press '2' for 'Delete an existing migration batch'"
     Write-Host "Press '3' for 'Start a stopped migration batch'"
	 Write-Host "Press '4' for 'Stop a running migration batch'"
	 Write-Host "Press '5' for 'Complete a synced migration batch'"
	 Write-Host "Press '6' for 'List all migration batches'"
	 Write-Host "Press '7' for 'List all mailbox move requests'"
	 Write-Host "Press '8' for 'List all failures'"
     Write-Host "Press 'Q' to quit."
}

function Connect-ExchangeOnline
{
	#Connect to Exchange Online/O365
	$UserCredential = Get-Credential
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
	Import-PSSession $Session
}

function Create-MigrationBatches
{
     cls
     $existingbatches = Get-MigrationBatch
	 Write-Host "Existing Batches: " $existingbatches.Identity
	 $batchname = Read-Host "Please enter the name of the new migration batch"
	 
	 Write-Host "Provide the CSV file for the new migration batch"
	 $inputfile = Get-FileName "C:\temp"
	 $inputdata = get-content $inputfile
	 
	 $void = New-MigrationBatch -Name $batchname -SourceEndpoint "oa.gtlaw.com.au" -TargetDeliveryDomain "gtlawhub.mail.onmicrosoft.com" -CSVData ([System.IO.File]::ReadAllBytes($inputfile)) -AllowIncrementalSyncs $True -BadItemLimit $baditemcount -NotificationEmails $notificationemail
	 Write-Host "New migration batch " $batchname " was created."
	 Sleep 2
}

function List-MigrationBatches
{
     cls
	 Get-MigrationBatch | Select Identity,Status,State,CreationDateTime,BadItemLimit,TotalCount,ActiveCount,StoppedCount,SyncedCount,FinalizedCount,FailedCount,FailedInitialSyncCount,FailedIncrementalSyncCount,CompletedWithWarningCount | Out-Gridview
}

function Start-MigrationBatches
{
     cls	 
	 Write-Host "================ Stopped MigratonBatch Overview ================"
     Write-Host ""
	 $existingbatches = Get-MigrationBatch | Where-Object {$_.Status -like "Stopped"}
	 if ($existingbatches.Count -eq 0) {
		Write-Host "No matching migration batches found!"
		Write-Host ""
	 } else {
	 foreach($batch in $existingbatches){
		Write-Host $batch.Identity " Status:" $batch.Status " State:" $batch.State " Created on:" $batch.CreationDateTime " Mailboxes:" $batch.TotalCount
	 }
		Write-Host ""
		$batchname = Read-Host "Please enter the name of the migration batch"
		Write-Host $batchname
		Start-MigrationBatch -Identity $batchname
	 }
}

function Stop-MigrationBatches
{
     cls
	 Write-Host "================ Started MigratonBatch Overview ================"
     Write-Host ""
	 $existingbatches = Get-MigrationBatch | Where-Object {$_.Status -like "Syncing"}
	 if ($existingbatches.Count -eq 0) {
		Write-Host "No matching migration batches found!"
		Write-Host ""
	 } else {
	 foreach($batch in $existingbatches){
		Write-Host $batch.Identity " Status:" $batch.Status " State:" $batch.State " Created on:" $batch.CreationDateTime " Mailboxes:" $batch.TotalCount
	 }
		Write-Host ""
		$batchname = Read-Host "Please enter the name of the migration batch"
		Stop-MigrationBatch -Identity $batchname
	}
}

function Delete-MigrationBatches
{
     cls
	 Write-Host "================ All MigratonBatch Overview ================"
     Write-Host ""
	 $existingbatches = Get-MigrationBatch 
	 if ($existingbatches.Count -eq 0) {
		Write-Host "No matching migration batches found!"
		Write-Host ""
	 } else {
	 foreach($batch in $existingbatches){
		Write-Host $batch.Identity " Status:" $batch.Status " State:" $batch.State " Created on:" $batch.CreationDateTime " Mailboxes:" $batch.TotalCount
	 }
	 Write-Host ""
	 $batchname = Read-Host "Please enter the name of the migration batch"
	 Remove-MigrationBatch -Identity $batchname
	 }
}

function Complete-MigrationBatches
{
     cls
	 Write-Host "================ Synced MigratonBatch Overview ================"
     Write-Host ""
	 $existingbatches = Get-MigrationBatch | Where-Object {$_.Status -like "Synced"}
	 if ($existingbatches.Count -eq 0) {
		Write-Host "No matching migration batches found!"
		Write-Host ""
	 } else {
	 foreach($batch in $existingbatches){
		Write-Host $batch.Identity " Status:" $batch.Status " State:" $batch.State " Created on:" $batch.CreationDateTime " Mailboxes:" $batch.TotalCount
	 }
	 Write-Host ""
	 $batchname = Read-Host "Please enter the name of the migration batch"
	 Complete-MigrationBatch -Identity $batchname
	 }
}

function List-MoveRequests
{
     cls
	 Get-MoveRequest | Get-MoveRequestStatistics | Select DisplayName,BatchName,Status,StatusDetail,SyncStage,TotalMailboxSize,BytesTransferred,TotalMailboxItemCount,ItemsTransferred,BytesTransferredPerMinute | Out-Gridview
}

function Get-MigrationBatchFailures
{
     cls
	 $report = Get-MigrationBatch -IncludeReport
	 $report.Report.Failures | Select Timestamp,FailureType,Message |  Out-GridView
}

#Start with connecting to Exchange Online
cls
Connect-ExchangeOnline

#Run menu loop
do
{
	 Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
				Create-MigrationBatches
           } '2' {
                cls
                Delete-MigrationBatches
           } '3' {
                cls
                Start-MigrationBatches
           } '4' {
                cls
                Stop-MigrationBatches
           } '5' {
                cls
                Complete-MigrationBatches
           } '6' {
                cls
                List-MigrationBatches
           } '7' {
                cls
                List-MoveRequests
           } '8' {
                cls
                Get-MigrationBatchFailures
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')