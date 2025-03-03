#
# enable_spofeature.ps1
#
############################################################################################################################################ 
#Script that enables a feature in a SPO Site 
# Required Parameters: 
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection. 
#  -> $sPassword: Password for the user. 
#  -> $sSiteColUrl: SharePoint Online Site Collection 
#  -> $sFeatureGuid: GUID of the feature to be enabled 
############################################################################################################################################ 
 
$host.Runspace.ThreadOptions = "ReuseThread" 
 
#Definition of the function that allows to enable a SPO Feature 
function Enable-SPOFeature 
{ 
    param ($sSiteColUrl,$sUserName,$sPassword,$sFeatureGuid) 
    try 
    {     
        #Adding the Client OM Assemblies         
        Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll"
 
        #SPO Client Object Model Context 
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl)  
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)   
        $spoCtx.Credentials = $spoCredentials       
 
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green 
        Write-Host "Enabling the Feature with GUID $sFeatureGuid !!" -ForegroundColor Green 
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green 
 
        $guiFeatureGuid = [System.Guid] $sFeatureGuid 
        $spoSite=$spoCtx.Site 
        $spoSite.Features.Add($sFeatureGuid, $true, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None) 
        $spoCtx.ExecuteQuery() 
        $spoCtx.Dispose() 
    } 
    catch [System.Exception] 
    { 
        write-host -f red $_.Exception.ToString()    
    }     
} 
 
#Required Parameters 
$sSiteColUrl = "https://primarycommunitycare.sharepoint.com/sites/services" 
$sUserName = "tmladmin@PrimaryCommunityCare.onmicrosoft.com"  
$sFeatureGuid= "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString   
#$sPassword=convertto-securestring "[password]" -asplaintext -force 
 
Enable-SPOFeature -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sFeatureGuid $sFeatureGuid

