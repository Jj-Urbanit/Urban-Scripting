Get-WinEvent -Computername localhost -FilterHashtable @{Logname='Security';Id=4624;starttime=(Get-Date).AddDays(-1)} -WarningAction SilentlyContinue -ErrorAction SilentlyContinue


#test