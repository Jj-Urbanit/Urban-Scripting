# WannaCryUpdfatesCheckDomain.ps1
# Author: Blake Peden (bpeden@themissinglink.com.au)
# 2017-07-25

# Checks all machines for which there is an active computer account in Active
# Directory for updates that patch the vulnerability used in teh WannaCry
# randsomeware attack

$KBs = @"
KB4012212
KB4012215
KB4012218
KB4015549
KB4015552
KB4019263
KB4019264
KB4012214
KB4012217
KB4012220
KB4015551
KB4015554
KB4019214
KB4019216
KB4012213
KB4012216
KB4012219
KB4015550
KB4015553
KB4019213
KB4019215
KB4012606
KB4016637
KB4015221
KB4019474
KB4013198
KB4016636
KB4015219
KB4019473
KB4013429
KB4016635
KB4015217
KB4019472
KB4012219
KB4015553
KB4019217
KB4012220
KB4015554
KB4019218
KB4012218
KB4015552
KB4019265
"@ -split "`n"


Get-ADComputer -Filter {Enabled -eq $True} | foreach {
    $computer = $_.Name
    Try {
        Get-HotFix -id $KBs -ComputerName $computer -ErrorAction Stop
    }
    Catch [System.Runtime.InteropServices.COMException] {
        Write-Host "Can't connect to $computer"
    }
    Catch [System.ArgumentException] {
        Write-Host "$computer is not protected: None of the listed patches are applied"
    }
}
