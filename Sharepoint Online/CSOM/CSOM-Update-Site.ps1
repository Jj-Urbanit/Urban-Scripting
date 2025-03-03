Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"

$UserName = "cturner_admin@themissinglink.com.au"
$Password = "S3cur32018"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
  $context = New-Object Microsoft.SharePoint.Client.ClientContext("https://themissinglink.sharepoint.com/sites/client/ZieraRetailAustraliaPtyLtd")  
  $context.Credentials = $SPOCredentials 
  $web = $context.Web
  $context.Load($web)
  
$web.Description = "New Change"
 
$web.Update()
 
$context.ExecuteQuery()