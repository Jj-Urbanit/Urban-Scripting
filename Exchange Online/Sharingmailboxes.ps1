$sourcemailbox = read-host "Who gets access"
$destinationmailbox = read-host $sourcemailbox "is getting access to what email address"
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session -AllowClobber
