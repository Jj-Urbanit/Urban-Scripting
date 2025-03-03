#
# SMTP_Relay.ps1
#
Import-Module ServerManager 
Add-WindowsFeature SMTP-Server,Web-Mgmt-Console,WEB-WMI
$Networkip =@()
$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName    localhost | ? {$_.IPEnabled}
foreach($Network in $Networks)  {  $Networkip = $Network.IpAddress[0]  }

$ipblock= @(24,0,0,128,
32,0,0,128,
60,0,0,128,
68,0,0,128,
1,0,0,0,
76,0,0,0,
0,0,0,0,
0,0,0,0,
1,0,0,0,
0,0,0,0,
2,0,0,0,
1,0,0,0,
4,0,0,0,
0,0,0,0,
76,0,0,128,
0,0,0,0,
0,0,0,0,
0,0,0,0,
0,0,0,0,
255,255,255,255)

$ipList = @()
$octet = @()
$connectionips=$arg[0]       
$ipList = "127.0.0.1"
$octet += $ipList.Split(".")
$octet += $Networkip.Split(".")

$ipblock[36] +=2 
$ipblock[44] +=2;
$smtpserversetting = get-wmiobject -namespace root\MicrosoftIISv2 -computername localhost -Query "Select * from IIsSmtpServerSetting"
$ipblock += $octet
$smtpserversetting.AuthBasic=1
$smtpserversetting.RelayIpList = $ipblock
$smtpserversetting.put()

$connectionips="10.10.10.10"      

$checkArray =$connectionips.split(",") 
if($checkArray -notcontains $Networkip)
{
 $connectionips += ","+$Networkip
}

$connectionipbuild=@()
$ipArray=$connectionips.split(",")
foreach ($ip in $ipArray)
{   
  $connectionipbuild +=$ip+",255.255.255.255;"     
}

$iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/SmtpSvc/1")
$ipSec = $iisObject.Properties["IPSecurity"].Value

# We need to pass values as one element object arrays
[Object[]] $grantByDefault = @()
$grantByDefault += , $false            # <<< We're setting it to false

$ipSec.GetType().InvokeMember("GrantByDefault", $bindingFlags, $null, $ipSec, $grantByDefault);

$iisObject.Properties["IPSecurity"].Value = $ipSec
$iisObject.CommitChanges()

$iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/SmtpSvc/1")
$ipSec = $iisObject.Properties["IPSecurity"].Value
$bindingFlags = [Reflection.BindingFlags] "Public, Instance, GetProperty"
$isGrantByDefault = $ipSec.GetType().InvokeMember("GrantByDefault", $bindingFlags, $null, $ipSec, $null);

# to set an iplist we need to get it first
if($isGrantByDefault)
{
    $ipList = $ipSec.GetType().InvokeMember("IPDeny", $bindingFlags, $null, $ipSec, $null);
}
else
{
    $ipList = $ipSec.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $ipSec, $null);
}

# Add a single computer to the list:
$ipList = $ipList + $connectionipbuild

# This is important, we need to pass an object array of one element containing our ipList array
[Object[]] $ipArray = @()
$ipArray += , $ipList

# Now update
$bindingFlags = [Reflection.BindingFlags] "Public, Instance, SetProperty"
if($isGrantByDefault)
{
    $ipList = $ipSec.GetType().InvokeMember("IPDeny", $bindingFlags, $null, $ipSec, $ipArray);
}
else
{
    $ipList = $ipSec.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $ipSec, $ipArray);
}

$iisObject.Properties["IPSecurity"].Value = $ipSec
$iisObject.CommitChanges()