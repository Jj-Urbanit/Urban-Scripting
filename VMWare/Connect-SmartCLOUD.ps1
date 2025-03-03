Function Initiate-PowerCLI 
{
    .$("C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1")
}
function Connect-SmartCLOUD 
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet(
            'TenantSydney', 
            'InfrastructureSydney',
            'InfrastructureMelbourne',
            'TenantMelbourne'
        )]
        $vCenterServer
    )
    switch ($vCenterServer) {
        TenantSydney {
            Initiate-PowerCLI
            Connect-VIServer -Server svsy3005024.cloud.themissinglink.com.au -Credential $(Get-Credential)
        }
        InfrastructureSydney {
            Initiate-PowerCLI
            Connect-VIServer -Server svsy3005017.cloud.themissinglink.com.au -Credential $(Get-Credential)
        }
        InfrastructureMelbourne {
            Initiate-PowerCLI
            Connect-VIServer -Server svme1mgmt004.cloud.themissinglink.com.au -Credential $(Get-Credential)
        }
        TenantMelbourne {
            Initiate-PowerCLI
            Connect-VIServer -Server svme1mgmt006.cloud.themissinglink.com.au -Credential $(Get-Credential)
        }
    }
}