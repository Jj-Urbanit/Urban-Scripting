$aClient = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$aClientRuntime = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$UserName = "cturner_admin@themissinglink.com.au"
$Password = "2017r3Dass"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$Url = "https://themissinglink.sharepoint.com/sites/client/ZieraRetailAustraliaPtyLtd"
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
$ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword)
$clientweb = $ctx.Web  
$ctx.Load($clientweb) 
$ctx.ExecuteQuery()
$name = $clientWeb.Title
#Add description to the "Other category" field
$fieldTitle = "Client Name"
$fieldvalue = "$name"
$field = $ctx.Site.RootWeb.Fields.GetByInternalNameOrTitle($fieldTitle)
#$field.DefaultValue = "zz SharePoint Temporary Client (please update me)"
#$field.UpdateAndPushChanges($true)
Write-Host -------------------------------
Write-Host -------------------------------
Write-Host Site is $name
$write
$ctx.ExecuteQuery()