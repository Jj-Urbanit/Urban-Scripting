function Get-SPOWebs(){
param(
   $Url = $(throw "Please provide a Site Collection Url"),
   $Credential = $(throw "Please provide a Credentials")
)

  $context = New-Object Microsoft.SharePoint.Client.ClientContext($Url)  
  $context.Credentials = $Credential 
  $web = $context.Web
  $context.Load($web)
  $context.Load($web.Webs)
  $context.ExecuteQuery()
  foreach($web in $web.Webs)
  {
       Get-SPOWebs -Url $web.Url -Credential $Credential 
       $web
  }
}

Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
$UserName = "cturner_admin@themissinglink.com.au"
$Password = Read-Host
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
  $context = New-Object Microsoft.SharePoint.Client.ClientContext("https://themissinglink.sharepoint.com/sites/client")  
  $context.Credentials = $SPOCredentials 
  $web = $context.Web
  $context.Load($web)
  $context.Load($web.Webs)
  $context.ExecuteQuery()

$AllWebs = Get-SPOWebs -Url 'https://themissinglink.sharepoint.com/sites/client' -Credential $SPOCredentials |select title,url 
$AllWebs | %{ 
write-Host Title is $_.Title
Write-Host URL is $_.URL
Write-Host Description is $_.Description
}