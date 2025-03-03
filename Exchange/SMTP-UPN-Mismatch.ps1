#
# SMTP_UPN_Mismatch.ps1
#
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$count = 0
$mbxs = get-mailbox -resultsize unlimited | select userprincipalname,primarysmtpaddress
foreach ($mbx in $mbxs)
{
    $mbxsmtp = $mbx.primarysmtpaddress
    if ($mbx.userprincipalname -ne $mbx.primarysmtpaddress)
    {
        write-host "$mbxsmtp doesn't match"
        $count ++
    }
}
$count