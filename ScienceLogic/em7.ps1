$Accounts = @()
$User = "em7admin"
$Password = "XkRfkr5gS8iBe6x_uP"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force 
$Credentials = New-Object -TypeName System.Management.Automation.PScredential ($User, $SecurePassword)
$Domain = "https://em7.themissinglink.com.au"
$URI = "/api/device"
$Limit = "?limit=100000"
$Method = "GET"
$Result = Invoke-RestMethod -Uri ($Domain+$URI+$Limit) -Method $Method -Credential $Credentials 
#devices "ale-br" $Result.result_set | sort description -Descending
$Result.result_set
# https://em7.themissinglink.com.au/em7/index.em7?exec=performance_ifrm&did=108&act=performance_network_utilnew&if_id=1074
# Device > performance > network interfaces > vocus