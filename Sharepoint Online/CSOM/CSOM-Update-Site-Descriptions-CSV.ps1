 param(
  [string]
  $csvName
  
) 
# ---------------------------------------------------------
# Load SharePoint 2013 CSOM  libraries.
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$UserName = "cturner_admin@themissinglink.com.au"
$Password = "S3cur32018"
$csvName = "clients.csv"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)

$csvFilePath = Join-Path -Path $scriptPath -ChildPath $csvName
if (Test-Path "$csvFilePath")

{
	$context = New-Object Microsoft.SharePoint.Client.ClientContext("https://themissinglink.sharepoint.com/sites/client")
	$context.Credentials = $SPOCredentials 
	$web = $context.Web
	$context.Load($web)
	$context.Load($web.Webs)
	$context.ExecuteQuery()
		
	#  Step  2.  collect the rows for the list
	Write-Host "Importing CSV data from $csvFilePath"
	$listItems = import-csv -Path "$csvFilePath"
	$recordCount = @($listItems).count;
	Write-Host -ForegroundColor Yellow "There are $recordCount list items to process"
	Write-Host "Please wait..."
	
	#  Step  3.  Add the list items
	for($rowCounter = 0; $rowCounter -le $recordCount - 1; $rowCounter++)
	
		
	{ 
		$curItem = @($listItems)[$rowCounter];
	    Write-Progress -id 1 -activity "Updating client" -status "client $rowCounter of $recordCount list items." -percentComplete ($rowCounter*(100/$recordCount));
		$context = New-Object Microsoft.SharePoint.Client.ClientContext($curitem.URL)  
		$context.Credentials = $SPOCredentials 
		$web = $context.Web
		$context.Load($web)
		$web.Description = $curitem.Description
		$web.Update()
 		$context.ExecuteQuery()
 		write-host --------------------------------------------------------------
		write-host --------------------------------------------------------------
		Write-Host Current Title is $curItem.Title
		Write-Host Current URL is $curItem.URL
		Write-Host Current Description is $curItem.Description
		$curItem = @($listItems)[$rowCounter]
	}
}
else
{
	$listItems
}