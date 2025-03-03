#
# Accepteddomains_Check_SPF.ps1
#
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$domains = Get-AcceptedDomain
foreach ($domain in $domains)
{
    write-host ================================================================
    write-host Checking TXT records fro $domain
    Resolve-DnsName -name $domain -type txt -server 8.8.8.8
}