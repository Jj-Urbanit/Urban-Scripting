$UserCredential = Get-Credential -UserName "dmathison_admin@themissinglink.com.au" -Message "Bleaeh"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

