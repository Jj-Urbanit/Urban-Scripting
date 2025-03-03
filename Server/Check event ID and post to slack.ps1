<#
.Synopsis
    Check Event ID on Servers and post to Slack
.DESCRIPTION
    This Script is used to check event IDs on servers listed and post to the slack channel "#script-feedback" is events are found for the previous day.
.EXAMPLE
    Modify the Event ID and servers variable then schedule the script as task on windows server everyday.
#>

#Script Name: Check Event IDs
#Creator: Josh
#Date: 18/02/2019
#Updated: - 
#References, if any

#Variables
$InstanceID = 
$date = (get-date).AddDays(-1)
$servers = ("*Server Names*")
#Parameters

function Send-SlackMessage {
    # Add the "Incoming WebHooks" integration to get started: https://slack.com/apps/A0F7XDUAZ-incoming-webhooks
    param (
        [Parameter(Mandatory=$true, Position=0)]$Text,
        $Url="https://hooks.slack.com/services/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", #Put your URL here so you don't have to specify it every time.
        # Parameters below are optional and will fall back to the default setting for the webhook.
        $Username, # Username to send from.
        $Channel, # Channel to post message. Can be in the format "@username" or "#channel"
        $Emoji, # Example: ":bangbang:".
        $IconUrl # Url for an icon to use.
    )
    
    $body = @{ text=$Text; channel=$Channel; username=$Username; icon_emoji=$Emoji; icon_url=$IconUrl } | ConvertTo-Json
    Invoke-WebRequest -Method Post -Uri $Url -Body $body
}

foreach ($server in $servers) 
{
$events = Get-EventLog -LogName System -InstanceID $InstanceID -After $date -ComputerName $server | out-string
Send-SlackMessage "$server $events" -Emoji ":fire:" -Channel "#script-feedback"
}