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

#Set variables for list comparison
#Variables for Processing
$importCSV = 'D:\CW-Export\cw-clients - Copy.csv'
$CSV = Import-CSV $importCSV
$Time = Get-Date
$logfile = "D:\CW-Export\logging.txt"
$SiteUrl = "https://themissinglink.sharepoint.com/sites/client"
$ListName="List of Clients"
 
$UserName="cturner_admin@themissinglink.com.au"
#$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
#$SecurePassword = $Password
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
$clients = "https://themissinglink.sharepoint.com/sites/client/TheMissingLink"
#$lists = "Agreements","Documentation"
$lists = "Quotes & Proposals"
foreach ($row in $CSV)
{
    $url = $row.url
    $Output | where { $_.Client -eq $row.company_name} | % {
            $curid = $_.LineID
            write-host $_.Client
            write-host $_.LineID
            foreach ($clientlist in $lists)
            {
                $context = Get-SPOContext -Url $Url -UserName $UserName -Password $SecurePassword
                $items = Get-ListItems -Context $context -ListTitle $clientlist 
                write-host ========================
                write-host $curID
                Write-Host $Url
                write-host $clientlist
                foreach ($item in $items)
                {
                    write-host ===================================
                    write-host $item.FieldValues.FileLeafRef
                    write-host $item.FieldValues.Client.LookupValue
                    write-host $item.FieldValues.Client.LookupId
                    #$item["Client"] = $curid
                    #$item.Update()
                    #$context.ExecuteQuery()
                }    
            }
        }
	else
	{
		Write-Host $row.Company_Name not found
	}
}