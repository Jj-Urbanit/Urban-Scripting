# Site Collection URL or Sub Site URL
$siteurl = "*******"
# User Credentials

$username = "*******"

# Connects and Creates Context
Connect-SPOCSOM -Url $siteurl -Username $username

# Function to Get all Field and their titles

function RetrieveFields(){

 # Retrieves Fields or Site Columns
 $fields = Get-SPOListFields -ListTitle Documentation


 Write-Host "Totally " $fields.Count " fields available on the site"

 # Write output on the console

 foreach($field in $fields){
 Write-Host $field.Title
 }
}
# Calls the Function
# Retrieves all the fields from site level

RetrieveFields | Sort-Object -Descending

