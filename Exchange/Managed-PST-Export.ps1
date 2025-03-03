# - no need to run from Exchange PowerShell. Needed library is loaded at runtime
$smtpServer = "192.168.0.78"
$starttime = get-date -displayhint time
###############
# Settings    #
###############

# Pick ONE of the list below. If you choose both, it will use $Server. If list, the two columns required are SamAccountName and PrimarySMTPAddress
#$Server
#$Database
$list = "\\syd-ex-01\f$\list.csv"

# Share to export mailboxes to. Needs R/W by Exchange Trusted Subsystem
# Must be a UNC path as this is run by the CAS MRS service.
$ExportShare = "\\syd-ex-01\archives$\"
if (!(test-path -path $ExportShare -pathtype container))
{
 mkdir $ExportShare
}

# After each run a report of the exports can be dropped into the directory specified below. (The user that runs this script needs access to this share)
# Must be a UNC path or the full path of a local directory.
$ReportShare = "\\syd-ex-01\reports$\"
if (!(test-path -path $ReportShare -pathtype container))
{
 mkdir $ReportShare
}

# Shall we remove the PST file, if it exists beforehand? (The user that runs this script needs access to the $ExportShare share)
# Valid values: $true or $false
$RemovePSTBeforeExport = $true

# Do we want to include Archive Mailboxes
$IncludeArchive = $true

# Do we want to exclude dumpster
# currently not working as intended. workarround in place
$ExcludeDumpster = $true

# How many concurrent exports do we want?
# This must be an even number (2, 4, 6, 50, 100, 200, 1000 etc)
$maxConcurrentExports = 8

###############
# Code        #
###############

# function created by Jeff Wouters (www.jeffwouters.nl)
function Check-LoadedModule
{
  Param( [parameter(Mandatory = $true)][alias("Module")][string]$ModuleName)
  $LoadedModules = Get-Module | Select Name
  if (!$LoadedModules -like "*$ModuleName*") {Import-Module -Name $ModuleName}
}

# Deviation from Jeff Wouters function but for PSAddins
function Check-LoadedSnapIN
{
  Param( [parameter(Mandatory = $true)][alias("SnapIN")][string]$SnapINName)
 if ( (Get-PSSnapin -Name $SnapINName -ErrorAction SilentlyContinue) -eq $null )
 {
     Add-PsSnapin $SnapINName
 }
}

# If Archives are included we get 2 exports at a time. so we need to divide the maximum by 2
if ($includeArchive){
 $maxConcurrentExports = $maxConcurrentExports / 2
}

# load the Exchange powershell snapin if not loaded
Check-LoadedSnapIN Microsoft.Exchange.Management.PowerShell.SnapIn

# this function will create the MailboxExportRequests.
function exportMailbox ([String]$CurrentUser) {
     if ($RemovePSTBeforeExport -eq $true -and (Get-Item "$($ExportShare)\$($CurrentUser).PST" -ErrorAction SilentlyContinue))
     { 
         Remove-Item "$($ExportShare)\$CurrentUser.PST" -Confirm:$false -ErrorAction SilentlyContinue
         Remove-Item "$($ExportShare)\$CurrentUser-Archive.PST" -Confirm:$false -ErrorAction SilentlyContinue
     }
     if ($ExcludeDumpster){ # workarround if else. Would rather place this inline in the vode.
      New-MailboxExportRequest -BatchName $BatchName -Mailbox $CurrentUser -FilePath "$($ExportShare)\$CurrentUser.pst" -ExcludeDumpster
      if ($IncludeArchive){
       New-MailboxExportRequest -BatchName $BatchName -Mailbox $CurrentUser -FilePath "$($ExportShare)\$CurrentUser-Archive.pst" -IsArchive -ExcludeDumpster
      }
     } else {
      New-MailboxExportRequest -BatchName $BatchName -Mailbox $CurrentUser -FilePath "$($ExportShare)\$CurrentUser.pst"
      if ($IncludeArchive){
       New-MailboxExportRequest -BatchName $BatchName -Mailbox $CurrentUser -FilePath "$($ExportShare)\$CurrentUser-Archive.pst" -IsArchive
      }
  }     
}

# This function makes the script wait for completion of all exports.
function waitForCompletion {
 while ((Get-MailboxExportRequest -BatchName $BatchName | Where {$_.Status -eq "Queued" -or $_.Status -eq "InProgress"}))
 {
     clear
     Write-Output "Waiting for the exports to complete"
     Get-MailboxExportRequest -BatchName $BatchName | Get-MailboxExportRequestStatistics | Where {$_.Status -eq "Queued" -or $_.Status -eq "InProgress"} | Out-Default | Format-Table
     sleep 60
 }
}

# Make batch name
$date=Get-Date
$BatchName = "Export_$($date.Year)-$($date.Month)-$($date.Day)_$($date.Hour)-$($date.Minute)-$($date.Second)"

if ($ExcludeDumpster){
 $additionalParm = "-ExcludeDumpster $true"
} else {
 $additionalParm = ""
}

