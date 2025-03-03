#
# Update_Client_List_comparison.ps1
#
############################
# Matches client list in SharePoint with CSV and adds missing items to list
############################
#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
   
#Variables for Processing
$importCSV = "D:\CW-Export\cw-clients.csv"
$Time = Get-Date
$logfilename = get-date -format MMM-yyyy
$logfile = "D:\CW-Export\"+$logfilename+".txt"
$SiteUrl = "https://themissinglink.sharepoint.com/sites/client"
$ListName="List of Clients"
 
$UserName="cw_export@themissinglink.onmicrosoft.com"
$password = Get-Content -path "D:\CW-Export\Encrypted-ExportPW.txt" | ConvertTo-SecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,$Password)
   
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext("https://themissinglink.sharepoint.com/sites/client")
$Context.Credentials = $Creds


#Populate all lists to find specified list above
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
$context.load($field)
$context.ExecuteQuery()
#create array to hold SharePoint values
$allvalues = New-Object System.Collections.ArrayList
#set missing clients counter to zero
$missingclients = 0
try{
	$currentstep = "TestCSV"
    $FileExists = Test-Path $importCSV

	if ($FileExists -eq $True) 
	{
    	$currentstep = "ImportCSV"
        $CSV = Import-CSV $importCSV
        $currentstep = "Parse Listitems"
        foreach ($listitem in $ListItems)
		{
			#Add all existing Sharepoint list items to a variable without terminal output
			$currentstep = "getfields"
            $allvalues.Add($listitem.fieldvalues.Client) | Out-Null
		}
    
			foreach ($row in $CSV)
			{
    		#check if SharePoint list items contains the current row in CSV
			$currentstep = "checkallvalues"
            if ($allvalues -notcontains $row.company_name)
				{
					$currentstep = "dochanges"
                    #write-host -ForegroundColor Red $row.company_name not found in Sharepoint
					$clientmissing = $row.Company_Name
					"$Time --- $clientmissing ---- was not found in SharePoint. Adding..." | Out-File -Filepath $logfile -Append
					$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
					$Item = $List.AddItem($ListItemInfo)
					$Item["Client"] = $row.Company_Name
					$Item["AccountExecutive"] = $row.Owner_Level_Name
					$Item.Update()
					$Context.ExecuteQuery()
					$missingclients ++
				}
			    #else
				#{
					#write-host -ForegroundColor Green $row.company_name found in SharePoint
				#}
			} 
			"$Time --- added $missingclients clients to SharePoint" | Out-File -Filepath $logfile -append
			#Remove the csv file
			remove-item -path $importCSV
		}
	else
    {
        "$Time - == FAILED == Connectwise Client Import Process Failed" | Out-File -Filepath $logfile -append
        Send-MailMessage -SmtpServer mail.themissinglink.com.au -Attachments $logfile -Subject "Error Import CSV file missing" -To cturner@themissinglink.com.au -From cturner@themissinglink.com.au -Body $ErrorMessage
    }
}

catch
{
	$ErrorMessage = $_.Exception.Message
	"$Time - An error occurred while importing client data on step $currentstep : $ErrorMessage" | Out-File -Filepath $logfile -append
    Send-MailMessage -SmtpServer mail.themissinglink.com.au -Attachments $logfile -Subject "Connectwise Client Import Process Failed" -To cturner@themissinglink.com.au -From cturner@themissinglink.com.au -Body $ErrorMessage
}