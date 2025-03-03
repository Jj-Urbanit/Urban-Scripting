<#
# Password_Expiration_Notification.ps1
#
#.EXAMPLE 
#  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <itadmin@wem.com.au>" -Logging -LogPath "c:\logFiles" -testing -testRecipient itadmin@wem.com.au 
#.EXAMPLE 
#  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <itadmin@wem.com.au>" -reportTo myaddress@domain.com -interval 1,2,5,10,15 
#> 
param( 
    # $smtpServer Enter Your SMTP Server Hostname or IP Address 
    [Parameter(Mandatory=$True,Position=0)] 
    [ValidateNotNull()] 
    [string]$smtpServer, 
    # Notify Users if Expiry Less than X Days 
    [Parameter(Mandatory=$True,Position=1)] 
    [ValidateNotNull()] 
    [int]$expireInDays, 
    # From Address, eg "IT Support <itadmin@wem.com.au>" 
    [Parameter(Mandatory=$True,Position=2)] 
    [ValidateNotNull()] 
    [string]$from, 
    [Parameter(Position=3)] 
    [switch]$logging, 
    # Log File Path 
    [Parameter(Position=4)] 
    [string]$logPath, 
    # Testing Enabled 
    [Parameter(Position=5)] 
    [switch]$testing, 
    # Test Recipient, eg recipient@domain.com 
    [Parameter(Position=6)] 
    [string]$testRecipient, 
    # Output more detailed status to console 
    [Parameter(Position=7)] 
    [switch]$status, 
    # Log file recipient 
    [Parameter(Position=8)] 
    [string]$reportto, 
    # Notification Interval 
    [Parameter(Position=9)] 
    [array]$interval 
) 
################################################################################################################### 
$start = [datetime]::Now 
$midnight = $start.Date.AddDays(1) 
$timeToMidnight = New-TimeSpan -Start $start -end $midnight.Date 
$midnight2 = $start.Date.AddDays(2) 
$timeToMidnight2 = New-TimeSpan -Start $start -end $midnight2.Date 
# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
$today = $start 
# End System Settings 
 
# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired 
Import-Module ActiveDirectory 
$padVal = "20" 
Write-Output "Script Loaded" 
Write-Output "*** Settings Summary ***" 
$smtpServerLabel = "SMTP Server".PadRight($padVal," ") 
$expireInDaysLabel = "Expire in Days".PadRight($padVal," ") 
$fromLabel = "From".PadRight($padVal," ") 
$testLabel = "Testing".PadRight($padVal," ") 
$testRecipientLabel = "Test Recipient".PadRight($padVal," ") 
$logLabel = "Logging".PadRight($padVal," ") 
$logPathLabel = "Log Path".PadRight($padVal," ") 
$reportToLabel = "Report Recipient".PadRight($padVal," ") 
$interValLabel = "Intervals".PadRight($padval," ") 
if($testing) 
{ 
    if(($testRecipient) -eq $null) 
    { 
        Write-Output "No Test Recipient Specified" 
        Exit 
    } 
} 
if($logging) 
{ 
    if(($logPath) -eq $null) 
    { 
        $logPath = $PSScriptRoot 
    } 
} 
Write-Output "$smtpServerLabel : $smtpServer" 
Write-Output "$expireInDaysLabel : $expireInDays" 
Write-Output "$fromLabel : $from" 
Write-Output "$logLabel : $logging" 
Write-Output "$logPathLabel : $logPath" 
Write-Output "$testLabel : $testing" 
Write-Output "$testRecipientLabel : $testRecipient" 
Write-Output "$reportToLabel : $reportto" 
Write-Output "$interValLabel : $interval" 
Write-Output "*".PadRight(25,"*") 
$users = get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress | where { $_.passwordexpired -eq $false } 
# Count Users 
$usersCount = ($users | Measure-Object).Count 
Write-Output "Found $usersCount User Objects" 
# Collect Domain Password Policy Information 
$defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days
#$defaultMaxPasswordAge = 170  
Write-Output "Domain Default Password Age: $defaultMaxPasswordAge" 
# Collect Users 
$colUsers = @() 
# Process Each User for Password Expiry 
Write-Output "Process User Objects" 
foreach ($user in $users) 
{ 
    $Name = $user.Name 
    $emailaddress = $user.emailaddress 
    $passwordSetDate = $user.PasswordLastSet 
    $samAccountName = $user.SamAccountName 
    $pwdLastSet = $user.PasswordLastSet 
    # Check for Fine Grained Password 
    $maxPasswordAge = $defaultMaxPasswordAge 
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)  
    if (($PasswordPol) -ne $null) 
    { 
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge.Days 
    } 
    # Create User Object 
    $userObj = New-Object System.Object 
    $expireson = $pwdLastSet.AddDays($maxPasswordAge)
    $expiresond = $expireson.ToString("dddd, dd MMMM yyyy")
    $daysToExpire = New-TimeSpan -Start $today -End $Expireson 
    # Round Up or Down 
    if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -le $timeToMidnight.TotalHours)) 
    { 
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "today." 
    } 
    if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -gt $timeToMidnight.TotalHours) -or ($daysToExpire.Days -eq "1") -and ($daysToExpire.TotalHours -le $timeToMidnight2.TotalHours)) 
    { 
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "tomorrow." 
    } 
    if(($daysToExpire.Days -ge "1") -and ($daysToExpire.TotalHours -gt $timeToMidnight2.TotalHours)) 
    { 
        $days = $daysToExpire.TotalDays 
        $days = [math]::Round($days) 
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "in $days days" 
    } 
    $daysToExpire = [math]::Round($daysToExpire.TotalDays) 
    $userObj | Add-Member -Type NoteProperty -Name UserName -Value $samAccountName 
    $userObj | Add-Member -Type NoteProperty -Name Name -Value $Name 
    $userObj | Add-Member -Type NoteProperty -Name EmailAddress -Value $emailAddress 
    $userObj | Add-Member -Type NoteProperty -Name PasswordSet -Value $pwdLastSet 
    $userObj | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daysToExpire 
    $userObj | Add-Member -Type NoteProperty -Name ExpiresOn -Value $expiresond
    $colUsers += $userObj 
} 
$colUsersCount = ($colUsers | Measure-Object).Count 
Write-Output "$colusersCount Users processed" 
$notifyUsers = $colUsers | where { $_.DaysToExpire -le $expireInDays} 
$notifiedUsers = @() 
$notifyCount = ($notifyUsers | Measure-Object).Count 
Write-Output "$notifyCount Users with expiring passwords within $expireInDays Days" 
foreach ($user in $notifyUsers) 
{ 
    # Email Address
    $samAccountName = $user.UserName 
    $emailAddress = $user.EmailAddress
    $expiresonday = $user.ExpiresOn 
    # Set Greeting Message 
    $name = $user.Name 
    $messageDays = $user.UserMessage 
    # Subject Setting 
    $subject="Your password will expire $messageDays"
    # Email Body Set Here, Note You can use HTML, including Images. 
    $body =" 
    <font face=""verdana""> 
    Dear $name, 
    <p> Your Password will expire $messageDays, on $expiresonday.
    <p> To change your password on your computer press CTRL ALT DELETE and choose Change Password.
    <p> Please note, you will need to be onsite at Seven Hills, connected to the WEM network to facilitate the password update.
    <p> Ensure you do this BEFORE the expiry date, $expiresonday.
    <p> Your mobile device will prompt you within 24 hours of the password change, to enter your NEW password.<br>
    <p>Your password must meet the minimum standard. 
<ul>
  <li>Passwords must have at least eight characters.</li>
<li>Passwords cannot contain the user name or parts of the user�s full name, such as first name </li>
<li>Passwords must use at least three of the four available character types: lowercase letters, uppercase letters, numbers, and symbols.</li>
</ul>

    </font>" 
        
    # If Testing Is Enabled - Email Administrator 
    if($testing) 
    { 
        $emailaddress = $testRecipient 
    } # End Testing 
 
    # If a user has no email address listed 
    if(($emailaddress) -eq $null) 
    { 
        $emailaddress = $testRecipient     
    }# End No Valid Email 
    $samLabel = $samAccountName.PadRight($padVal," ") 
    try 
    { 
        if($interval) 
        { 
            $daysToExpire = [int]$user.DaysToExpire 
            if(($interval) -Contains($daysToExpire)) 
            { 
                if($status) 
                { 
                    Write-Output "Sending Email : $samLabel : $emailAddress" 
                } 
                Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop 
                $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "OK" 
            } 
            else 
            { 
                if($status) 
                { 
                    Write-Output "Sending Email : $samLabel : $emailAddress : Skipped - Interval" 
                } 
                $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "Skipped - Interval" 
            } 
        } 
        else 
        { 
            if($status) 
            { 
                Write-Output "Sending Email : $samLabel : $emailAddress" 
            } 
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop 
            $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "OK" 
        } 
         
    } 
    catch 
    { 
        $errorMessage = $_.exception.Message 
        if($status) 
        { 
           $errorMessage 
        } 
        $user | Add-Member -MemberType NoteProperty -Name SendMail -Value $errorMessage     
    } 
    $notifiedUsers += $user 
} 
if($logging) 
{ 
    # Create Log File 
    Write-Output "Creating Log File" 
    $day = $today.Day 
    $month = $today.Month 
    $year = $today.Year 
    $date = "$day-$month-$year" 
    $logFileName = "$date-PasswordLog.csv" 
    if(($logPath.EndsWith("\"))) 
    { 
       $logPath = $logPath -Replace ".$" 
    } 
    $logFile = $logPath, $logFileName -join "\" 
    Write-Output "Log Output: $logfile" 
    $notifiedUsers | Export-CSV $logFile 
    if($reportTo) 
    { 
        $reportSubject = "Password Expiry Report" 
        $reportBody = "Password Expiry Report Attached" 
        try { 
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $reportTo -subject $reportSubject -body $reportbody -bodyasHTML -priority High -Encoding $textEncoding -Attachments $logFile -ErrorAction Stop  
        } 
        catch 
        { 
            $error = $_.Exception.Message 
            Write-Output $error 
        } 
    } 
} 
$notifiedUsers | select UserName,Name,EmailAddress,PasswordSet,DaysToExpire,Expireson | sort DaystoExpire | FT -autoSize 
 
$stop = [datetime]::Now 
$runTime = New-TimeSpan $start $stop 
Write-Output "Script Runtime: $runtime" 
# End 