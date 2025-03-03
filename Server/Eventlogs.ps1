##################################################################################################################################################################
#This script is to run on servers mentioned in ServersList.txt and export all errors and critical events to CSV files, create a zip and sending it via email.
#Created by Shayan Ranjbar on 14/08/2018
##################################################################################################################################################################

$ErrorActionPreference = "Stop"
#Remove all variables from previous sessions
Remove-Variable * -ErrorAction SilentlyContinue

#------------------------------------------------------------------------------------#
#Variables
#------------------------------------------------------------------------------------#

$now = Get-Date
#$now = $now.ToString("dd-MM-yyyy_hh-mm-ss")
$MonthlyDate = $now.ToString("dd-MM-yyyy")
$days = (Get-Date).AddDays(-30)
$Computers = Get-Content "C:\Scripts\EventLogs\ServersList.txt"
$CustomerName = "Customer"

#------------------------------------------------------------------------------------#
#Email Variables
#------------------------------------------------------------------------------------#
$SMTPServer= "afmex03"
$From = "$CustomerName-MonthlyReports@domain.com.au"
$To = "a@b.cd"

#------------------------------------------------------------------------------------#
#Script
#------------------------------------------------------------------------------------#

#Checking to make sure the Serverslist has been provided
If(Test-path "C:\Scripts\EventLogs\ServersList.txt"){} else {break}

foreach($computer in $computers){
Try {
Get-WinEvent -ComputerName $computer -FilterHashTable @{logname='Application','System';level=1,2;starttime=$days} -ErrorAction SilentlyContinue | Select-Object Timecreated,LogName,leveldisplayname,Id,message | Export-CSV -Path "C:\Scripts\Eventlogs\Files\$Computer-$MonthlyDate.csv" -NoTypeInformation
} Catch {
Write-host "Script could not pull logs from server $Computer because $_." -ForegroundColor Red
"$Now `| Script failed to pull logs from server $Computer |  $_." | Out-File -FilePath "C:\Scripts\Eventlogs\logs\Failed Servers-$MonthlyDate.log" -append
    }
}

#------------------------------------------------------------------------------------#
#CSV Cleanup/ ZIP
#------------------------------------------------------------------------------------#

$source = "C:\Scripts\Eventlogs\Files"
$destination = "C:\Scripts\Eventlogs\zip\$CustomerName-Monthly Logs-$MonthlyDate.zip"

#Remove CSV files that their concent is blank
get-childItem $Source | where {$_.length -eq 0} | remove-Item

#Check to make sure Destination file does not exist, if yes, remove it
If(Test-path $destination) {Remove-item $destination}

#Compress the CSV files into Zip
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($Source, $destination) 

#Remove CSV files after being zipped
Remove-Item –path $Source\* -Filter *.csv

#------------------------------------------------------------------------------------#
#Send attachment(s) to email
#------------------------------------------------------------------------------------#

$ZipFile = "C:\Scripts\Eventlogs\zip\$CustomerName-Monthly Logs-$MonthlyDate.zip"
$FailedServersFile = "C:\Scripts\Eventlogs\logs\Failed Servers-$MonthlyDate.log"
#Send Zip file
If(Test-path "C:\Scripts\Eventlogs\logs\Failed Servers-$MonthlyDate.log")
{
Send-MailMessage -Attachments $ZipFile,$FailedServersFile -SmtpServer $SMTPServer -From $From -To $to -Subject "$CustomerName Monthly Eventlog Report - $MonthlyDate" -BodyAsHtml "Please find the Monthly report and list of failed servers for $CustomerName in attachement."
} else {
Send-MailMessage -Attachments $ZipFile -SmtpServer $SMTPServer -From $From -To $to -Subject "$CustomerName Monthly Eventlog Report - $MonthlyDate" -BodyAsHtml "Please find the Monthly report for $CustomerName in attachement."
}
