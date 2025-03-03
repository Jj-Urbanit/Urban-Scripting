#
# new-sporesources-CSV.ps1
#
#used to create site collections using the modern team site template, sites/subsites and document libraries, and folders within document libraries based on input from a CSV.
#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
#variables that needs to be set before starting the script
$siteURL = "https://primarycommunitycare.sharepoint.com"
$adminUrl = "https://primarycommunitycare-admin.sharepoint.com"
#$userName = "tmladmin@PrimaryCommunityCare.onmicrosoft.com"
$csvpath = read-host -Prompt "enter full path to CSV"
$logfile = "c:\temp\structure.log"
$csv = import-csv -path $csvpath
$credentials = get-credential -
#$password = Read-Host "Please enter the password for $($userName)" -AsSecureString
#below currently doesn't work with gather method
#$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($credentials)
# Creating client context object
foreach ($line in $csv)
{    
    if ($line.type -eq "sitecoll")
    {
		connect-sposervice -url $adminUrl -Credential $credentials
		$sitecollname = $line.name
		try
		{
			new-sposite -url $line.host -title $line.name -owner $userName -nowait -template STS#3 -storagequota 300
			$result = Write-Host "Info: Created Site collection $($sitecollname)" -foregroundcolor Blue
			$result | Out-File -FilePath $logfile -Append
		}
		catch
		{
			Write-host "Info: Failed to Create Site collection $($sitecollname)" -foregroundcolor Red
		}
	}
	if ($line.type -eq "site")
    {
        #Setup the context
        $hosturl = $line.host
		$Context = New-Object Microsoft.SharePoint.Client.ClientContext($hosturl)
        #testing. old is spocredentials, new is credentials
        #$Context.Credentials = $spoCredentials
        $Context.Credentials = $Credentials
 
        #Specify Subsite details
		$WebCI = New-Object Microsoft.SharePoint.Client.WebCreationInformation
        $WebCI.Title = $line.name
        $WebCI.WebTemplate = "STS#3"
        $WebCI.Url = $line.Url
        $SubWeb = $Context.Web.Webs.Add($WebCI)
        $Context.ExecuteQuery()
		$result = Write-Host "Info: Created Site $($sitename)" -foregroundcolor Blue
		$result | Out-File -FilePath $logfile -Append
    }
    if ($line.type -eq "library")
    {
        $listTitle = $line.name
        $listTemplate = 101
        $hosturl = $line.host
        $context = New-Object Microsoft.SharePoint.Client.ClientContext($hostURL)
        $context.credentials = $SPOCredentials
        #create list using ListCreationInformation object (lci)
        $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $lci.title = $listTitle
        $lci.TemplateType = $listTemplate
        $list = $context.web.lists.add($lci)
        $context.load($list)
        $context.executeQuery()
        write-host "info: Created $($listTitle)" -foregroundcolor green
        $context = New-Object Microsoft.SharePoint.Client.ClientContext($hostURL)
        $context.credentials = $SPOCredentials
        $web = $context.Web
        $navColl = $web.Navigation.QuickLaunch
        $newNavNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
        $newNavNode.Title = $listTitle
        $newNavNode.Url = $hostUrl +"/" + "$listtitle" + "/Forms/AllItems.aspx"
        $newNavNode.AsLastNode = $true
        $context.Load($navColl.Add($newNavNode))
        $result = write-host "info: Library $($listTitle) added to quick launch" -ForegroundColor DarkYellow
		$result | Out-File -FilePath $logfile -Append
        $context.executeQuery()
    }
	if ($line.type -eq "folder")
	{
		$hosturl = $line.host
		$context = New-Object Microsoft.SharePoint.Client.ClientContext($hostURL)
		$context.credentials = $SPOCredentials
		$web = $context.Web;
		$context.Load($web)
        $foldername = $line.name
        $libname = $line.libname
		$folder = $web.Folders.Add($libname + '\'+ $line.Name)
		#$context.Load($folder1)
		$context.ExecuteQuery()
        $result = write-host "info: Folder $($foldername) created in library $($libname)" -ForegroundColor Red
		$result | Out-File -FilePath $logfile -Append
        
	}
}