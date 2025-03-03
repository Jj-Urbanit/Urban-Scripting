# This script requires an encrypted password stored in the C:\Temp folder called EncryptedPassword.txt
# If this file exists, the script requires no interaction.
# This file can be created with the following command:
# Read-Host -Prompt Password -AsSecureString | ConvertFrom-SecureString |Out-File "C:\Temp\EncryptedPassword.txt"
# Declare variables
$username = "dmathison_admin@themissinglink.com.au"
$adminsiteurl = "https://themissinglink-admin.sharepoint.com"
$siteurl = "https://themissinglink.sharepoint.com/sites/client"
$password = Get-Content -Path "C:\temp\EncryptedPassword.txt" | ConvertTo-SecureString
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,$password)

#$Logon = $username,$password
# Connect SharePoint Online
Connect-SPOService -Url $adminsiteurl -Credential $Cred
Write-Host "Exporting...."
# Pull Subsite name & URL for all sub-sites in $siteurl

$Object = @()
$webURL= $siteurl  
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($webURL)  
$Context.Credentials = $Credentials
$Web = $context.Web  
$Context.Load($web)  
$Context.Load($web.Webs)
$Context.executeQuery()

foreach ($Subweb in $web.Webs)  
{
    $Object += [PSCustomObject]@{
        Title = $subweb.Title;
        Url = $Subweb.url
    }
}
 

# Export to CSV
$Object | Export-Csv c:\temp\object.csv -NoTypeInformation -Force