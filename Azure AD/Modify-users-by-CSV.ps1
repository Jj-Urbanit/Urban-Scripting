#
# Modify_users_by_CSV.ps1
#
#$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-msolservice -credential $UserCredential

$path = "c:\temp"
#$csvfile = $path + "\hg-addressbook.csv"
$csvfile = $path + "\displaynames.csv"
$logs = $path + "\usermodify.log"

Import-Csv -path $csvfile | `

ForEach-Object {
	#get-msoluser -userprincipalname $_.WindowsEmailAddress | Set-MSOLUSER -firstname $_."First Name" -lastname $_."Last Name" -department $_.dept -title $_.title -City $_.City`
	#-Fax $_.fax -PostalCode $_.postalcode -PhoneNumber $_.phone -StreetAddress $_.streetaddress
	#Set-User -Identity $_.WindowsEmailAddress -CountryOrRegion $_.CountryOrRegion -Company $_.company
	#Write-Host Updating $_.displayname
	get-msoluser -UserPrincipalName $_.PrimarySmtpAddress | set-msoluser -DisplayName $_.displayname
#if ($_.password -ne $null)
#	{
#		Set-MsolUserPassword -userprincipalname $_.email -newpassword $_.pswd -ForceChangePassword $false
#	}
}

get-pssession | Remove-PSSession