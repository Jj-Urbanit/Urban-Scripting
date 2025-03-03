########################
# Creates the List to be used to host client list and pre-fills it based on CSV
########################
#Specify tenant admin and site URL
$User = "CTURNER_ADMIN@themissinglink.com.au"
$ListTitle = "List of Clients"



#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
#$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
   
#Bind to site collection
write-host $SiteURL
$Context = New-Object Microsoft.SharePoint.Client.ClientContext("https://themissinglink.sharepoint.com/sites/client")
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds
   
#Retrieve lists
$Lists = $Context.Web.Lists
$Context.Load($Lists)
$Context.ExecuteQuery()
   
#Create list with "custom" list template
$ListInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListInfo.Title = $ListTitle
$ListInfo.TemplateType = "100"
$List = $Context.Web.Lists.Add($ListInfo)
$List.Description = $ListTitle
$List.Update()
$Context.ExecuteQuery()
   
#create Client column and make mandatory
$List.Fields.AddFieldAsXml("<Field Type='Text' DisplayName='Client' Required='TRUE'/>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
$List.Update()
#create AE column and make optional
$List.Fields.AddFieldAsXml("<Field Type='Text' DisplayName='AccountExecutive'/>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
$List.Update()
$Context.ExecuteQuery()
#Hiding the default Title Column
#Get list and Title column
$titleColumn = $List.fields.GetByTitle('Title')

#Set Title to optional and hidden
$titleColumn.Required = $false
$titleColumn.Hidden = $true

#Update Title column and list
$titleColumn.Update()
$List.Update()
$Context.ExecuteQuery()


#$CSV = Import-CSV "D:\CW-Export\cw-clients.csv"
#foreach ($row in $csv) {
    ##Adds an item to the list
    #$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
    #$Item = $List.AddItem($ListItemInfo)
    #$Item["Client"] = $row.Company_Name
    #$Item["AccountExecutive"] = $row.Owner_Level_Name
    #$Item.Update()
    #$Context.ExecuteQuery()
#}