<#
Level31	            209.244.0.3	    209.244.0.4
Verisign2	        64.6.64.6	    64.6.65.6
Google3	            8.8.8.8	        8.8.4.4
DNS.WATCH4	        84.200.69.80	84.200.70.40
Comodo Secure DNS	8.26.56.26	    8.20.247.20
OpenDNS Home5	    208.67.222.222	208.67.220.220
DNS Advantage	    156.154.70.1	156.154.71.1
Norton ConnectSafe6	199.85.126.10	199.85.127.10
GreenTeamDNS7	    81.218.119.11	209.88.198.133
SafeDNS8	        195.46.39.39	195.46.39.40
OpenNIC9	        96.90.175.167	193.183.98.154
SmartViper	        208.76.50.50	208.76.51.51
FreeDNS10	        37.235.1.174	37.235.1.177
Alternate DNS11	    198.101.242.72	23.253.163.53
Yandex.DNS12	    77.88.8.8	    77.88.8.1
censurfridns.dk13	91.239.100.100	89.233.43.71
Hurricane Electric1 74.82.42.42	 
puntCAT15	        109.69.8.51	 
#>
cls

#define vars
[int]$x = 0
[int]$dnschecks = 5
[int]$ipresults = 2
[array]$dnsserverlist = @("209.244.0.3","64.6.64.6","8.8.8.8","84.200.69.80","8.26.56.26","208.67.222.222","156.154.70.1","199.85.126.10","81.218.119.11","195.46.39.39","96.90.175.167","37.235.1.174","198.101.242.72","77.88.8.8","91.239.100.100","74.82.42.42","109.69.8.51") 
[array]$ResultList = @()

#read dns name
[string]$name = Read-Host -Prompt 'Enter a DNS name: '

#resolve with local isp dns
$LocalDNSquery = (Resolve-DnsName -Name $name -Type A -DnssecOk).IPAddress
Write-Host "DNS name resolves with local ISP DNS Server: "$LocalDNSquery

#grab a random list of dns server for resolving
[array]$choosendns = $dnsserverlist | Get-Random -Count $dnschecks

Write-Host "Start resolving..."

for ($x=0;$x -lt ($choosendns.Count);$x++) {
    # define in loop to clear
    $CountryList = @()
    $Result = @()
    
    #resolve with remote dns
    $RemoteDNSquery = (Resolve-DnsName -Name $name -Type A -Server $choosendns[$x] -DnssecOk).IPAddress
    #grab a specific count of ips
    $Result = $RemoteDNSquery | Select -First $ipresults

    for ($i=0;$i -lt ($Result.Count);$i++) {
        #handle string and array in case of one ip
        if(($Result.Count) -eq 1) {
            $CountryList += ((((Invoke-WebRequest "https://extreme-ip-lookup.com/json/$Result").Content) | ConvertFrom-Json).country)
        } else {
            $CountryList += ((((Invoke-WebRequest "https://extreme-ip-lookup.com/json/$($Result[$i])").Content) | ConvertFrom-Json).country)
        }       
    }

    #build output
    if ($RemoteDNSquery)
    {
        #check if hostname existis
        try{
            $hostname = [System.Net.Dns]::GetHostByAddress($choosendns[$x]).hostname
        }
        catch {
            $hostname = "No Hostname"
        }
        # Creating custom object to feed the array
        $Object = New-Object PSObject
        $Object | Add-Member -MemberType NoteProperty -Name "TargetHostname" -Value $name
        $Object | Add-Member -MemberType NoteProperty -Name "ResolvedIP" -Value $Result
        $Object | Add-Member -MemberType NoteProperty -Name "ResultIPCountry" -Value $CountryList
        $Object | Add-Member -MemberType NoteProperty -Name "DNSServerIP" -Value $choosendns[$x]
        $Object | Add-Member -MemberType NoteProperty -Name "ResolverIPCountry" -Value ((((Invoke-WebRequest "https://extreme-ip-lookup.com/json/$($choosendns[$x])").Content) | ConvertFrom-Json).country)
        $Object | Add-Member -MemberType NoteProperty -Name "DNSServerHostname" -Value $hostname
        $ResultList += $Object
    }
}

# Displaying the array with the results
$ResultList