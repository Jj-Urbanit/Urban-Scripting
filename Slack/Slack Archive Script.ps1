$Token = ''
$PayLoad1 = @{token=$Token}
$Slack_ChannelList = Invoke-RestMethod -Uri https://slack.com/api/channels.list -Body $PayLoad1
$ChannelsToArchive =@()
$Slack_ChannelHistory=@()
foreach ($Slack_Channel in $Slack_ChannelList.channels) {
    if ($Slack_Channel.is_archived -eq $false -and $Slack_Channel.name -notlike "client-*" -and $Slack_Channel.name -notlike "topic-smart*") {
        $PayLoad2 = @{token=$Token;channel=$Slack_Channel.id}
        $Slack_ChannelHistory = Invoke-RestMethod -Uri https://slack.com/api/channels.history -Body $PayLoad2
        $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
        $LastMessageTime = $origin.AddSeconds($($Slack_ChannelHistory[0].messages[0].ts)).AddHours(11)
        if ($LastMessageTime -lt $(Get-Date).AddDays(-60)) {
            $Slack_Channel.name + " is older than 60 days"
            $ChannelsToArchive += $Slack_Channel.name
            $PayLoad3 = @{token=$Token;channel=$Slack_Channel.id}
            Invoke-RestMethod -Uri https://slack.com/api/channels.archive -Body $PayLoad3
        }
    } else {$null}
}