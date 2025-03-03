#
# Delicense_Disabled_Users.ps1
#
# Searches all Azure AD users in disabled state and removes licenses
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
#Connect-MsolService -Credential $UserCredential$lic = get-msoluser -EnabledFilter DisabledOnly
$count = 0
foreach ($user in $lic)
{
    if ($user.islicensed -eq $True)
    {
        #write-host $user.displayname is disabled but licensed
        $Skus = $userdet.licenses.AccountSkuId
		Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $Skus
        $count ++
    }
}
Write-Host removed $count licenses