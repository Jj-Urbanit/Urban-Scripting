# force all exceptions to trigger the catch block
$ErrorActionPreference = "Stop"
$status_code = 0
$url = "https://www.dropbox.com/s/fwhe5gfaairablu/GoogleUpdate.adml?dl=1"
$url2 = "https://www.dropbox.com/s/4nds6unsi5xfi01/GoogleUpdate.admx?dl=1"
$target_directory = "C:\Temp"
$output = "C:\Temp\googleupdate.adml"
$output2 = "C:\Temp\googleupdate.admx"

try {
    # test if the target directory already exists
    if (!(Test-Path -Path $target_directory)) {
        # an exception will still be generated if something goes wrong
        # e.g. permissions issue
        New-Item -path "c:\" -Name "Temp" -ItemType "directory"    
    }
    
    Invoke-WebRequest -Uri $url -OutFile $output
    Invoke-WebRequest -Uri $url2 -OutFile $output2

    Copy-Item "C:\Temp\GoogleUpdate.adml" -Destination "C:\Windows\PolicyDefinitions\en-US"
    Copy-Item "C:\Temp\GoogleUpdate.admx" -Destination "C:\Windows\PolicyDefinitions"

    New-Item -Path HKLM:\Software\Policies\Google\ -Name "Update" -Force
    Set-ItemProperty -Path HKLM:\Software\Policies\Google\Update -Name "Update" -Value 0
}
catch {
    write-host "Caught an exception:" -ForegroundColor Red
    write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
    write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    $status_code = 1

}

Write-Host $status_code