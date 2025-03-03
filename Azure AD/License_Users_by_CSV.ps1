#
# License_Users_by_CSV.ps1
#
#script to license users by CSV. First checks if the user exists AND is an unlicensed User type mailbox (exclused mailboxes marked as resource [RoomMailbox] or shared [SharedMailbox])
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
connect-msolservice -credential $credentials
$msolaccount = Get-MsolAccountSku | out-gridview -PassThru
$AccountSKU = $msolaccount.AccountSkuId 
$folder = "c:\temp"
$csvname = Read-Host -Prompt "Enter the CSV filename excluding extension"
$csvfile = $folder+"\"+$csvname+".csv"
$FileExists = Test-Path $csvfile
$count = 0
if ($FileExists -eq $True)
{
    $users = Import-Csv $csvfile
    Foreach ($user in $users)
    {
        $userdet = get-msoluser -UserPrincipalName $user.UserPrincipalName
        if ($User.RecipientTypeDetails -eq "UserMailbox" -AND $userdet.islicensed -eq $false)
        {
            #write-host $user.emailaddress address is an unlicensed user mailbox
            write-host =============================================================
            write-host Licensing $user.emailaddress
    	    set-msoluser -UserPrincipalName $user.emailaddress -usagelocation AU
    	    Set-MsolUserLicense -UserPrincipalName $user.emailaddress -AddLicenses $AccountSKU
        $count ++
        }
    }
}
else
{
    write-host filename incorrect. Try again you derp
}
$count