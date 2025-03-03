#LogName: Application, System, Security
#EntryType: Error, Information, FailureAudit, SuccessAudit, Warning
Get-EventLog -Newest 20 -LogName "Application" -EntryType Error -Message "*Chrome*" | where {$_.eventID -eq 1000}
