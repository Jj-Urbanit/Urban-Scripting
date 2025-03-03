#Imports active directory module to only current session
Import-Module activedirectory

#User names whose lastlogondate is less than the presentdate-90days and those usernames are given to the variable output 
$userst=Get-ADUser -Filter * -Searchbase "OU=Users,DC=missinglink,DC=com,DC=au"

foreach($b in $users){
    $g=get-aduser -Identity $b -Properties Name,pwdlastset
    $date=[datetime]$g.pwdLastSet
    $pwdlast =$date.AddYears(1600).ToLocalTime()
    "$b,$pwdlast"
}