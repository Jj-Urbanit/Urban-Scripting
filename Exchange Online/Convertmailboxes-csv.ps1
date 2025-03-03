$csv = import-csv C:\TML-Decom\mailboxes.csv
$csv.Alias | % {
    $_
    #disable-mailbox -Identity $_  -Confirm:$false
    #enable-mailuser -identity $_ -externalemailaddress $csv.EmailAddresses -Confirm:$false
}