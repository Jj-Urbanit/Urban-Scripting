# Declare Universal variables

# Site Collection URL or Sub Site URL
 $siteurl = "*******"
 
# List and column information 
 $FieldName = "*******"
 $ListName = "*******"
# User Credentials
$username = "*******"

# Connects and Creates Context

Connect-SPOCSOM -Url $siteurl -Username $username -Verbose

# Function to Get a Field by Name and change the default value. Prints the before and after to the screen to confirm the change.

function RetrieveFieldByName(){

    # Retrieves Field or Site Column

 $field = Get-SPOListColumn -ListTitle $ListName -FieldTitle $FieldName
 $ClientName = "zz SharePoint Default Client (Please update me)"

 # Write output on the console

 Write-Host "Default Value before change : " $field.DefaultValue

 Set-SPOListColumn -ListTitle $ListName -FieldTitle $FieldName -DefaultValue $ClientName

 }

# Calls the Function
# Retrieves required field by using field name

RetrieveFieldByName 


Get-SPOListColumn -ListTitle $ListName -FieldTitle $FieldName | Select-Object scope,DefaultValue

