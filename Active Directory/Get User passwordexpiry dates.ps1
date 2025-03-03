#
# user_passwordexpiry_dates.ps1
#

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
} else {
    Write-Host "Module does not exist"
}

Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} 