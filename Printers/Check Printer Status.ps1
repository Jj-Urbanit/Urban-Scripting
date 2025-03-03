Function Test-OSCPrinter
{
<#
Status information for a printer as below.
Value,Meaning
1 (0x1) ,Other
2 (0x2) ,Unknown
3 (0x3) ,Idle
4 (0x4) ,Printing
5 (0x5) ,Warming Up
6 (0x6) ,Stopped printing
7 (0x7) ,Offline
#>    
    Try
    {    #retrieve all network printer and check if network printer is connected
        Get-WmiObject -Class Win32_Printer -ErrorAction Stop | Where {$_.Network} | Select-Object Name,SystemName,`
        @{Name="PrinterStatus";Expression={Switch($_.PrinterStatus)
                                            {
                                                1 {"Other"; break}
                                                2 {"Unknown"; break}
                                                3 {"Idle"; break}
                                                4 {"Printing"; break}
                                                5 {"Warming Up"; break}
                                                6 {"Stopped printing"; break}
                                                7 {"Offline"; break}
                                            }}},`
        @{Name="ConnectedStatus";Expression={$PrinterName = $_.Name;
                                            Try
                                            {
                                                $NetworkObj = New-Object -ComObject WScript.Network
                                                $NetworkObj.AddWindowsPrinterConnection("$PrinterName")
                                                "Connected"
                                            }
                                            Catch
                                            {"Unconnected"}}} | Format-Table -AutoSize
    }
    Catch
    {
        Write-Warning "Failed to find printer,please check your printer service 'Spooler' is running."
    }
}
#invoke the function
Test-OSCPrinter