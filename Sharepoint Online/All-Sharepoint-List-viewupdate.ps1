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
#Add-PSSnapin "Microsoft.SharePoint.PowerShell"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")


[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")




$siteUrl = “https://themissinglink.sharepoint.com/sites/client/”


$username = "cturner_admin@themissinglink.com.au"


#$password = Read-Host -Prompt "Enter password" -AsSecureString


$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)


$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password)

$ctx.Credentials = $credentials

$Lists = $Ctx.Web.Lists
$Ctx.Load($Lists)
$Ctx.ExecuteQuery()
foreach ($list in $lists) {
    $Ctx.Load($List)
    $Ctx.ExecuteQuery()
    #for ($h = 0; $h -lt $lists.Count; $h++)
    #{
        $views = $list.Views
        $Ctx.Load($Views)
        $Ctx.ExecuteQuery()
        $ctx.load($list.views)
        #Write-Host =======================================================
        #Write-Host 'lists' $list.title
        foreach ($view in $views) {
            $Ctx.Load($view)
            $Ctx.ExecuteQuery()
            foreach ($v in $view){
                #Write-Host _____________________________________________________________
                #Write-Host 'views' $v.title
                if ($v.title -eq "All Documents"){
                    #write-host $v.OrderedView
                    $v.ViewQuery = '<OrderBy><FieldRef Name="Modified" Ascending="FALSE" /></OrderBy>'
                    $v.Update();
                }
                else {$null}
                #$view=$views[$i];
                	
            }
        }
    #}
}
#$DefaultView = $lists.DefaultView
#$Ctx.Load($DefaultView)
#$Ctx.ExecuteQuery()

#$DefaultView.ViewFields.Add("Created")

#$DefaultView.ViewFields.Add("ID")


#$DefaultView.Update()

$ctx.ExecuteQuery()