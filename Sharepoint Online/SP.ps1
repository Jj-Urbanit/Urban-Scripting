Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"   
Add-Type -Path "c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll" 
#Enter the data 
$AdminPassword=Read-Host -Prompt "Enter your password" -AsSecureString 
$username="aplatanisiotis_admin@themissinglink.com.au" 
$Url="https://themissinglink.sharepoint.com/sites/client/themissinglink" 
$ListTitle="Documents" 
$userLoginName="aplatanisiotis_admin@themissinglink.com.au"

<#
    Connect-SPOCSOM -Username aplatanisiotis@themissinglink.onmicrosoft.com -Url https://themissinglink.sharepoint.com/sites/client
    $lists=(Get-SPOList -IncludeAllProperties | where {$_.BaseTemplate -eq 101}).Title
    $emptyitems=@()
    foreach($list in $listOfLists){$emptyitems+=((Get-SPOListItems $list -IncludeAllProperties $true -Recursive | where {$_.FSObjType -eq 0}).FileRef)}
    $files=@()
    for($i=0;$i -lt $emptyitems.Count; $i++){$files+=(Get-SPOFileByServerRelativeUrl -ServerRelativeUrl $emptyitems[$i])}
    foreach($file in $files){ if($file.CheckedOutByUser.LoginName -ne $null) {$file.ServerRelativeUrl}}
#>