#
# License_Users_by_Batch.ps1
#
#outputs all completed batches and licenses all users within
#AccountSkuId                  ActiveUnits WarningUnits ConsumedUnits
#-----------                  ----------- ------------ -------------
#ppg4:O365_BUSINESS_ESSENTIALS 2           0            1            
#ppg4:RIGHTSMANAGEMENT_ADHOC   50000       0            1            
#ppg4:STANDARDPACK             510         0            11           
#ppg4:ENTERPRISEPACK           10          0            0            
#ppg4:POWER_BI_STANDARD        1000000     0            1            
$credentials = get-credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credentials -Authentication Basic -AllowRedirection
Import-PSSession $Session
#connect-msolservice -credential $credentials
$msolaccount = Get-MsolAccountSku | out-gridview -PassThru
$AccountSKU = $msolaccount.AccountSkuId 
$freelicenses = $msolaccount.activeunits - $msolaccount.consumedunits
Get-MigrationBatch -status Completed
$batch = read-host -Prompt "enter batch to license"
$count = 0
$users = get-migrationuser -batchid $batch
$userbatchcount = ($users).count
if ($userbatchcount -gt $freelicenses)
{
	Write-Host You dont have enough licenses. You need $userbatchcount but only have $freelicenses
	break
}
Foreach ($user in $users)
{
    $userdet = get-msoluser -UserPrincipalName $user.UserPrincipalName
    if ($User.RecipientTypeDetails -eq "UserMailbox" -AND $userdet.islicensed -eq $false)
    {
        #write-host $user.emailaddress address is an unlicensed user mailbox
        write-host =============================================================
        write-host Licensing $user.emailaddress
    	#set-msoluser -UserPrincipalName $user.emailaddress -usagelocation AU
    	#Set-MsolUserLicense -UserPrincipalName $user.emailaddress -AddLicenses $AccountSKU
    $count ++
    }
}
$count