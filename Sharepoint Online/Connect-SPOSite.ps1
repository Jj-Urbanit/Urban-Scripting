﻿Install-Module -Name Microsoft.Online.SharePoint.PowerShell 
Import-Module Microsoft.Online.SharePoint.Powershell 
Connect-SPOService -Url htttps://<OrganizationName>-admin.sharepoint.com  


function global:Connect-SPOSite {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $Url
    )

    begin {
        [System.Reflection.Assembly]::LoadFile("C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.dll") | Out-Null
        [System.Reflection.Assembly]::LoadFile("C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.SharePoint.Client.Runtime.dll") | Out-Null
    }
    process {
        if ($global:spoCred -eq $null) {
            $cred = Get-Credential -Message "Enter your credentials for SharePoint Online:"
            $global:spoCred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.UserName, $cred.Password)
        }
        $ctx = New-Object Microsoft.SharePoint.Client.ClientContext $Url
        $ctx.Credentials = $spoCred

        if (!$ctx.ServerObjectIsNull.Value) { 
            Write-Host "Connected to site: '$Url'" -ForegroundColor Green
        }
        return $ctx
    }
    end {
    }
}