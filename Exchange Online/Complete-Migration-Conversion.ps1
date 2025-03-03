#
# Complete_Migration_Conversion.ps1
#
$user = $args[0]

Set-AdServerSettings -ViewEntireForest $True

$addresses = (Get-Mailbox $user).EmailAddresses
$upn = (Get-Mailbox $user).UserPrincipalName

foreach ($address in $addresses) {
  try {
    if ($address.SmtpAddress.IndexOf(".mail.onmicrosoft.com") -gt 0) {
      $target = "SMTP:"+$address.SmtpAddress
    }
  }
  catch {}
}

Get-ADUser -Filter 'UserPrincipalName -eq $upn' | Set-ADUser -Clear homeMDB, homeMTA, msExchHomeServerName -Replace @{msExchVersion="44220983382016";msExchRecipientDisplayType="-2147483642";msExchRecipientTypeDetails="2147483648";msExchRemoteRecipientType="4";targetAddress=$target}
