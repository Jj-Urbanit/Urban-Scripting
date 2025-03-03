#Check if a profile exists
Test-Path $Profile

#Create a profile
New-Item –Path $Profile –Type File –Force

#Copy paste the following into the profile:

Write-host -ForegroundColor Green "================================"
Write-host -ForegroundColor Yellow "Powershell Functions Available:"
Write-host -ForegroundColor White "          Connect-365           "
Write-host -ForegroundColor White "           Check-DNS            "
Write-host -ForegroundColor Green "================================"

#Connect to Office 365
Function Connect-365{

$UserCredential = Get-Credential

function Show-Menu
{
    param (
        [string]$Title = '365 Options'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Connect to Exchange Online."
    Write-Host "2: Press '2' for Connect to Azure AD."
    Write-Host "3: Press '3' for Connect to Sharepoint Online."
    Write-Host "4: Press '4' for Connect to On-Prem Exchange."
    Write-Host "Q: Press 'Q' to quit."
}

Show-Menu –Title '365 Options'
 $selection = Read-Host "Please make a selection"
 switch ($selection)
 {
     '1' {
     'Connecting to Exchange Online'
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -DisableNameChecking
     } '2' {
     'Connecting to Azure AD'
    Connect-AzureAD -Credential $UserCredential
     } '3' {
     'Connecting to Sharepoint Online'
     $Url = Read-Host "Please input URL for Sharepoint" 
    Connect-SPOService -Url $Url -Credential $UserCredential
     } '4' {
     'Connecting to On Premise Exchange Server'
     $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ausyd1exch01/PowerShell/ -Authentication Kerberos -Credential $UserCredential
    Import-PSSession $Session -DisableNameChecking
     } 'q' {
         return
     }
 }
 }

Function Check-DNS {

    param
    (
        [Parameter(Mandatory)]$Domain,
        [Parameter(Mandatory)][ValidateSet("AAAA", "A", "NS", "MD", "MF", "CNAME", "SOA", "MB", "MG", "MR", "WKS", "PTR", "HINFO", "MINFO", "MX", "TXT", "RP", "AFSDB", "X25", "ISDN", "RT", "AAAA", "SRV", "DNAME", "OPT", "DS", "RRSIG", "NSEC", "DNSKEY", "DHCID", "NSEC3", "NSEC3PARAM", "ANY", "ALL", "WINS")][String]$RecordType
        )
    
        $server = Read-Host -Prompt 'Input DNS Server to Check Against (e.g. Google, OpenDNS, CloudFlare, 1.1.1.1, 8.8.8.8)'
        IF ( $server -eq [string]::empty) 
            {$server = 1.1.1.1
            Write-Host -ForegroundColor Yellow "DNS Server: CloudFlare (1.1.1.1)"}

        IF ( $server -eq [string]'Google') 
            {$server = 8.8.8.8
            Write-Host -ForegroundColor Yellow "DNS Server: Google DNS (8.8.8.8)"}

        IF ( $server -eq [string]'8.8.8.8') 
            {$server = 8.8.8.8
            Write-Host -ForegroundColor Yellow "DNS Server: Google DNS (8.8.8.8)"}

        IF ( $server -eq [string]'8.8.4.4') 
            {$server = 8.8.4.4
            Write-Host -ForegroundColor Yellow "DNS Server: Google DNS (8.8.4.4)"}

        IF ( $server -eq [string]'CloudFlare') 
            {$server = 1.1.1.1
            Write-Host -ForegroundColor Yellow "DNS Server: CloudFlare (1.1.1.1)"}

        IF ( $server -eq [string]'1.1.1.1') 
            {$server = 1.1.1.1
            Write-Host -ForegroundColor Yellow "DNS Server: CloudFlare (1.1.1.1)"}

        IF ( $server -eq [string]'1.0.0.1') 
            {$server = 1.0.0.1
            Write-Host -ForegroundColor Yellow "DNS Server: CloudFlare (1.0.0.1)"}

        IF ( $server -eq [string]'OpenDNS') 
            {$server = 208.67.222.222
            Write-Host -ForegroundColor Yellow "DNS Server: OpenDNS (208.67.222.222)"}

        IF ( $server -eq [string]'208.67.222.222') 
            {$server = 208.67.222.222
            Write-Host -ForegroundColor Yellow "DNS Server: OpenDNS (208.67.222.222)"}

        IF ( $server -eq [string]'208.67.220.220') 
            {$server = 208.67.220.220
            Write-Host -ForegroundColor Yellow "DNS Server: OpenDNS (208.67.220.220)"}

    Resolve-DnsName -Name $domain -Type $recordtype -Server $server -DnsOnly -NoHostsFile
}