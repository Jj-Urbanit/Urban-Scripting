#
# get_spowebtemplates.ps1
#
function get-SPOnlineWebTemplates {
 #variables that needs to be set before starting the script
 $adminUrl = "https://primarycommunitycare.sharepoint.com/sites/services"
 $userName = "tmladmin@PrimaryCommunityCare.onmicrosoft.com"
 $password = Read-Host "Please enter the password for $($userName)" –AsSecureString
  
 #set credentials for SharePoint Online
 $credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $password
  
 #connect to SharePoint Online
 Connect-SPOService -Url $adminUrl -Credential $credentials
  
 get-spoWebTemplate
}
get-SPOnlineWebTemplates