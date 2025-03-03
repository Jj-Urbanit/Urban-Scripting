#This is specifically for NEXTGEN, this code would need to be altered for other customers.

# Update these variables as needed
$CID = '94A85EB8518A47F3962EB3977AE24B08-DC'
# The sensor is copied to the following directory
$SensorLocal = 'C:\Temp\WindowsSensor.MaverickGyr.exe'
$BDLocal = 'C:\Temp\BEST_uninstallTool.exe'

#Functions#
Function Get-CrowdStrike {
    # URL to download file from
    $url = "https://ngdo365ae.blob.core.windows.net/crowdstrike/WindowsSensor.MaverickGyr.exe"
    # Directory to save file to and file name.
    $output = "C:\temp\WindowsSensor.MaverickGyr.exe"
    # Download the file.
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
}
Function Get-BitDefender{
    # URL to download file from
    $url = "https://download.bitdefender.com/SMB/Hydra/release/bst_win/uninstallTool/BEST_uninstallTool.exe"
    # Directory to save file to and file name.
    $output = "C:\temp\BEST_uninstallTool.exe"
    # Download the file.
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
}
Function Get-Ncentral {
    # URL to download file from
    $url = "https://ngdo365ae.blob.core.windows.net/ncentral/305WindowsAgentSetup_DOES_NOT_EXPIRE.exe"
    # Directory to save file to and file name.
    $output = "C:\temp\305WindowsAgentSetup_DOES_NOT_EXPIRE.exe"
    # Download the file.
    (New-Object System.Net.WebClient).DownloadFile($url, $output)
}
Function Get-BitDefenderService{
    $service = Get-Service -Name EPSecurityService -ErrorAction SilentlyContinue
    if($service -eq $null)
    {
        $null
    } else {
        & $BDLocal /bdparams /bruteForce
    }
}
Function Install-CrowdStrike{
    $service = Get-Service -Name CSFalconService -ErrorAction SilentlyContinue
    if($service -eq $null)
    {
        & $SensorLocal /install /quiet /norestart CID=$CID
    } else {
        $Null
    }
}
Function Install-Ncentral {
        C:\temp\305WindowsAgentSetup_DOES_NOT_EXPIRE.exe -ai
}

#Execution#

# Create a TEMP directory if one does not already exist
if (!(Test-Path -Path 'C:\Temp' -ErrorAction SilentlyContinue)) {
    New-Item -ItemType Directory -Path 'C:\Temp' -Force
}

#Download CrowdStrike Sensor Install
Get-CrowdStrike

#Download BitDefender Uninstall Tool
Get-BitDefender

#Download CrowdStrike Sensor Install
Get-Ncentral

#Check for BitDefender Service and Uninstall
Get-BitDefenderService

#Install CrowdStrike
Install-CrowdStrike

#Install N-Central
Install-Ncentral