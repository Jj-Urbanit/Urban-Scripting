$DFSGroupName = 'Trenchless Group'
$DFSservers = (Get-DfsrMembership -GroupName $DFSGroupName | Select-Object -ExpandProperty computername)
$foldernamedate = $(get-date -f dd-MM-yyyy)
$source = 'C:\DFSReportsImport\'
$destination = "C:\DFSReportsExport\$foldernamedate\DFS_Report.zip"
$emailServer = 'uea-caht01.uea.com.au'
$Sender = 'tmladmin@uea.com.au'
$recipients = 'servicedesk@themissinglink.com.au'
$DFSRArchive = 'C:\DFSReports'

New-Item -Path c:\DFSReportsImport\$foldernamedate -ItemType Directory
New-Item -Path c:\DFSReportsExport\$foldernamedate -ItemType Directory
Write-DfsrHealthReport -GroupName $DFSGroupName -ReferenceComputerName $DFSservers[0] -MemberComputerName $DFSservers[0], $DFSservers[1] -CountFiles -Path c:\DFSReportsImport\$foldernamedate\
Add-Type -assembly 'system.io.compression.filesystem'
[io.compression.zipfile]::CreateFromDirectory($source, $destination)
Copy-Item -Path $destination -Destination $DFSRArchive
Remove-Item -path c:\DFSReportsImport\$foldernamedate -Recurse -Force
Send-MailMessage -from $Sender -to $recipients -subject "DFS Report $foldernamedate" -Body "DFS Report to advise status of Replication between $DFSservers[0]" -smtpserver $EmailServer -attachments "C:\DFSReportsExport\$foldernamedate\DFS_Report.zip"
Remove-Item -path c:\DFSReportsExport\$foldernamedate -Recurse -Force