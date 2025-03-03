#
# Disable_dkim_forall_accepteddomains.ps1
#
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$domains = get-accepteddomain
foreach ($domain in $domains)
{
    $dkim = Get-DkimSigningConfig -identity $domain.DomainName
    if ($dkim.enabled -eq $true)
    {
        write-host disabling dkim for $domain.DomainName
        Set-DkimSigningConfig -Identity $domain.DomainName -Enabled $false
    }
}