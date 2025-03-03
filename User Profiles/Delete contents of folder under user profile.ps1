#This will delete all content with in the folder mentioned.
#If you want to confirm what will happen append switch "-WhatIf" to the end of "silentlycontinue"
$users = Get-ChildItem -Directory D:\Shares\Data\Redirected_Folders\Citrix715UPM -Exclude __Profile_Backup | Select-Object $_.Name
foreach ($user in $users){
$folder = "$($user.fullname)\UPM_Profile\AppData\Local\Microsoft\Windows\Caches\*"
   If (Test-Path $folder) {
     Remove-Item $folder -Recurse -Force -ErrorAction silentlycontinue
   }
}