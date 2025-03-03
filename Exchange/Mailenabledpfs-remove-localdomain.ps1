#
# Mailenabledpfs_remove_localdomain.ps1
#
$Mailboxes = Get-Mailpublicfolder -resultsize unlimited
$Mailboxes | foreach{
    for ($i=0;$i -lt $_.EmailAddresses.Count; $i++)
    {
        $address = $_.EmailAddresses[$i]
        if ($address.IsPrimaryAddress -eq $false -and $address.SmtpAddress -like "*domain.local" )
        {
            Write-host($address.AddressString.ToString() | out-file c:\addressesRemoved.txt -append )
            $_.EmailAddresses.RemoveAt($i)
            $i--
        }
    }
    Set-Mailpublicfolder -Identity $_.Identity -EmailAddresses $_.EmailAddresses
}