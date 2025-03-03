#Script to reset network interfaces to use DHCP (IPV4 Only) 
# 

$IPV = "IPv4"
#Collecting all interfaces with Stuats UP
$Adapter = Get-NetAdapter | ? {$_.Status -eq “up”}
$ifname = $Adapter.Name
#Selecting IPV4
$interface = $adapter | Get-NetIPInterface -AddressFamily $IPV
$interfacename = $Adapter | -InterfaceDescription

#Setting IP and DNS settings to Use DNS
$interface | Remove-NetRoute -Confirm:$false
$interface | Set-NetIPInterface -DHCP Enabled
$interface | Set-DnsClientServerAddress -ResetServerAddresses
#Renewing IP address
ipconfig /renew