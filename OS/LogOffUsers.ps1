$ServerList = 'AFMHVTS01', 'AFMHVTS02'
Invoke-CimMethod -ComputerName $ServerList -ClassName Win32_Operatingsystem -MethodName Win32Shutdown -Arguments @{ Flags = 0 } -Verbose
Start-Sleep -Seconds 120 -Verbose
Invoke-CimMethod -ComputerName $ServerList -ClassName Win32_Operatingsystem -MethodName Win32Shutdown -Arguments @{ Flags = 4 } -Verbose
Start-Sleep -Seconds 60 -Verbose
Invoke-CimMethod -ComputerName $ServerList -ClassName Win32_Operatingsystem -MethodName Win32Shutdown -Arguments @{ Flags = 2 } -Verbose

# $Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-ExecutionPolicy Bypass -File C:\scripts\Reboot.ps1'
# $Trigger = New-ScheduledTaskTrigger -Daily -At 3am
# Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Session Host Reboot Schedule" -Description "Reboots the session hosts every night at 3 AM after logging off the connected interactive sessions."