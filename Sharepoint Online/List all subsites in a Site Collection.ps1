# Declare variables
$username = "*******"
$adminsiteurl = "*******"
$siteurl = "*******"
$password = "*******"
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))  


Connect-SPOService  -Credential $username -Url $adminsiteurl

Function Get-Subsites() {  
  
  
    $webURL= $siteurl  
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($webURL)  
    $Context.Credentials = $credentials
    $Web = $context.Web  
    $Context.Load($web)  
    $Context.Load($web.Webs)
    $Context.executeQuery()  
    Write-host $Web.URL  
    foreach ($Subweb in $web.Webs)  
    {  
       Write-host $Subweb.url, $Subweb.name
    }  
}  
  
#Call the function  
Get-SubSites 


Set-SPOSite -Identity