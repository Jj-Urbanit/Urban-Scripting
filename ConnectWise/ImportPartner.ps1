###############################################################################################
################## This script imports client data from cw-partners.csv #######################
################## into the missing link site column "Partner Name".    #######################
################## It requires the cw-partners.csv and                  #######################
################## SiteCollectionList.txt files mentioned in the path below. ##################
###############################################################################################

$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
$username = "cw_export@themissinglink.onmicrosoft.com" 
$password = "" 
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force 
$logpath = "D:\CW-Export-logs\Import-Partners.log"

####### CHANGE PATH BELOW ############### 
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"

try
{
	####### CHANGE PATH BELOW ###############
	$importCSV = "D:\CW-Export\cw-partners.csv" 
	$FileExists = Test-Path $importCSV
    if ($FileExists -eq $True)
    {if((Get-Item $importCSV).length -gt 0kb)
	{
		$exportedPartner = Import-CSV $importCSV 
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
				$ctx.Credentials = $SPOCredentials 
				$rootWeb = $ctx.Web  
				$ctx.Load($rootWeb) 
				$ctx.ExecuteQuery()

				$contentTypes = $rootWeb.ContentTypes
				$ctx.Load($contentTypes)
				$ctx.ExecuteQuery() 
				$fieldTitle = "Partner_x0020_Name"
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
				       				$contentTypes[$i].Fields[$j].Choices.Clear()
	   								$contentTypes[$i].Fields[$j].Update()
	  								$ctx.Load($contentTypes[$i].Fields[$j])
									$ctx.ExecuteQuery()
	   								$contentTypes[$i].Fields[$j].Choices = $exportedPartner.Company_Name
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
		remove-item -path $importCSV
        $Time = Get-Date
        "$time - $importCSV SUCCESSFULLY imported " | out-file $logpath -Append
	}
else {
    $Time = Get-Date
    "$time - $importCSV file at 0KB, unable to import" | out-file $logpath -Append
    }
}
else {
    $Time = Get-Date
    "$time - $importCSV file missing, unable to import" | out-file $logpath -Append
    }}
catch
{
	$ErrorMessage = $_.Exception.Message
	$Time = Get-Date
	####### CHANGE PATH BELOW ###############
 	"$Time - An error occurred while importing partner data: $ErrorMessage" | out-file $logpath -Append
}