$aClient = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$aClientRuntime = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$UserName = "cturner_admin@themissinglink.com.au"
$SecurePassword = Read-Host -Prompt "enter password" -AsSecureString
#$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$Url = "https://themissinglink.sharepoint.com/sites/client/ZieraRetailAustraliaPtyLtd"
$list = "https://themissinglink.sharepoint.com/sites/client/ZieraRetailAustraliaPtyLtd\documentation"
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
$list = New-Object Microsoft.Office.DocumentManagement.MetadataDefaults($listctx)
$ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$SecurePassword) 
$clientweb = $ctx.Web  
$ctx.Load($clientweb) 
$ctx.ExecuteQuery()
$name = $clientWeb.Title
$listname = $listctx.title
$listctx.load($listname)

#$f = $sList.Fields["Client Name"]
#$f.DefaultValue = "$name"
#$f.Update()
Write-Host Name is $name
Write-Host List is $list
Write-Host Listname is $listname

#Write-Host Field is $field
#Write-Host Doclib is $docLib
#Write-Host Web is $clientweb
$ctx.ExecuteQuery()