import-module ActiveDirectory

$groups= get-adgroup -filter * -searchbase "OU=Okta,OU=PRO-PAC,DC=pb,DC=local" -properties distinguishedname

$csv = import-csv -Path c:\sharedmbs.csv
foreach ($user in $csv)
{
    $founduser = Get-ADUser -Filter "UserPrincipalName -eq '$($user.userprincipalname)'" -Properties memberof
    $foundname = $founduser.name
    foreach ($group in $founduser.memberof)
    {
        $groups | where { $_.distinguishedname -eq $founduser.memberof} |% {
            #Remove-ADGroupMember -Identity "$group" -Members "$user" -Confirm:$false
            ECHO "Removing $foundname from $group"
        }
    }
}