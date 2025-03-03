#
# Bulk_Add_UPNSuffixes_toAD.ps1
#
$domains = get-accepteddomain
foreach ($domain in $domains) {
	Get-ADForest | Set-ADForest -UPNSuffixes @{add="$domain"} -whatif
	Write-Host Adding $domain to UPN Suffix list in Forest
}