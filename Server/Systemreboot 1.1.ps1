<#
.Synopsis
    Short Description
.DESCRIPTION
    Long Description
.EXAMPLE
    Example of how to use the cmdlet
.EXAMPLE
    Another Example of how to use the cmdlet
#>

#Script Name
#Creator: Josh
#Date: 17/01/2019
#Updated:
#References, if any: -

#Variables
$hostname = hostname
$engineer = Read-host "Enter your First Name"
$currentdate = get-date

#Parameters

#Enter Tasks Below as Remarks

Do
{$date= read-host "Please enter date & time you'd like to reboot the server at (i.e.: '25/12/2012 09:00', '25 oct 2012 9:00'):"

    $date = $date -as [datetime]

    if (!$date) {
        "Not A valid date and time"
    }
} while ($date -isnot [datetime])

#Create Scheduled Task
function Schedule {
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "shutdown /r /t 0"'
    $trigger =  New-ScheduledTaskTrigger -Once -At $date
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Reboot Server" -Description "TML Server Reboot Created by $engineer"
}

#Check the server came back online.
function check-server {
    $url = "https://www.dropbox.com/s/tvr0fopsabwc1fh/Serveronlinecheck.ps1?dl=1"
    $output = "C:\temp\servercheck.ps1"
    (New-Object System.Net.WebClient).DownloadFile($url, $output)

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-file C:\temp\servercheck.ps1'
    $trigger =  New-ScheduledTaskTrigger -Once -At $date.Addminutes(30)
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Check Server after reboot" -Description "Reboot by $engineer"
}

#Send Slack Message.
function Send-SlackMessage {
    # Add the "Incoming WebHooks" integration to get started: https://slack.com/apps/A0F7XDUAZ-incoming-webhooks
    param (
        [Parameter(Mandatory=$true, Position=0)]$Text,
        $Url="", #Put your URL here so you don't have to specify it every time.
        # Parameters below are optional and will fall back to the default setting for the webhook.
        $Username, # Username to send from.
        $Channel, # Channel to post message. Can be in the format "@username" or "#channel"
        $Emoji, # Example: ":bangbang:".
        $IconUrl # Url for an icon to use.
    )
    
    $body = @{ text=$Text; channel=$Channel; username=$Username; icon_emoji=$Emoji; icon_url=$IconUrl } | ConvertTo-Json
    Invoke-WebRequest -Method Post -Uri $Url -Body $body
}

function Cleanup {
    $action = New-ScheduledTaskAction -Execute 'ForFiles' -Argument '/p "c:\temp" /c "cmd /c del servercheck.ps1"'
    $trigger =  New-ScheduledTaskTrigger -Once -At $date$date.Addminutes(120)
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Remove Old Script" -Description "Remove Reboot Script"
}

Schedule
check-server
cleanup
Send-SlackMessage "Server: $hostname set to restart at $date by $engineer" -Emoji ":clock1:" -Channel "#script-feedback"