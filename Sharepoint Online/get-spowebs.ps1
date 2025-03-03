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