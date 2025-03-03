#Add-PSSnapin "Microsoft.SharePoint.PowerShell"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")


[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")




$siteUrl = "https://themissinglink.sharepoint.com/sites/corporate/financetmls"


$username = "cturner_admin@themissinglink.com.au"


#$password = Read-Host -Prompt "Enter password" -AsSecureString


$Context = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)


$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password)

$Context.Credentials = $credentials

$Lists = $Context.Web.Lists
$Context.Load($Lists)
$Context.ExecuteQuery()
foreach ($list in $lists) {
    $Context.Load($List)
    $Context.ExecuteQuery()
    #for ($h = 0; $h -lt $lists.Count; $h++)
    #{
        $views = $list.Views
        $Context.Load($Views)
        $Context.ExecuteQuery()
        $Context.load($list.views)
        Write-Host =======================================================
        Write-Host 'lists' $list.title
        foreach ($view in $views) {
            $Context.Load($view)
            $Context.ExecuteQuery()
            foreach ($v in $view){
                Write-Host _____________________________________________________________
                Write-Host 'views' $v.title
                if ($v.title -eq "All Documents"){
                    Write-Host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					write-host $v.OrderedView
                    $v.ViewQuery = '<OrderBy><FieldRef Name="Modified" Ascending="FALSE" /></OrderBy>'
                    $v.Update();
                }
                else {$null}
                #$view=$views[$i];
                	
            }
        }
    #}
}

$Context.ExecuteQuery()