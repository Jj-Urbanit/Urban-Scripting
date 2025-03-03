param(
[int]$waitseconds = 5,
[string]$SERV = "AFMEX02"
)
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

while($true) {
    cls
    Get-Date
    Write-Output "============================================"
    Write-Host "SERVER: "$SERV
    Write-Host " "
    $var = Get-MailboxDatabase -Server $SERV -Status | Select Name,Mounted,WhenCreated,WhenChanged,DatabaseSize
    for($i=0;$i -lt $var.Count;$i++){
        Write-Host -NoNewline "***" $var.Name[$i] "***"
        if($var.Mounted[$i] -like "False"){
        Write-Host -ForegroundColor Red " OFFLINE"
        } else {
        Write-Host -ForegroundColor Green " ONLINE"
        }
        Write-Host "Created: " $var.WhenCreated[$i]
        Write-Host "Changed: " $var.WhenChanged[$i]
        Write-Host "Size: " $var.DatabaseSize[$i]
        Write-Host " "
    }
    sleep $waitseconds
}