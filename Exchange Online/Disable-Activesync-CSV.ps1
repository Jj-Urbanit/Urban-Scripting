#
# Disable_Activesync_CSV.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
$list = Import-Csv "c:\temp\activesync.csv"
foreach ($user in $list){
    if ($user.activesync -eq "yes")
        {
        write-host ================================
        write-host Based on the CSV imported, $user.user has activeysnc enabled
        #Set-CASMailbox -Identity $user.User -ActiveSyncEnabled $True
        }
    else
        {
        write-host ================================
        Write-Host Based on the CSV imported, $user.user will have activesync disabled
        #Set-CASMailbox -Identity $user.User -ActiveSyncEnabled $False
        }
    }
foreach ($user in $list){
    if ($user.OWAdevices -eq "yes")
        {
        write-host ================================
        write-host Based on the CSV imported, $user.user has OWA for devices enabled
        #Set-CASMailbox -Identity $user.User -OWAforDevicesEnabled $True
        }
    else
        {
        write-host ================================
        Write-Host Based on the CSV imported, $user.user will have OWA for devices disabled
        #Set-CASMailbox -Identity $user.User -OWAforDevicesEnabled $false
        }
 }
