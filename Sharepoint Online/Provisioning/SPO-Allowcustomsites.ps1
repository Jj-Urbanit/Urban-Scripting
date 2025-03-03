#
# SPO_Allowcustomsites.ps1
#
# Use this to update custom pages, i.e. managed natviation using term sets. Do not need to wait 24 hours. Run per SITE, not subsite
$adminUPN="tmladmin@PrimaryCommunityCare.onmicrosoft.com"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url https://primarycommunitycare-admin.sharepoint.com -Credential $userCredential
Set-SPOsite https://primarycommunitycare.sharepoint.com -DenyAddAndCustomizePages 0
