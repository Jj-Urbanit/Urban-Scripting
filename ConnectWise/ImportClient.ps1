###############################################################################################
################## This script imports client data from cw-clients.csv  #######################
################## into the missing link site column "Client Name".     #######################
################## It requires the cw-clients.csv and                   #######################
################## SiteCollectionList.txt files mentioned in the path below. ##################
###############################################################################################

$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$username = "cw_export@themissinglink.onmicrosoft.com" 
$password = "%d1ZM0#h9V8eiirC" 
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force 
$logpath = "D:\CW-Export-logs\Import-Clients.log"

####### CHANGE PATH BELOW ############### 
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"

try
{
	####### CHANGE PATH BELOW ###############
	$importCSV = "D:\CW-Export\cw-clients.csv"
	$FileExists = Test-Path $importCSV 
	if ($FileExists -eq $True) 
	{
		$exportedClient = Import-CSV $importCSV 
		$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword)
		####### CHANGE PATH BELOW ###############
		$siteCollectionFile = "D:\CW-Export\SiteCollectionList.txt"
		$siteColFileExists = Test-Path $siteCollectionFile 
		if ($siteColFileExists -eq $True)
		{
			$siteCollections = Get-Content $siteCollectionFile
			foreach ($siteCollection in $siteCollections)
			{
				$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteCollection)
                $ctX.RequestTimeOut = 5000*10000
				$ctx.Credentials = $SPOCredentials 
				$rootWeb = $ctx.Web  
				$ctx.Load($rootWeb) 
				$ctx.ExecuteQuery()

				$contentTypes = $rootWeb.ContentTypes
				$ctx.Load($contentTypes)
				$ctx.ExecuteQuery() 
				$fieldTitle = "Client_x0020_Name"
				$fieldColl = $rootWeb.Fields
				$ctx.Load($fieldColl)
				$ctx.ExecuteQuery() 

				foreach($field in $fieldColl)
				{
					if ($field.InternalName -eq $fieldTitle)
					{
						$ctx.Load($field)
						$ctx.ExecuteQuery()
						$guid = $field.id
					
						for ($i=0; $i -lt $contentTypes.Count; $i++) 
						{
							$ctx.Load($contentTypes[$i].Fields)
							$ctx.ExecuteQuery()
							for ($j=0; $j -lt $contentTypes[$i].Fields.Count; $j++)
  							{
								#$ctx.Load($contentTypes[$i].Fields[$j])
								#$ctx.ExecuteQuery()
								if ($contentTypes[$i].Fields[$j].id -eq $guid)
       							{
				       				#$contentTypes[$i].Fields[$j].Choices.Clear()
	   								#$contentTypes[$i].Fields[$j].Update()
	  								$ctx.Load($contentTypes[$i].Fields[$j])
									$ctx.ExecuteQuery()
	   								$contentTypes[$i].Fields[$j].Choices = $exportedClient.Company_Name
	   								$contentTypes[$i].Fields[$j].UpdateAndPushChanges($True)
									$ctx.Load($contentTypes[$i].Fields[$j])
									$ctx.ExecuteQuery()
       							}
  							}
						}
					}
				}
			}
		}
		#Remove the csv file
		#remove-item -path $importCSV
	}
}
catch
{
	$ErrorMessage = $_.Exception.Message
	$Time = Get-Date
	####### CHANGE PATH BELOW ###############
    "$Time - An error occurred while importing client data: $ErrorMessage" | out-file $logpath -Append
}