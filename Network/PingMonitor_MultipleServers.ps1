#### Provide the computer name in $ServerName variable
$ServerName = "ausyd1ads01","ausyd2ads03","ausyd1sccm01" 
$Count = 99999
##### Script Starts Here ###### 
While ($Count -gt 0)
{ 
	foreach ($Server in $ServerName) {

		if (test-Connection -ComputerName $Server -Count 2 -Quiet ) { 
		
			write-Host "$Server is alive and Pinging " -ForegroundColor Green
		
					} else
					
					{ Write-Warning "$Server seems dead not pinging"
			
					}	
		
	}
}

########## end of script #######################