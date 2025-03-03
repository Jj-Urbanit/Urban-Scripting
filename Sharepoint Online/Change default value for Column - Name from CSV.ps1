# This script has two pre-requisites: 
# A CSV with two columns, containing the name of each of the sub-sites and the URL of each site. 
# An encrypted password stored in the C:\Temp folder called EncryptedPassword.txt
# If these files exist, the script requires no interaction.
# the encrypted password file can be created with the following command:
# Read-Host -Prompt Password -AsSecureString | ConvertFrom-SecureString |Out-File "C:\Temp\EncryptedPassword.txt"


# Universal variables
$FieldName = "Client Name"
$ListName1 = "Projects"
$ListName2 = "Agreements"
$ListName3 = "Documentation"
$ListName4 = "Projects"
$ListName5 = "Quotes & Proposals" 
#Import CSV file - One column titled 'URL', one headed 'Title'
$username = "*******@themissinglink.com.au"
$password = Get-Content -Path "C:\temp\EncryptedPassword.txt" | ConvertTo-SecureString
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

$clients = Import-Csv "C:\Temp\object.csv"

# Commented-out Site Collection URL or Sub Site URL - use this for testing a single site
# $siteurl = "https://themissinglink.sharepoint.com/sites/client/themissinglink"

# Make the change for all lines in csv
foreach ($row in $clients) 
{
    # Declare variables based on CSV
    $siteurl = $row.url     
    $ClientName = $row.title
    # Connects to the site listed under the 'URL' column in the CSV
        Connect-SPOCSOM -Url $siteurl -Credential $cred -Verbose
            function RetrieveFieldByName()
    {
        # Retrieves Field or Site Column
        $field = Get-SPOListColumn -ListTitle $ListName1 -FieldTitle $FieldName
    
        
        # Change the default value for the column to be the entry under 'title' in the csv
        Set-SPOListColumn -ListTitle $ListName1 -FieldTitle $FieldName -DefaultValue $ClientName
        $field = Get-SPOListColumn -ListTitle $ListName2 -FieldTitle $FieldName
        Set-SPOListColumn -ListTitle $ListName2 -FieldTitle $FieldName -DefaultValue $ClientName
        $field = Get-SPOListColumn -ListTitle $ListName3 -FieldTitle $FieldName
        Set-SPOListColumn -ListTitle $ListName3 -FieldTitle $FieldName -DefaultValue $ClientName
        $field = Get-SPOListColumn -ListTitle $ListName4 -FieldTitle $FieldName
        Set-SPOListColumn -ListTitle $ListName4 -FieldTitle $FieldName -DefaultValue $ClientName
        $field = Get-SPOListColumn -ListTitle $ListName5 -FieldTitle $FieldName
        Set-SPOListColumn -ListTitle $ListName5 -FieldTitle $FieldName -DefaultValue $ClientName
        
        # Write the changed value to screen to confirm a change was made
        Get-SPOListColumn -ListTitle $ListName1 -FieldTitle $FieldName | Select-Object DefaultValue,scope
    }
    
    # Calls the Function
    RetrieveFieldByName
}
