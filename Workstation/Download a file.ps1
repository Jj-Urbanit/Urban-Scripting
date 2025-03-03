# Slack Function
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

# URL to download file from
$url = "https://www.dropbox.com/s/2bp0qu9yu5ynnhg/UEAUserFiles.zip?dl=1"

# Directory to save file to and file name.
$output = "D:\Data\Userfiles.zip"

$start_time = Get-Date

# Download the file.
(New-Object System.Net.WebClient).DownloadFile($url, $output)

# Post Message to Slack upon completion. (Channel "Script-feedback")
Send-SlackMessage "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)" -Emoji ":fire:" -Channel "#script-feedback"