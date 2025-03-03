#Install the Sharepoint Online Module
Install-Module SharePointPnPPowerShellOnline

#Connect to specific SharePoint Tenancy
Connect-PnPOnline -Url https://*sharepointURL*

#Number of items in Recyclebin
(Get-PnPRecycleBinItem).count

#Filter by date:
{
#set the restore date to yesterday
$today = (Get-Date)
$restoreDate = $today.date.AddDays(-1)
 
#get all items that are deleted yesterday or today, select the last 10 items and display a list with all properties
Get-PnPRecycleBinItem | ? DeletedDate -gt $restoreDate | select -last 10 | fl *
}

#Find files between dates
{
$today = (Get-Date) 
$date1 = $today.date.addDays(-4)
$date2 = $today.date.addDays(-6)
 
Get-PnPRecycleBinItem | Where-Object { DeletedDate -gt $date2 -and DeletedDate -lt $date1}  | select -last 10 | fl *
}

#Filter by user
Get-PnPRecycleBinItem -FirstStage | ? DeletedByEmail -eq 'john@contoso.com'

#Filter by file type
Get-PnPRecycleBinItem -FirstStage | ? LeafName -like '*.docx'

#Restore Files.
et-PnPRecycleBinItem -firststage | ? {$_.DeletedDate -gt $restoreDate -and $_.DeletedByEmail -eq 'john@contoso.com'} | Restore-PnpRecycleBinItem -Force

#Find Items Deleted from a specific Folder
Get-PnPRecycleBinItem | Where-Object {$_.DirName -contains "*Path*"} 

#Select a file and restore it
Get-PnPRecycleBinItem | Where-Object {$_.Id -eq "File ID"} | Restore-PnPRecycleBinItem

#Export a CSV of everything in Recycle Bin
Get-PnPRecycleBinItem | select *  | Export-Csv c:\temp\deleted.csv