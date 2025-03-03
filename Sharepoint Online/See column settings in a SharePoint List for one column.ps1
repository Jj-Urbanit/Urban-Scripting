# Note - the schema.xml file in this script produces all TML clients, to it's very long. Remove this entry to see the other results easily.

# Declare universal Variables

    # Site Collection URL or Sub Site URL
    $siteurl = "https://themissinglink.sharepoint.com/sites/client/AllianceSI"
    # User Credentials
    $username = "dmathison_admin@themissinglink.com.au"


# Connects and Creates Context
import-module .\SPOMod.psm1 -verbose
Connect-SPOCSOM -Url $siteurl -Username $username

# Function to Get a Field by Name

function RetrieveFieldByName(){

 # Input Parameter

 $FieldName = "Client Name"
 $ListName = "Projects"

 # Retrieves Field or Site Column

 $field = Get-SPOListColumn -ListTitle $ListName -FieldTitle $FieldName
  
 # Write output on the console

 Write-Host "Field ID : " $field.Id
 Write-Host "Field Title : " $field.Title
 Write-Host "Description : " $field.Description
 Write-Host "Default Value : " $field.DefaultValue
 Write-Host "Group : " $field.Group
 Write-Host "Scope : " $field.Scope
}

# Calls the Function & retrieves required field by using field name

RetrieveFieldByName 

