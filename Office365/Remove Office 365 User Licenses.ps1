# Set Credentials
$Credential = Get-credential -UserName "username@themissinglink.com.au" -Message Bleh

#Connect to Office 365 & Azure AD
Import-Module AzureAD
Import-Module MsolService
Connect-AzureAD -Credential $credential
Connect-MsolService -Credential $Credential

# Get Microsoft Account SKU
Get-MsolAccountSku

# Get Plan names for particular SKU
(Get-MsolAccountSku | where {$_.AccountSkuId -eq 'themissinglink:ENTERPRISEPACK'}).ServiceStatus

# Set variable for removing licenses based on client environment. For Example:
# $LO = New-MsolLicenseOptions -AccountSkuId "litwareinc:ENTERPRISEPACK" -DisabledPlans "SHAREPOINTWAC", "SHAREPOINTENTERPRISE"
# $LO = New-MsolLicenseOptions -AccountSkuId themissinglink:ENTERPRISEPACK -DisabledPlans "YAMMER_ENTERPRISE"

# Remove licenses for a specific user
Set-MsolUserLicense -UserPrincipalName 'username@themissinglink.com.au' -LicenseOptions $LO


