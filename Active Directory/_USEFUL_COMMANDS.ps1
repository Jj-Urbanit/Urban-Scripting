Get-ADUser -Filter *
Get-ADUser USERNAME -Properties *
Get-ADUser USERNAME -Properties * | Select name, department, title
Get-ADUser -SearchBase “OU=ADPRO Users,dc=ad,dc=activedirectorypro.com” -Filter *
Get-ADUser -Filter {name -like "*robert*"}
Get-ADUser -filter * -properties Name, PasswordNeverExpires | where {$_.passwordNeverExpires -eq "true" } | Select-Object DistinguishedName,Name,Enabled

#Force Password Change at Next Login
Set-ADUser -Identity username -ChangePasswordAtLogon $true

#List all Disabled User Accounts
Search-ADAccount -AccountDisabled

#Find All Locked User Accounts
Search-ADAccount -LockedOut

#Unlock User Account
Unlock-ADAccount –Identity john.smith

#Disable User Account
Disable-ADAccount -Identity rallen


#Get All members Of A Security group
Get-ADGroupMember -identity "HR Full"

#Get All Security Groups
#This will list all security groups in a domain
Get-ADGroup -filter *

#Add User to Group
#Change group-name to the AD group you want to add users to
Add-ADGroupMember -Identity group-name -Members Sser1, user2

#Export Users From a Group
#This will export group members to a CSV, change group-name to the group you want to export.
Get-ADGroupMember -identity "Group-name" | select name | Export-csv -path C:\OutputGroupmembers.csv -NoTypeInformation

#Get Group by keyword
#Find a group by keyword. Helpful if you are not sure of the name, change group-name.
get-adgroup -filter * | Where-Object {$_.name -like "*group-name*"}

#Import a List of Users to a Group
$members = Import-CSV c:itadd-to-group.csv | Select-Object -ExpandProperty samaccountname Add-ADGroupMember -Identity hr-n-drive-rw -Members $members

#Get All Computers
#This will list all computers in the domain
Get-AdComputer -filter *

#Get All Computers by Name
#This will list all the computers in the domain and only display the hostname
Get-ADComputer -filter * | select name

#Get All Computers from an OU
Get-ADComputer -SearchBase "OU=DN" -Filter *

#Get a Count of All Computers in Domain
Get-ADComputer -filter * | measure

#Get all Windows 10 Computers
#Change Windows 10 to any OS you want to search for
Get-ADComputer -filter {OperatingSystem -Like '*Windows 10*'} -property * | select name, operatingsystem

#Get a Count of All computers by Operating System
#This will provide a count of all computers and group them by the operating system. A great command to give you a quick inventory of computers in AD.
Get-ADComputer -Filter "name -like '*'" -Properties operatingSystem | group -Property operatingSystem | Select Name,Count

#Delete a single Computer
Remove-ADComputer -Identity "USER04-SRV4"

#Delete a List of Computer Accounts
#Add the hostnames to a text file and run the command below.
Get-Content -Path C:ComputerList.txt | Remove-ADComputer

#Delete Computers From an OU
Get-ADComputer -SearchBase "OU=DN" -Filter * | Remote-ADComputer