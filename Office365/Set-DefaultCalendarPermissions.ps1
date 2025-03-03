#The function is located in the "General" folder
. C:\Scripts\Functions-PSStoredCredentials.ps1

# Folder for Logs and File Format
$LogFile = "C:\Scripts\Logs\TML_CalendarPermissions.log"

#### LOG FUNCTION ####
Function Write-Log
{
	param (
        [Parameter(Mandatory=$True)]
        [array]$LogOutput,
        [Parameter(Mandatory=$True)]
        [string]$Path
	)
	$currentDate = (Get-Date -UFormat "%d-%m-%Y")
	$currentTime = (Get-Date -UFormat "%T")
	$logOutput = $logOutput -join (" ")
	"[$currentDate $currentTime] $logOutput" | Out-File $Path -Append
}

$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ -ConfigurationName Microsoft.Exchange -Credential (Get-StoredCredential -UserName mliewerenz_admin@missinglink.com.au) -Authentication Basic -AllowRedirection
Import-PSSession $Session

foreach($user in Get-Mailbox -RecipientTypeDetails UserMailbox) {
    $cal = $user.alias+":\Calendar"
    $perm = Get-MailboxFolderPermission -Identity $cal -User Default | Select AccessRights
    if ($($perm.AccessRights) -ne "Reviewer"){
        Write-Log -LogOutput ("User {0} has differnt default permissions: {1}" -f $user,$($perm.AccessRights)) -Path $LogFile
        Set-MailboxFolderPermission -Identity $cal -User Default -AccessRights Reviewer
    }
}