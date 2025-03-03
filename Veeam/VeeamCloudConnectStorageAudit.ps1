Add-PSSnapin VeeamPSSnapIn
$VeeamTenantInfo = @()

    foreach($VBRCloudTenant in (Get-VBRCloudTenant | Sort-Object Name)){
        
        $RepositoryQuota = $([math]::Truncate($VBRCloudTenant.Resources.RepositoryQuota / 1024))
        $UsedSpace = $([math]::Truncate($VBRCloudTenant.Resources.UsedSpace / 1024))
        $UsedSpacePercentage = $VBRCloudTenant.Resources.UsedSpacePercentage
        $Repository = $VBRCloudTenant.Resources.Repository.name
        $Leaseperiod = $VBRCloudTenant.LeaseExpirationDate


        if($Repository -eq $null -and $VBRCloudTenant.ReplicaCount -ne 0){
            $UsedSpace = 0
            $Repository = 0
            $RepositoryQuota = 0
            $UsedSpacePercentage = 0
            $Repository = "n.a."
        }
        
        if($Leaseperiod -eq $null){
            $Leaseperiod = "n.a."
        }

        $VeeamTenantInfo += New-Object PSObject -Property ([ordered]@{
            User = $VBRCloudTenant.Name
            Enabled = $VBRCloudTenant.Enabled
            VMCount = $VBRCloudTenant.VMCount
            ReplicaCount = $VBRCloudTenant.ReplicaCount
            RepositoryQuota = $RepositoryQuota
            UsedSpace = $UsedSpace
            UsedSpacePercentage = $UsedSpacePercentage
            Repository = $Repository 
            LeaseExpirationEnabled = $VBRCloudTenant.LeaseExpirationEnabled
            LeaseExpirationDate = $Leaseperiod
        })
    }


$html = "<html><body><h1>Veeam Cloud Connect</h1><table border=1 cellspacing=0 cellpadding=3>"
$html += "<html><body><h2>Cloud Connect Server: $((hostname).ToUpper())</h2><table border=1 cellspacing=0 cellpadding=3>"
$html += "<html><body><h3>Usage report generated on $(Get-Date -Format g)</h3><table border=1 cellspacing=0 cellpadding=3>"
$html += "<tr>"
$html += "<th>User</th>"
$html += "<th>Enabled</th>"
$html += "<th>VMCount</th>"
$html += "<th>ReplicaCount</th>"
$html += "<th>RepositoryQuota in GB</th>"
$html += "<th>UsedSpace in GB</th>"
$html += "<th>RemainingSpace in GB</th>"
$html += "<th>UsedSpacePercentage</th>"
$html += "<th>Repository</th>"
$html += "<th>LeaseExpirationEnabled</th>"
$html += "<th>LeaseExpirationDate</th>"
$html += "</tr>"
foreach($veeamTenant in $VeeamTenantInfo){
    $html += "<tr>"
    $html += "<td>$($veeamTenant.User)</td>"
    $html += "<td>$($veeamTenant.Enabled)</td>"
    $html += "<td>$($veeamTenant.VMCount)</td>"
    $html += "<td>$($veeamTenant.ReplicaCount)</td>"
    $html += "<td>$($veeamTenant.RepositoryQuota)</td>"
    $html += "<td>$($veeamTenant.UsedSpace)</td>"
    $html += "<td>$($veeamTenant.RepositoryQuota - $veeamTenant.UsedSpace)</td>"
    $html += "<td>$($veeamTenant.UsedSpacePercentage)</td>"
    $html += "<td>$($veeamTenant.Repository)</td>"
    $html += "<td>$($veeamTenant.LeaseExpirationEnabled)</td>"
    $html += "<td>$($veeamTenant.LeaseExpirationDate)</td>"
    $html += "</tr>"
}
$html += "<tr>"
$html += "<td colspan=2><b>Totaal</b></td>"
$html += "<td>$(($VeeamTenantInfo.VMCount | Measure -Sum).sum)</td>"
$html += "<td>$(($VeeamTenantInfo.ReplicaCount | Measure -Sum).sum)</td>"
$html += "<td>$(($VeeamTenantInfo.RepositoryQuota | Measure -Sum).sum)</td>"
$html += "<td>$(($VeeamTenantInfo.UsedSpace | Measure -Sum).sum)</td>"
$html += "<td></td>"
$html += "<td></td>"
$html += "<td></td>"
$html += "<td></td>"
$html += "</tr>"
$html += "</table></body></html>"

$ScriptBaseName = ((Get-ChildItem ([string]$MyInvocation.InvocationName)).FullName) -replace "\.ps1$", ''
$html