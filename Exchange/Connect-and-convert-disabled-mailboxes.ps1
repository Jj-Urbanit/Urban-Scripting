#
# Connect_and_convert_disabled_mailboxes.ps1
#
# used to read a CSV and recover soft-deleted mailboxes and convert to shared
import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
$csv = "C:\temp\undelete.csv"
$all = Import-Csv -Path $csv
$recovercount = 0
$log = "c:\temp\enabling.log"
foreach ($row in $all)
{
    $mbx = Get-MailboxDatabase | Get-MailboxStatistics | Where { $_.DisplayName -eq $row.displayname } 
    foreach ($mb in $mbx)
    {
        if ($mb.disconnectdate -ne $null)
        {
            $recovercount ++
            $mbname = $mb.DisplayName
            "$mbname needs to be recovered" | Out-File -Append -Filepath $log
            $name = $mb.DisplayName.ToString()
            $user = get-aduser -filter {displayname -like $name}
            $username = $user.name.ToString()
            #if ($user.Enabled -eq $false)
            #{
                #$wasdisabled = "true"
                #Enable-ADAccount -Identity $user -Verbose
                #"enabling $userName" |Out-File -Append $log
            #}
            #else
            #{
                #$wasdisabled = "false"
            #}
            #start-sleep 11
            #write-host $user.Enabled 
            #Connect-mailbox -shared -Identity $name -database $mb.database.Name -user $username >> $log
            set-mailbox -Identity $name -Type Shared
            #if ($wasdisabled -eq "true")
            #{
                #Disable-ADAccount -Identity $user
                #"disabling $userName" | out-file -Filepath $log -Append
            #}
        }
    }
}
write-host $recovercount mailboxes to be processed
