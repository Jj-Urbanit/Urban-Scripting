#Change Hybrid AD Email distribution group display email.
#Connect to Exchange Online first
# The first address is the current addrese, -windowsemail address will be the new address. 
Set-DistributionGroup groupname@themissinglink.onmicrosoft.com -WindowsEmailAddress groupname@themissinglink.com.au -PrimarySmtpAddress groupname@themissinglink.com.au

set-DistributionGroup AE-TMLS@themissinglink.onmicrosoft.com -WindowsEmailAddress AE-Security@themissinglink.com.au -PrimarySmtpAddress AE-Security@themissinglink.com.au

