# Get members of all AD distribution groups and output to a CSV file

#Includes only names and no other info. Add more details by adding to -Properties in Get-ADUser

# to Filter by type of group, use  -Filter 'groupcategory -eq "distribution"' or 'groupcategory -eq "security"'

$groups = Get-ADGroup -filter 'groupcategory -eq "distribution"'
$output = ForEach ($g in $groups) 
 {
 $results = Get-ADGroupMember -Identity $g.name -Recursive | Get-ADUser -Properties displayname

 ForEach ($r in $results){
 New-Object PSObject -Property @{
        GroupName = $g.Name
        Username = $r.name
     }
    }
 } 
 $output | Export-Csv -path c:\temp\output.csv 