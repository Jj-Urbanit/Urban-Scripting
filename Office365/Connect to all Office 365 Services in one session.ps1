#Running this script will connect to all of the below Office 365 services simultaneously. 
#The prerequisites for this and further info can be found here: https://technet.microsoft.com/en-us/library/dn568015.aspx
#The services connected to are: 
#Office 365 admin center, SharePoint Online, Exchange Online, Skype for Business Online, and the Security & Compliance Center
$username = "dmathison_admin@themissinglink.com.au"
$password = Get-Content -path "C:\temp\EncryptedPassword.txt" | ConvertTo-SecureString
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password


#Connect to Office 365
Import-Module AzureAD
Connect-AzureAD -Credential $credential
Connect-MsolService -Credential $Credential -Verbose

#Connect to SharePoint Online
#Replace "domainhost" with your URL
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url https://themissinglink-admin.sharepoint.com -credential $credential

#Connect to Exchange Online
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#Connect to Security & Compliance Center
$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $ccSession -Prefix cc

Write-host 'All services connected'

Import-Module LyncOnlineConnector  -verbose
New-CsOnlineSession -Credential $Credential