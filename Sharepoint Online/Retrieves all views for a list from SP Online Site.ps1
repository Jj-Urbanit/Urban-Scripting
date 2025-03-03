# Site Collection URL or Sub Site URL
$siteurl = "********8"

# User Credentials

$username = "*******"

# Connects and Creates Context
Connect-SPOCSOM -Url $siteurl -Username $USERNAME

# Function to retrieve list views

function RetrieveListViews(){
 
 # Input parameter
 $listName = "Partner"

 # Gets all available views for a list from current site
 $views = Get-SPOListView -ListName $listName

 # Displays the response on the console
 foreach($view in $views){
 Write-Host $view.Title " - " $view.ServerRelativeUrl
 }
}
# Calls the Function

RetrieveListViews #Retrieves all views for a list from SP 