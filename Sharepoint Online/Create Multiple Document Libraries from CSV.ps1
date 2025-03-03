function new-SPOnlineList {
    #variables that needs to be set before starting the script.
	#List template 101 is for a Document Library. Other templates can be used. 
    $siteURL = "https://themissinglink.sharepoint.com/sites/Docshare"
    $adminUrl = "https://themissinglink-admin.sharepoint.com"
    $userName = "**************"
    $listDescription = "*************"
    $listTemplate = 101
     
    # Let the user fill in their password in the PowerShell window
    $password = Read-Host "Please enter the password for $($userName)" -AsSecureString
     
    # set SharePoint Online credentials
    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $password)
         
    # Creating client context object
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    $context.credentials = $SPOCredentials
    
    #import CSV file
    $sites = Import-Csv "C:\Temp\Client_List.csv"

    foreach($row in $sites){

    #create list using ListCreationInformation object (lci)
    $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
    $lci.title = $row.title
    $lci.description = $listDescription
    $lci.TemplateType = $listTemplate
    $list = $context.web.lists.add($lci)
    $context.load($list)

    #send the request containing all operations to the server
    try{
        $context.executeQuery()
        write-host "info: Created $($row.title)" -foregroundcolor green
    }
    catch{
        write-host "info: $($_.Exception.Message)" -foregroundcolor red
    } 
    }
}
new-SPOnlineList