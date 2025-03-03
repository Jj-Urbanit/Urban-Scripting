Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$serverempty = 0
$mbempty = 0
$mbnotempty = 0
$mbservers = get-mailboxserver
foreach ($mbserver in $mbservers) {
    $mbs = get-mailboxdatabase -server $mbserver
    $mbcount = (get-mailboxdatabase -server $mbserver).count
    if ($mbcount -eq "0")
    {
        write-host -ForegroundColor Yellow $mbserver has no databases. Decommission
        $serverempty++
    }
    else
    {
        foreach ($mb in $mbs)
        {
            $count = (get-mailbox -database $mb).count
            if ($count -eq "0")
            {
                write-host =================================================
                write-host -ForegroundColor green $mb on $mbserver is empty
                $mbempty++
            }
            else
            {
                write-host =================================================
                write-host -ForegroundColor red $mb on $mbserver has $count mailboxes to migrate
                $mbnotempty++
            }
        }
    }
}
write-host ======================================================================
write-host ======================================================================
write-host -ForegroundColor Green $mbempty empty databases to delete
write-host -ForegroundColor red $mbnotempty not empty databases need attention
write-host -ForegroundColor yellow $serverempty empty servers to decommission
