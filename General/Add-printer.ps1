#
# Add_printer.ps1
#
# Used to install printer and coresponding TCP/IP port, can be useful to push printer through InTune.
#7620 e_wf1kae.inf
# 7725 e_wf1sae.inf
$driver1 = Get-ChildItem "E:\WF-7725 Site Shed Printer\WF7720_x64_262JAUsHomeExportAsiaML\WINX64\e_wf1sae.inf"
$driver2 = Get-ChildItem "E:\WF-7620 site shed printer\WINX64\e_wf1kae.inf"
# -Recurse -Filter "*.inf" | where ($_.Name -like "E_WF1SAE.INF")
PNPUtil.exe /add-driver $driver1.FullName /install
PNPUtil.exe /add-driver $driver2.FullName /install
Add-PrinterPort -Name "IP_192.168.1.192" -PrinterHostAddress "192.168.1.192"
Add-PrinterDriver -Name "EPSON WF-7620 Series"
Add-PrinterDriver -Name "EPSON WF-7720 Series"
Add-Printer -name "Site Shed" -portname "IP_192.168.1.192" -DriverName "EPSON WF-7720 Series"