# the collection of what to be export
if ($Server)
{
 write-output "Using Server"
    if (!(Get-ExchangeServer $Server -ErrorAction SilentlyContinue))
    {
        throw "Exchange Server $Server not found";
    }
    if (!(Get-MailboxDatabase -Server $Server -ErrorAction SilentlyContinue))
    {
        throw "Exchange Server $Server does not have mailbox databases";
    }
    $Mailboxes = Get-Mailbox -Server $Server -ResultSize Unlimited
} elseif ($Database) {
 write-output "Using database"
    if (!(Get-MailboxDatabase $Database -ErrorAction SilentlyContinue))
    {
        throw "Mailbox database $Database not found"
    }
    $Mailboxes = Get-Mailbox -Database $Database -ResultSize Unlimited
} elseif ($list) {
 write-output "Using list: $list"
 $userlist = Import-CSV $list
} else {
    write-output "None of the above, so exporting all mailboxes.."
    $mailboxes = Get-Mailbox -ResultSize Unlimited
} 

# The Export
if ($list){
 Write-Output "Queuing $($userlist.Count) mailboxes as batch '$($BatchName)'"
 $teller = 0
 # Queue all mailbox export requests
 foreach ($user in $userlist)
 {
     $teller = $teller + 1
     $curuser =  $user.PrimarySmtpAddress
     exportMailbox $curuser
     if ($teller -gt $maxConcurrentExports){
  Write-Output "Waiting for batch to complete"
  # Wait for mailbox export requests to complete
  waitForCompletion 
  $teller = 0
     }
 }  
 # Wait for mailbox export requests to complete
 waitForCompletion
}elseif ((!$Mailboxes) -and (!$Mailboxes.Count)) {
    throw "No mailboxes found on $Server or single Mailbox."
} else {
 Write-Output "Queuing $($Mailboxes.Count) mailboxes as batch '$($BatchName)'"
 # Queue all mailbox export requests
 $teller = 0
 foreach ($Mailbox in $Mailboxes)
 {
     $teller = $teller + 1
     exportMailBox $Mailbox.alias
     if ($teller -gt $maxConcurrentExports){
  Write-Output "Waiting for batch to complete"
  # Wait for mailbox export requests to complete
  waitForCompletion 
  $teller = 0
     }
 }
 # Wait for mailbox export requests to complete
 waitForCompletion
}

# Write reports if required
if ($ReportShare)
{
    Write-Output "Writing reports to $($ReportShare)"
    $Completed = Get-MailboxExportRequest -BatchName $BatchName | Where {$_.Status -eq "Completed"} | Get-MailboxExportRequestStatistics | Format-List
    if ($Completed)
    {
        $Completed | Out-File -FilePath "$($ReportShare)$($BatchName)_Completed.txt"
        Send-MailMessage -From "administrator@ilg.com.au" -To "cturner@themissinglink.com.au" -Subject "Completed Batch $Batchname" -Body "Attached completed report." -Attachments "$($ReportShare)$($BatchName)_Completed.txt" -Priority High -dno onSuccess, onFailure -SmtpServer $smtpserver
    }
    $Incomplete = Get-MailboxExportRequest -BatchName $BatchName | Where {$_.Status -ne "Completed"} | Get-MailboxExportRequestStatistics
    if ($Incomplete)
    {
        $Incomplete | Format-List | Out-File -FilePath "$($ReportShare)$($BatchName)_Incomplete_Report.txt"
        Send-MailMessage -From "administrator@ilg.com.au" -To "cturner@themissinglink.com.au" -Subject "Incomplete Batch $Batchname" -Body "Attached Incomplete report." -Attachments "$($ReportShare)$($BatchName)_Incomplete.txt" -Priority High -dno onSuccess, onFailure -SmtpServer $smtpserver
    
  if (!$list){
   $list = "$($ReportShare)$($BatchName)_failedpst.csv"
  }
  set-content -Value "Failed-PST" -Path $list".new"
  foreach ($woops in $Incomplete) {
   add-content -Value $woops.FilePath -Path $list".new"
  }

    }
}

$endtime = get-date -displayhint time

$runtimefile = "$($ReportShare)$($BatchName)_runtime.txt"
$runtimeentry0 = $starttime.tostring() + ' - ' + $endtime.tostring()
$runtimeentry1 = "Completed exports: " + $completed.count
$runtimeentry2 = "Failedexports: " + $Incomplete.count
$runtimeentry3 = "Errored users:"
$runtimeentry4 = ( get-content -Path $list".new" | out-string)
Set-Content -Value $runtimeentry0 -Path $runtimefile
add-content -Value $runtimeentry1 -Path $runtimefile
add-content -Value $runtimeentry2 -Path $runtimefile
add-content -Value $runtimeentry3 -Path $runtimefile
add-content -Value $runtimeentry4 -Path $runtimefile

# Remove Requests
Write-Output "Removing requests created as part of batch '$($BatchName)'"
Get-MailboxExportRequest -BatchName $BatchName | Remove-MailboxExportRequest -Confirm:$false