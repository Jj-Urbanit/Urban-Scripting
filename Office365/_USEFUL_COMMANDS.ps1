#Important Modules we should install and load
Install-Module PowershellGet -Force
Import-Module PowerShellGet

Install-Module -Name ExchangeOnlineManagement -Force
Install-Module -Name MSOnline -Force
Install-Module -Name AzureAD -Force
Install-Module -Name Az -Repository PSGallery -Force


#Connect 
$Credential=Get-Credential  
Connect-AzureAD –Credential $Credential  

$Credential = Get-Credential  
Connect-MsolService –Credential $Credential  

