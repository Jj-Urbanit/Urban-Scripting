cls# Site Collection URL or Sub Site URL
$siteurl = "*******"

# User Credentials
$username = "*********"


# Connects and Creates Context
Connect-SPOCSOM -Url $siteurl -Username $username

# Function to get all lists on the site

function RetrieveLists(){
 # Gets all available lists from current site
 $lists = Get-SPOList
 Write-Host "There are " $lists.count " lists available on the site"
 foreach($list in $lists){
 # Properties for each list
 Write-Host $list.Title
 }
}
# Calls the Function
RetrieveLists #Retrieves all lists from SP site
