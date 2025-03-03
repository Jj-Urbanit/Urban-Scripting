<#
.Synopsis
    Ping servers and post to Slack when down
.DESCRIPTION
    This script will ping all servers listed in C:\Temp\Ping\servers.txt and post to Slack when they are non responsive.
.EXAMPLE
    Example of how to use the cmdlet
#>

#Script Name: Ping.ps1
#Creator: Josh
#Date: 15/03/2019
#Updated:
#References, if any:

# Variables
# Reset the lists of hosts prior to looping
$OutageHosts = $Null
# specify the time you want email notifications resent for hosts that are down
$EmailTimeOut = 30
# specify the time you want to cycle through your host lists.
$SleepTimeOut = 45
# specify the maximum hosts that can be down before the script is aborted
$MaxOutageCount = 10
# specify who gets notified
$notificationto = "m1n6n2d9b3q2g8p9@themissinglink.slack.com"
# specify where the notifications come from
$notificationfrom = "$env:COMPUTERNAME@*domain*"
# specify the SMTP server
$smtpserver = "*Mail Server*"
#Log File Location
$logfile = "c:\temp\ping\log.txt"
#Channel to Post Alerts to
$customerchannel = "*Channel Name*"

#Parameters

#Enter Taska Below as Remarks

$Now = Get-Date
$Now = $Now.ToString("dd/MM/yyyy HH:mm:ss")

Function Send-SlackMessage {
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

Function LogEvent {
"$Now `| Ping failed from $env:COMPUTERNAME to $_" | Out-File -FilePath $logfile -Append
}


# start looping here
Do{
$available = $Null
$notavailable = $Null
Write-Host (Get-Date)

# Read the File with the Hosts every cycle, this way to can add/remove hosts
# from the list without touching the script/scheduled task, 
# also hash/comment (#) out any hosts that are going for maintenance or are down.
get-content C:\Temp\Ping\servers.txt | Where-Object {!($_ -match "#")} | 
ForEach-Object {
if(Test-Connection -ComputerName $_ -Count 1 -ea silentlycontinue)
    {
     # if the Host is available then just write it to the screen
     write-host "Available host ---> "$_ -BackgroundColor Green -ForegroundColor White
     [Array]$available += $_
    }
else
    {
     # If the host is unavailable, give a warning to screen
     write-host "Unavailable host ------------> "$_ -BackgroundColor Magenta -ForegroundColor White
     if(!(Test-Connection -ComputerName $_ -Count 4 -ea silentlycontinue))
       {
        # If the host is still unavailable for 4 full pings, write error and send email
        write-host "Unavailable host ------------> "$_ -BackgroundColor Red -ForegroundColor White
        [Array]$notavailable += $_

        if ($OutageHosts -ne $Null)
            {
                if (!$OutageHosts.ContainsKey($_))
                {
                 # First time down add to the list and send email
                 Write-Host "$_ Is not in the OutageHosts list, first time down"
                 $OutageHosts.Add($_,(get-date))
                 $Body = "$_ has not responded for 5 pings at $Now"
                 #Send-MailMessage -Body "$body" -to $notificationto -from $notificationfrom `
                  #-Subject "Host $_ is down" -SmtpServer $smtpserver
                  LogEvent
                 # Send Message to Slack
                 Send-SlackMessage "Print Server: Host $_ is down, $Body" -Emoji ":octagonal_sign:" -Channel "$customerchannel"
                }
                else
                {
                    # If the host is in the list do nothing for 1 hour and then remove from the list.
                    Write-Host "$_ Is in the OutageHosts list"
                    if (((Get-Date) - $OutageHosts.Item($_)).TotalMinutes -gt $EmailTimeOut)
                    {$OutageHosts.Remove($_)}
                }
            }
        else
            {
                # First time down create the list and send email
                Write-Host "Adding $_ to OutageHosts."
                $OutageHosts = @{$_=(get-date)}
                $Body = "$_ has not responded for 5 pings at $Now" 
                #Send-MailMessage -Body "$body" -to $notificationto -from $notificationfrom `
                 #-Subject "Host $_ is down" -SmtpServer $smtpserver
                 LogEvent
                # Send Message to Slack
                Send-SlackMessage "Print Server: Host $_ is down, $Body" -Emoji ":octagonal_sign:" -Channel "$customerchannel"
            } 
       }
    }
}
# Report to screen the details
Write-Host "Available count:"$available.count
Write-Host "Not available count:"$notavailable.count
Write-Host "Not available hosts:"
$OutageHosts
Write-Host ""
Write-Host "Sleeping $SleepTimeOut seconds"
sleep $SleepTimeOut
if ($OutageHosts.Count -gt $MaxOutageCount)
{
    # If there are more than a certain number of host down in an hour abort the script.
    $Exit = $True
    $body = $OutageHosts | Out-String
    #Send-MailMessage -Body "$body" -to $notificationto -from $notificationfrom `
     #-Subject "More than $MaxOutageCount Hosts down, monitoring aborted" -SmtpServer $smtpServer
    
    # Send Message to Slack 
    Send-SlackMessage "Print Server: More than $MaxOutageCount Hosts down, monitoring aborted" -Emoji ":octagonal_sign:" -Channel "$customerchannel"
}
}
while ($Exit -ne $True)