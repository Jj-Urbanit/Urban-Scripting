#
# Modify_users_by_CSV.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session
#Connect-msolservice -credential $UserCredential

$path = "c:\temp"
$csvfile = $path + "\hg-sendas.csv"
$logs = $path + "\hg-sendas.log"

Import-Csv -path $csvfile | `

ForEach-Object {
	Add-RecipientPermission $_.identity -AccessRights SendAs -Trustee $_.user -whatif
}

#get-pssession | Remove-PSSession