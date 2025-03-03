#
# Delicense_Shared_MBs.ps1
#
#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session -AllowClobber
#Connect-MsolService -Credential $UserCredential
$SharedMBs=Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited
$SharedMBs |select userprincipalname |  Export-Csv -Path c:\temp\sharedmbs.csv -NoTypeInformation
$Sharedcount = ($SharedMBs).count
$removalcount=0
$notremovedcount=0
#write-host Found $Sharedcount mailboxes
foreach ($smb in $SharedMBs)
{
		$user = get-msoluser -UserPrincipalName $smb.userprincipalname
    if ($user.islicensed -eq $True)
    {
        #write-host $user.userprincipalname has a license and needs to be removed.
		#Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -RemoveLicenses ppg4:STANDARDPACK
        $removalcount ++
    }
    else
    {
        #write-host $user.UserPrincipalName does not have a license
        $notremovedcount ++
    }
}
write-host $removalcount licenses reclaimed
write-host $notremovedcount users correctly configured