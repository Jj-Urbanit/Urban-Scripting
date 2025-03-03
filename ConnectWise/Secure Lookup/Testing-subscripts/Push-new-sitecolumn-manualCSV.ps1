#
# Push_new_sitecolumn_manualCSV.ps1
#
# Update_All_listitems_Client.ps1
#
###################################
# Used to update all list items in all client sites with their respective client name from Lookup Field
###################################
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")


Function Get-SPOContext([string]$Url,[string]$UserName,[string]$Password)
{
    #$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
    return $context
}

Function Get-ListItems([Microsoft.SharePoint.Client.ClientContext]$Context, [String]$ListTitle) {
    $list = $Context.Web.Lists.GetByTitle($listTitle)
    $qry = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
    $items = $list.GetItems($qry)
    $Context.Load($items)
    $Context.ExecuteQuery()
    return $items 
}

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

#Set variables for list comparison
#Variables for Processing


$importCSV = 'C:\CW-Export\2ndmanualclients.csv'
$CSV = Import-CSV $importCSV


$Time = Get-Date
$faillog = "C:\CW-Export\failed.txt"
$changelog = "C:\CW-Export\changed.txt"
$SiteUrl = "https://themissinglink.sharepoint.com/sites/client"
$ListName="List of Clients"
 
$UserName="cturner_admin@themissinglink.com.au"
#$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$SecurePassword = $Password
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,$Password)
   
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext("$SiteUrl")
$Context.Credentials = $Creds

$List = $Context.web.Lists.GetByTitle($ListName)
$ListItems = $List.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()) 
$Context.Load($ListItems)
$Context.ExecuteQuery()
$context.load($list)
$context.ExecuteQuery()
$fields = $list.Fields
$context.load($fields)
$context.ExecuteQuery()
$field = $List.fields.getbyinternalnameortitle("Client")
$field2 = $List.fields.getbyinternalnameortitle("AccountExecutive")
$context.load($field)
$context.load($field2)
$context.ExecuteQuery()
#$rightfields = $List.Fields | select

#populate client list of existing subsites
#$AllWebs = Get-SPOWebs -Url 'https://themissinglink.sharepoint.com/sites/client' -Credential $Creds |select title,url 

$Output= @()
            
foreach ($listitem in $ListItems)
{
    $listarray = [PSCustomObject]@{
    Client=$listitem.fieldvalues.Client
    AccountExecutive=$listitem.fieldvalues.AccountExecutive
    LineID=$listitem.ID
}
  #Add data to array
  $Output += $listarray 
}


# Set variables for site and list parsing
#$Url = "https://themissinglink.sharepoint.com/sites/client/ct-test/"
$clients = "https://themissinglink.sharepoint.com/sites/client/"
$lists = "Documentation","Agreements","Projects","Quotes & Proposals"
$missingclients = @()
foreach ($row in $CSV)
{
    $url = $row.url
    $Output | where {$_.client -eq $row.spclient} | % {
            $curid = $_.LineID
            #write-host $Output.Client
            #write-host $Output.LineID
            foreach ($clientlist in $lists)
            {
                $context = Get-SPOContext -Url $Url -UserName $UserName -Password $SecurePassword
                $items = Get-ListItems -Context $context -ListTitle $clientlist 
                write-host ========================
                write-host $_.client
                write-host $curID
                #Write-Host $Url
                write-host $clientlist
                foreach ($item in $items)
                {
                    #write-host ===================================
                    #write-host $item.FieldValues.FileLeafRef
                    #write-host $item.FieldValues.Client.LookupValue
                    #write-host $item.FieldValues.Client.LookupId
                    $item["Client"] = $curid
                    $item.Update()
                    $context.ExecuteQuery()
                }    
            }
        }
}