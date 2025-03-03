<#
.Synopsis
    Connect to 365 via PowerShell
.DESCRIPTION
    This module is used for easy access to 365 and Azure AD online.
.EXAMPLE
    Open PowerShell and type C:\connect-365.ps1
.EXAMPLE
    Another Example of how to use the cmdlet
#>

#Script Name: Connect-365
#Creator: Josh
#Date: 14/02/2019
#Updated
#References, if any

#Variables

#Parameters

#Enter Taska Below as Remarks
Function Connect-365{

$UserCredential = Get-Credential

function Show-Menu
{
    param (
        [string]$Title = '365 Options'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Connect to Exchange Online."
    Write-Host "2: Press '2' for Connect to Azure AD."
    Write-Host "Q: Press 'Q' to quit."
}

Show-Menu –Title '365 Options'
 $selection = Read-Host "Please make a selection"
 switch ($selection)
 {
     '1' {
     'Connecting to Exchange Online'
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -DisableNameChecking
     } '2' {
     'Connecting to Azure AD'
    Connect-AzureAD -Credential $UserCredential
     } 'q' {
         return
     }
 }
 }