#
# Push_new_sitecolumn.ps1
#
###################################
# Used to add the site column to all lists in all client subsites
###################################
#following line used to enforce TLS 1.2 in powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"

#Parameters
$URL="https://themissinglink.sharepoint.com/sites/client"
#Change url below for testing. If using this, uncomment the lines 47 and 48 checking against clienturl and line 112 closing parenthasis.
#$ClientURL="https://themissinglink.sharepoint.com/sites/client/ColemanGreigLawyersPtyLtd"
#$changeLists="Documentation"
$changeLists="Documentation","Agreements","Projects","Quotes & Proposals"
$SiteColumnName1="Client"
#$SiteColumnName2="Client:AccountExecutive"
$ViewName="All Documents"
$UserName="cturner_admin@themissinglink.com.au"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Credential = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $Password)
$context = New-Object Microsoft.SharePoint.Client.ClientContext($Url)  
$context.Credentials = $Credential 
$rootWeb = $context.Web 
   

#Try {
    #Get the Site column from web
    $SiteColumns = $rootWeb.Fields
    $Context.Load($SiteColumns)
    $SiteColumn1 = $rootWeb.Fields.GetByTitle($SiteColumnName1)
    #$SiteColumn2 = $rootWeb.Fields.GetByTitle($SiteColumnName2)
    
    #Check if given site column exists
    if($SiteColumn1 -eq $Null)
    {
        Write-host "Site Column $SiteColumnName doesn't exists!" -f Yellow
        }
    else
    {
        # sites under the root web site
        $sites  = $rootWeb.Webs 
        $Context.Load($sites)
        $Context.ExecuteQuery()
        foreach($subsite in $sites)
        {
            #if ($subsite.Url -eq $ClientURL)
            #{
                write-host ====================
                write-host -f DarkRed site is $subsite.Title
                $context.load($subsite.Webs)
                $Context.ExecuteQuery() 
                $cururl = $subsite.Url
                $lists = $subsite.lists
                #Get the list
                foreach ($List in $changeLists)
                {
                    $curlist = $subsite.Lists.GetByTitle($List)
                    ##Check if the Field exist in list already
                    $Context.Load($curlist)
                    $Fields = $curlist.Fields
                    $Context.Load($Fields)
                    $Context.ExecuteQuery()
                    #output current list name. If you do not need this, comment the "$Context.Load($curlist)" line also to remove overhead.
                    write-host -f DarkGreen list is $curlist.Title
                    if ($field.Title -ne $SiteColumnName1)
                    {
                              
                        #Add the site column to the list
                        $NewColumn1 = $curlist.Fields.Add($SiteColumn1)
                        #Remove the site column from the list (uncomment next two lines)
                        #$DelColumn1 = $curlist.Fields.GetByTitle($SiteColumnname1)
                        #$DelColumn1.DeleteObject()
                        try
                        {
                            $Context.ExecuteQuery()
                            Write-host "List Successfully modified for Site Column!" -f Green
                            $views = $curlist.Views
                            $Context.Load($Views)
                            $Context.ExecuteQuery()
                            foreach ($view in $views) {
                                $Context.Load($view)
                                $Context.ExecuteQuery()
                                foreach ($v in $view){
                                    if ($v.title -eq "$Viewname"){
                                        #Add the site column to the view
                                        $v.ViewFields.Add($Sitecolumnname1)
                                        #Remove the site column from the view. Do not use if deleting column above as it does this at the same time.
                                        #$view2.ViewFields.Remove($Sitecolumnname1)
                                        try
                                        {
                                            $v.Update();
                                            write-host -f Green "Default View Successfully modified for Site Column!"
                                        }
                                        catch
                                        {
                                            write-host -f red $_.Exception.Message
                                        }
                                    }
                                }
                            }
                        }
                        catch
                        {
                            write-host -f red $_.Exception.Message
                        }
                                   
                        }
                    }
                }
            }
        #}
    #}
    #Catch {
        #write-host -ForegroundColor Red "Error modifying list for Site Column!" $_.Exception.Message
    #}