#
# New_SPOLib_CSV.ps1
#
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$listTemplate = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary
$spWeb = Get-SPWeb -Identity http://sp.contoso.int/sites/family
$data = Import-Csv "C:\TEMP\DLs.csv"

 foreach($row in $data)
 {
 $spWeb.Lists.Add($row.DocLibs,"",$listTemplate)
 $docLib = $spWeb.Lists[$row.DocLibs]
 $docLib.OnQuickLaunch = $true
 $docLib.EnableVersioning = $true
 $docLib.Update()
 Write-Host Created document library $row.DocLibs.
 }


    #variables that needs to be set before starting the script
    $siteURL = "https://spfire.sharepoint.com/sites/BlogDemo"
    $adminUrl = "https://primarycommunitycare-admin.sharepoint.com"
    $userName = "mpadmin@spfire.onmicrosoft.com"
    $listTitle = "Finance"
    $listDescription = "Finance documents"
    $listTemplate = 101
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
     
    #create list using ListCreationInformation object (lci)
	$lci.url=$row.url
    $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
    $lci.title = $row.Title
    $lci.TemplateType = $listTemplate
    $list = $context.web.lists.add($lci)
    $context.load($list)
    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Created $($listTitle)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    }  