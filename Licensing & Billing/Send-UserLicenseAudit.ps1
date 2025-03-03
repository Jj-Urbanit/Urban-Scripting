C:\scripts\AP-Get-LicenseAudit.ps1
$userPassword = ConvertTo-SecureString -String "burr-wool-65A" -AsPlainText -Force 
$userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "svc_Email_Script_Account@themissinglink.onmicrosoft.com", $userPassword
$Month = (Get-Date).month
"smartservices users","citrix users" | Get-LicenseAudit | Export-Csv -path $("C:\scripts\$month"+"UserList.csv") -NoTypeInformation -ErrorAction Ignore -Force
Send-MailMessage `
    -Cc "jninios@themissinglink.com.au" `
    -To "admin@themissinglink.com.au" `
    -Attachments $("C:\scripts\$month"+"UserList.csv") `
    -SmtpServer "smtp.office365.com" `
    -Credential $userCredential `
    -UseSsl "Backup Notification" `
    -Port "587" `
    -Body "This is an automatically generated message.<br>This email will include the list of licensed users for SmartCLOUD Citrix and SmartSERVICES at RT Forsythe.<br><br><b>AP Bot</b>" `
    -From "svc_Email_Script_Account@themissinglink.com.au" `
    -BodyAsHtml