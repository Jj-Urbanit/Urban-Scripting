$PF = Get-PublicFolder -Identity "\dictation" -recurse
foreach ($PFM in $PF)

{
remove-PublicFolderClientPermission -Identity $PFM.identity -User Anonymous -confirm:$false
Add-PublicFolderClientPermission -identity $PFM.identity -User Anonymous -AccessRights Contributor -confirm:$false
}