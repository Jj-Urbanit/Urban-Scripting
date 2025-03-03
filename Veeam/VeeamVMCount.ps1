Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue
Get-VBRCloudTenant | Select-Object description, Name, VMcount | Sort-Object description | Export-Csv -nti -Path "C:\scripts\$((Get-Date).Month)-SmartCLOUDVeeamLicenseUsageReport.csv"
$userPassword = ConvertTo-SecureString -String "burr-wool-65A" -AsPlainText -Force
$userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "svc_Email_Script_Account@themissinglink.onmicrosoft.com", $userPassword
$Month = (Get-Date).month
Send-MailMessage `
    -To "admin@themissinglink.com.au" `
    -Cc "ap@themissinglink.com.au" `
    -Subject "$((Get-Date).Month) - SmartCLOUD Veeam License Usage Report" `
    -SmtpServer "smtp.office365.com" `
    -Credential $userCredential `
    -UseSsl `
    -Port "587" `
    -Body "This is an automatically generated message.<br><br>The Veeam license usage for SmartCLOUD this month is attached.</b><br><br>Reported from ausyd1vbr002.cloud.themissinglink.com.au</b><br><br>AP Bot" `
    -From "veeamusage@themissinglink.com.au" `
    -Attachments "C:\scripts\$((Get-Date).Month)-SmartCLOUDVeeamLicenseUsageReport.csv" `
    -BodyAsHtml