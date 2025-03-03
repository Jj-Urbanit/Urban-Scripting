$windowsUpdateObject = New-Object -ComObject Microsoft.Update.AutoUpdate
$servername = $env:computername
$windowsUpdateObject.Results | Select-Object -property LastInstallationSuccessDate  # | export-csv -path \\missinglink.com.au\nas\storage\TEMP\Winupdates\wupdates.csv -append - Force

