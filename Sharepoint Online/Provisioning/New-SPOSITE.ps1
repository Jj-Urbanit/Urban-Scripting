#
# New_SPOSITE.ps1
#
# Used to recreate a site that was used previously as an Gffice 365 Group, as a modern team site, not connected to an Office 365 Group (STS#3)
connect-sposervice -url https://primarycommunitycare-admin.sharepoint.com -
#remove-spodeletedsite -identity https://primarycommunitycare.sharepoint.com/sites/quality
new-sposite -url https://primarycommunitycare.sharepoint.com/sites/services -title Services -owner tmladmin@PrimaryCommunityCare.onmicrosoft.com -nowait -template STS#3 -storagequota 300