#
# DFS_Cutover.ps1
#
#Used to reduce DFS TTL frmo 30 mins to 10 minutes, then cutover all targets from old to new server if the nubmer of targets is GT 1 (targets not migrating will not have the new folder target). Then flushes the referral cache on DC's.
$roots = Get-DfsnRoot
foreach ($root in $roots)
{
    $rootpath = $root.path+"\*"
    $folders = Get-DfsnFolder -Path $rootpath
    foreach ($folder in $folders)
    {
       #set to small for migration
       Set-DfsnFolder -Path $folder.Path -TimeToLiveSec 300
       #set back to default
       #Set-DfsnFolder -Path $folder.Path -TimeToLiveSec 1800
    }
}

$table = Get-DfsnFolder -Path "\\colgreig.dom\shares\*"
foreach ($line in $table)
{
    $targets = Get-DfsnFolderTarget -Path $line.Path
    foreach ($target in $targets)
    {
        if ($targets.count -gt 1)
        {
            if ($target.targetpath.ToString() -match "\\\\cg-cdfs01" -and $target.State -eq "Offline")
            {
                write-host $target.path on $target.targetpath is the new server and enabling target
                Set-DfsnFolderTarget -Path $target.Path -TargetPath $target.TargetPath -State Online -WhatIf
            }
            if ($target.targetpath -match "\\\\cgdfs01" -and $target.State -eq "Online")
            {
                Set-DfsnFolderTarget -Path $target.Path -TargetPath $target.TargetPath -State Offline -WhatIf
                write-host $target.path on $target.targetpath is the old server and disabling target
            }
        }
    }
}

$geeks = Get-DfsnFolder -Path "\\colgreig.dom\IT\*"
foreach ($geek in $geeks)
{
    $points = Get-DfsnFolderTarget -Path $geek.Path
    foreach ($point in $points)
    {
        if ($points.count -gt 1)
        {
            if ($point.targetpath.ToString() -match "\\\\cg-cdfs01" -and $point.State -eq "Offline")
            {
                write-host $point.path on $point.targetpath is the new server and enabling target
                Set-DfsnFolderTarget -Path $point.Path -TargetPath $point.TargetPath -State Online -WhatIf
            }
            if ($point.targetpath -match "\\\\cgdfs01" -and $point.State -eq "Online")
            {
                Set-DfsnFolderTarget -Path $point.Path -TargetPath $point.TargetPath -State Offline -WhatIf
                write-host $point.path on $point.targetpath is the old server and disabling target
            }
        }
    }
}

Invoke-Command -ComputerName cg-cdc01 -ScriptBlock {dfsutil cache referral flush }
Invoke-Command -ComputerName cg-cdc02 -ScriptBlock {dfsutil cache referral flush }
Invoke-Command -ComputerName cgads01 -ScriptBlock {dfsutil cache referral flush }
Invoke-Command -ComputerName cgads02 -ScriptBlock {dfsutil cache referral flush }