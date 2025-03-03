#quick way to modify attributes for bulk users
Import-Module ActiveDirectory

$users= Get-ADUser -SearchBase "OU=Users,OU=whatever,DC=domain,DC=local" -Filter *

foreach($user in $users){
    SET-ADUSER $user –replace @{attribute=”value”}
}