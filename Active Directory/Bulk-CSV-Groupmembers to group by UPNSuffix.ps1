#
# CSV_Groupmembers_to_group_by_UPNSuffix.ps1
#
import-module activedirectory
$csv = import-csv -path c:\temp\domains.csv
foreach ($domain in $csv)
{
    $name = $domain.name
    $users = Get-ADUser -Filter "UserPrincipalName -like '*@$name'"
    $count = ($users).count
    if ($count -gt 0)
    {
        write-host $name
        new-adgroup -name Okta_$name -groupscope Global -path "OU=Okta,OU=PRO-PAC,DC=pb,DC=local"
        add-adgroupmember -identity Okta_$name -members $users
    }
}