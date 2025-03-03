#Checks SMB1 status on a device and writes to a csv. CSV name is the machine name.

$computername = $env:computername
Get-SmbServerConfiguration  | Select-Object -property enablesmb1protocol | export-csv -Path "C:\temp\$computername.csv" -NoTypeInformation




