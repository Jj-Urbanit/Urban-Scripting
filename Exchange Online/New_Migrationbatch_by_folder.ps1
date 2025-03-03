#
# new_migrationbatch_by_folder.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
$folderpath = read-host -prompt "enter the folder path containing migration CSVs"
$endpointname = read-host -Prompt "Enter the name of the migration endpoint"
$endpointnames = Get-MigrationEndpoint
if (!(($endpointnames|Select-Object -ExpandProperty Identity) -contains $endpointname))
{
    write-host "migration endpoint name is incorrect. Please check and try again"
    exit
}
Get-ChildItem $folderpath\*.csv | ForEach-Object {
    New-MigrationBatch -CSVData ([System.IO.File]::ReadAllBytes($_.fullname)) -name ($_.Name -replace ".csv","") -BadItemLimit 1000 -LargeItemLimit 1000 -AllowIncrementalSyncs $true -SourceEndpoint $endpointname `
    -TargetDeliveryDomain ppg4.mail.onmicrosoft.com -AllowUnknownColumnsInCsv $true -NotificationEmails cturner@themissinglink.com.au -AutoStart
}