#
# Remove_localdomain_proxyaddress.ps1
#
$Mailboxes = Get-Mailbox -result unlimited
$Mailboxes | foreach{
    for ($i=0;$i -lt $_.EmailAddresses.Count; $i++)
    {
        $address = $_.EmailAddresses[$i]
        if ($address.IsPrimaryAddress -eq $false -and $address.SmtpAddress -like "*bresicwhitney.local" )
        {
            Write-host($address.AddressString.ToString() | out-file c:\addressesRemoved.txt -append )
            $_.EmailAddresses.RemoveAt($i)
            $i--
        }
    }
    Set-Mailbox -Identity $_.Identity -EmailAddresses $_.EmailAddresses
}