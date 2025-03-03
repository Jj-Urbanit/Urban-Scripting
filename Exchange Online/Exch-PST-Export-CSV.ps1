$list = Import-Csv "D:\Mimecast-Users.csv"
foreach($entry in $list) {
$User = $entry
New-MailboxExportRequest $user -FilePath \\sbs1\pst-export$\$($user.primarysmtpaddress).pst
}