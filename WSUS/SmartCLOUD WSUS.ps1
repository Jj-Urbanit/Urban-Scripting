
New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"WSUS Automatic Reboot 01" -Path:"OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -SamAccountName:"WSUS Automatic Reboot 01" -Server:"ausyd1ads001.cloud.themissinglink.com.au"
Set-ADObject -Identity:"CN=WSUS Automatic Reboot 01,OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -ProtectedFromAccidentalDeletion:$true -Server:"ausyd1ads001.cloud.themissinglink.com.au"

New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"WSUS Automatic Reboot 02" -Path:"OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -SamAccountName:"WSUS Automatic Reboot 02" -Server:"ausyd1ads001.cloud.themissinglink.com.au"
Set-ADObject -Identity:"CN=WSUS Automatic Reboot 02,OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -ProtectedFromAccidentalDeletion:$true -Server:"ausyd1ads001.cloud.themissinglink.com.au"

New-ADGroup -GroupCategory:"Security" -GroupScope:"Global" -Name:"WSUS Automatic Reboot 03" -Path:"OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -SamAccountName:"WSUS Automatic Reboot 03" -Server:"ausyd1ads001.cloud.themissinglink.com.au"
Set-ADObject -Identity:"CN=WSUS Automatic Reboot 03,OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -ProtectedFromAccidentalDeletion:$true -Server:"ausyd1ads001.cloud.themissinglink.com.au"

Set-ADGroup -Add:@{
    'Member'="CN=AUMEL1SQL002,OU=Database,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUSYD1ADS001,OU=Domain Controllers,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUSYD1VBR001,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au",
    "CN=AUSYD1VMGMT001,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUSYD1VWA02,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUMEL1VBR001,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005024,OU=vCenter,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005023,OU=Database,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005022,OU=vCenter,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005017,OU=vCenter,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005008,OU=Citrix,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY1MGMT002,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au"
} -Identity:"CN=WSUS Automatic Reboot 01,OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -Server:"ausyd1ads001.cloud.themissinglink.com.au"

Set-ADGroup -Add:@{
    'Member'="CN=AUSYD1ADS002,OU=Domain Controllers,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUSYD1VBR002,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=AUSYD1VWA01,OU=Veeam,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au", 
    "CN=SVSY3005014,OU=Storage,OU=Servers,OU=Computers,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au"
} -Identity:"CN=WSUS Automatic Reboot 02,OU=Groups,OU=Hosting,DC=cloud,DC=themissinglink,DC=com,DC=au" -Server:"ausyd1ads001.cloud.themissinglink.com.au"
