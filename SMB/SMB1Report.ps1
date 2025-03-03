# Checks SMB1 status on a device and writes to a csv. CSV is the machine name.
# CSV File is then coped to a designated central location (usually a network path) top be reviewed

$Localpath = "C:\temp\$computername.csv"
$RemotePath = "\\UNC Path to Server here"
$computername = $env:computername

Get-SmbServerConfiguration  | Select-Object -property enablesmb1protocol | export-csv -Path $Localpath -NoTypeInformation
Move-Item -path $Localpath -Destination $RemotePath


