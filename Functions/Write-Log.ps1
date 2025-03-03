#check foldeer path
$FolderPath = "C:\Temp"
if (Test-path $FolderPath){
	#temp folder exists, no action required
}
Else
{
	#create temp folder without an output
	[void]( New-Item $FolderPath -ItemType Directory)
}
# Set log path
$logpath = "C:\Temp\scriptlog.log"
# Function to write to log file
function Write-Log
{
    param($msg)
    "$(Get-Date -Format G) : $msg" | Out-File -FilePath $logpath -Append -Force
}