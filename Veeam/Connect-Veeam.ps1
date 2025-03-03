# TML PRIVATE
function Connect-Veeam 
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet("TML-SmartCLOUD", "TML-Internal")]
        $vCenterServer
    )
    switch ($vCenterServer) 
    {
        TML-SmartCLOUD 
        {
            Enter-PSSession -ComputerName svsy1mgmt013.cloud.themissinglink.com.au -Credential $(Get-Credential) -Verbose
            Write-Warning "Add-PSSnapin VeeamPSSnapin"
        }
        TML-Internal 
        {
            Enter-PSSession -ComputerName TML-VEEA-01.themissinglink.com.au -Credential $(Get-Credential) -Verbose
            Write-Warning "Add-PSSnapin VeeamPSSnapin"
        }
    }
}