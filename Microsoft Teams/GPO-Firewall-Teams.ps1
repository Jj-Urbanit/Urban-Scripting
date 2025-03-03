# GPO_Firewall_Teams.ps1
$logfile = "c:\temp\teamfw.txt"
$users = Get-ChildItem C:\Users

foreach ($user in $users)
{
	$path = "c:\users\" + $user.Name + "\appdata\local\Microsoft\Teams\current\teams.exe"
	if (Test-Path $path)
	{
		$name = "teams.exe " + $user.Name
		
		if (!(Get-NetFirewallRule -DisplayName $name))
        {
        try
            {
			    New-NetfirewallRule -DisplayName $name -Direction Inbound -Profile Domain -Program $path -Action Allow -Verbose
                "Firewall rule created for $name" | out-file -Append $logfile
		    }
            catch
            {
	            $errormsg = "Error modifying firewall rule $_.Exception.Message" | Out-File -Append $logfile
            }
	    }
    }
}
