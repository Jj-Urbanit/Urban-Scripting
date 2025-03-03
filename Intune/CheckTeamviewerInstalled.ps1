$AppName = "TeamViewer"
$64BitPath = "C:\Program Files\TeamViewer\TeamViewer.exe"
$32BitPath = "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
Write-Host "Custom script based detection : $AppName"
if (Test-path $64BitPath) {       
        Write-Host "64 bit Path Found"
        Exit 0}
else { 
    if (Test-Path $32BitPath){
        Write-Host "32 bit Path Found"
        Exit 0}
    Else{
    Write-host "File not found. Application not installed"
    Exit 1}
}
Exit 1