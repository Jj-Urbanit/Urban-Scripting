<#
 	.SYNOPSIS
        An advanced function that gives you a break-down analysis of a user's most recent logon on the machine.
		
    .DESCRIPTION
        This function gives a detailed report on the logon process and its phases.
        Each phase documented have a column for duration in seconds, start time, end time
        and interim delay which is the time that passed between the end of one phase
        and the start of the one that comes after.
		
	.PARAMETER  <UserName <string[]>
		The user name the function reports for. The default is the user who runs the script.
		
	.PARAMETER	<UserDomain <string[]>
		The user domain name the function reports for. The default is the domain name of the user who runs the script.

	.PARAMETER  <HDXSessionId>
		The session id of the user the function reports for. Required for the "HDX Connection" phase.

	.PARAMETER  <CUDesktopLoadTime>
		Specifies the duration of the Shell phase, can be used with ControlUp as passed argument.
    
    .NOTES
        The HDX duration is a new metric that requires changes to the ICA protocol. 
        This means that, if the new version of the client is not being used, the metrics returned are NULL.
        It may take a few seconds until the HDX duration is reported and available at the Delivery Controller.
		
    .LINK
        For more information refer to:
            http://www.controlup.com

    .LINK
        Stay in touch:
        http://twitter.com/nironkoren

    .EXAMPLE
        C:\PS> Get-LogonDurationAnalysis -UserName Rick
		
		Gets analysis of the logon process for the user 'Rick' in the current domain.
#>

#requires -Version 3

function Get-LogonDurationAnalysis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Alias('User')]
        [String]
        $Username = $env:USERNAME,
        [Parameter(Mandatory=$false)] 
        [Alias('Domain')]
        [String]
        $UserDomain = $env:USERDOMAIN,
        [Parameter(Mandatory=$false)] 
        [Alias('HDX')]
        [int]
        $HDXSessionId,
        [int]
        $CUDesktopLoadTime
    )
    begin {
        $Script:Output = @()
        Remove-Variable -Name "LogonStartDate" -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name "EventProperties" -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name "GPAsync" -Scope Script -ErrorAction SilentlyContinue
    function Test-AdminPrivilege { 
	    $windowsPrincipal = New-Object -TypeName System.Security.Principal.WindowsPrincipal `
        ([System.Security.Principal.WindowsIdentity]::GetCurrent())   
	    $ElevatedAdmin = $windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
	    if (!($ElevatedAdmin)) {
		    Throw 'Admin privilege is required, Please run the script from an elevated prompt and with sufficent admin privlieges'
        }
    }
    function Get-PhaseEvent {
        [CmdletBinding()]
        param (
            [ValidateNotNullOrEmpty()]
            [String]
            $PhaseName,
            [ValidateNotNullOrEmpty()]
            [String]
            $StartProvider,
            [ValidateNotNullOrEmpty()]
            [String]
            $EndProvider,
            [ValidateNotNullOrEmpty()]
            [String]
            $StartXPath,
            [ValidateNotNullOrEmpty()]
            [String]
            $EndXPath,
            [int]
            $CUAddition
        )
        try {
            $PSCmdlet.WriteVerbose("Looking $PhaseName Events")
            $StartEvent = Get-WinEvent -MaxEvents 1 -ProviderName $StartProvider -FilterXPath $StartXPath -ErrorAction Stop
            if ($StartProvider -eq 'Microsoft-Windows-Security-Auditing' -and $EndProvider -eq 'Microsoft-Windows-Security-Auditing') {
                $EndEvent = Get-WinEvent -MaxEvents 1 -ProviderName $EndProvider -FilterXPath ("{0}{1}" -f $EndXPath,@"
                and *[EventData[Data[@Name='ProcessId'] 
                and (Data=`'$($StartEvent.Properties[4].Value)`')]] 
"@) # Responsible to match the process termination event to the exact process
            }
            elseif ($CUAddition) {
                Set-Variable -Name EndEvent -Value ($StartEvent | Select-Object -ExpandProperty TimeCreated).AddSeconds($CUAddition)
            }
            else {
                $EndEvent = Get-WinEvent -MaxEvents 1 -ProviderName $EndProvider -FilterXPath $EndXPath
            }
        }
        catch {
            if ($PhaseName -ne 'Citrix Profile Mgmt') {
                if ($StartProvider -eq 'Microsoft-Windows-Security-Auditing' -or $EndProvider -eq 'Microsoft-Windows-Security-Auditing' ) {
                    $PSCmdlet.WriteWarning("Could not find $PhaseName events (requires audit process tracking)")
                }
                else {
                    $PSCmdlet.WriteWarning("Could not find $PhaseName events")
                }
            }
        }
        finally {
            $EventInfo = @{}
            if ($EndEvent) {
                if ((($EndEvent).GetType()).Name -eq 'DateTime') {
                    $Duration = New-TimeSpan -Start $StartEvent.TimeCreated -End $EndEvent
                    $EventInfo.EndTime = $EndEvent
                }
                else {
                    $Duration = New-TimeSpan -Start $StartEvent.TimeCreated -End $EndEvent.TimeCreated
                    $EventInfo.EndTime = $EndEvent.TimeCreated 
                }
            }
            $EventInfo.PhaseName = $PhaseName
            $EventInfo.StartTime = $StartEvent.TimeCreated
            $EventInfo.Duration = $Duration.TotalSeconds
            $PSObject = New-Object -TypeName PSObject -Property $EventInfo
            if ($EventInfo.Duration -and $PhaseName -eq "GP Scripts" -and ($StartEvent.Properties[3]).Value) {
                $Script:Output += $PSObject
            }
            elseif ($EventInfo.Duration -and $PhaseName -eq "GP Scripts") {
                $Script:GPAsync = "{0:N1}" -f $PSObject.Duration
            }
            elseif ($EventInfo.Duration) {
                $Script:Output += $PSObject
            }
        }
    }
    function Get-ODataPhase {
        [CmdletBinding()]
        param (
        )
        try {
            if ($PSBoundParameters.Verbose) {
                $PSCmdlet.WriteVerbose("Looking in registry for OData info")
            }
            $CtxSessionsKey = (Get-ItemProperty HKLM:\SOFTWARE\Citrix\Ica\Session\CtxSessions)
            $DDC = (Get-ItemProperty HKLM:\SOFTWARE\Citrix\VirtualDesktopAgent\State) | Select-Object -ExpandProperty "RegisteredDdcFqdn"
	        }
	    catch {
		    $PSCmdlet.WriteWarning("Could not access registry. $($Error[0].Exception)")
	    }
	    finally {
		    $SessionsIdList = ($CtxSessionsKey | Get-Member -MemberType NoteProperty).Name | Where-Object {$_ -notmatch "PS*"}
	    }
	    if ((($SessionsIdList.GetType()).BaseType).Name -eq "Array") {
		    foreach ($i in $SessionsIdList) {
			    if ($CtxSessionsKey.$i -eq $HDXSessionId) {
				    $SessionKey = $i.Replace('({|})','')
			    }
		    }
	    }
	    else {
		    $SessionKey = $SessionsIdList.Replace('({|})','')
	    }
        try {
            $PSCmdlet.WriteVerbose("Trying to connect to OData")
	        $ODataData = (Invoke-RestMethod -Uri "http://$DDC/Citrix/Monitor/OData/v1/Data/Sessions(guid'$SessionKey')/CurrentConnection" `
            -UseDefaultCredentials).entry.content.properties
	        try {
		        [DateTime]$HDXStartTime = $ODataData.HdxStartDate.'#text'
		        [DateTime]$HDXEndTime = $ODataData.HdxEndDate.'#text'
	        }
	        catch {
		        $PSCmdlet.WriteWarning("No HDX duration records found.`nCheck if the Citrix client have HDX protocol support")
	        }
            finally {
                if (($HDXStartTime) -and ($HDXEndTime)) {
                    [DateTime]$Script:LogonStartDate = $ODataData.LogonStartDate.'#text'
		            $HDXSessionDuraiton = (New-TimeSpan -Start $HDXStartTime -End $HDXEndTime).TotalSeconds
                    $EventInfo = @{}
                    $EventInfo.PhaseName = "HDX Connection"
                    $EventInfo.StartTime = $HDXStartTime.ToLocalTime()
                    $EventInfo.EndTime = $HDXEndTime.ToLocalTime()
                    $EventInfo.Duration = $HDXSessionDuraiton
                    $PSObject = New-Object -TypeName PSObject -Property $EventInfo
                    $Script:Output += $PSObject
                }
            }
        }
        catch {
	        $PSCmdlet.WriteWarning("Could not initiate a connection to $DDC with SessionKey: $SessionKey,`n`
$($Error[0].Exception.Message)`nRequires the user to have `"Read-Only Administrator`" role")
	    }
    }
        Test-AdminPrivilege
        try {
        $LogonEvent = Get-WinEvent -MaxEvents 1 -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath @"
        *[System[(EventID='4624')]] 
        and *[EventData[Data[@Name='TargetUserName'] 
        and (Data=`"$UserName`")]] 
        and *[EventData[Data[@Name='TargetDomainName'] 
        and (Data=`"$UserDomain`")]] 
        and *[EventData[Data[@Name='LogonType'] 
        and (Data=`"2`" or Data=`"10`" or Data=`"11`")]]
        and *[EventData[Data[@Name='ProcessName'] 
        and (Data=`"C:\Windows\System32\svchost.exe`")]]
"@ -ErrorAction Stop
        }
        catch {
            Throw "Could not find Event Id 4624 (Successfully logged on event) in the Windows Security log for user $Username"
        }
        $Logon = New-Object -TypeName PSObject
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name LogonTime -Value $LogonEvent.TimeCreated
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name FormatTime -Value `
        (Get-Date -Date $LogonEvent.TimeCreated -UFormat %r)
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name LogonID -Value ($LogonEvent.Properties[7]).Value
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name WinlogonPID -Value ($LogonEvent.Properties[16]).Value
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name UserSID -Value ($LogonEvent.Properties[4]).Value
        Add-Member -InputObject $Logon -MemberType NoteProperty -Name Type -Value ($LogonEvent.Properties[8]).Value
        $ISO8601Date = Get-Date -Date $Logon.LogonTime
        $ISO8601Date = $ISO8601Date.ToUniversalTime()
        $ISO8601Date = $ISO8601Date.ToString("s")
        $WinlogonStartXpath = @"
        *[System[(EventID='4688')]]
        and *[EventData[Data[@Name='NewProcessId'] 
        and (Data=`'$($Logon.WinlogonPID)`')]] 
        and *[EventData[Data[@Name='NewProcessName'] 
        and (Data='C:\Windows\System32\winlogon.exe')]] 
"@
        $NPStartXpath = @"
        *[System[(EventID='4688')
        and TimeCreated[@SystemTime > '$ISO8601Date']]]
        and *[EventData[Data[@Name='ProcessId'] 
        and (Data=`'$($Logon.WinlogonPID)`')]] 
        and *[EventData[Data[@Name='NewProcessName'] 
        and (Data='C:\Windows\System32\mpnotify.exe')]] 
"@
        $NPEndXPath = @"
        *[System[(EventID='4689')
        and TimeCreated[@SystemTime > '$ISO8601Date']]]
        and *[EventData[Data[@Name='ProcessName'] 
        and (Data=`"C:\Windows\System32\mpnotify.exe`")]] 
"@
        $ProfStartXpath = @"
        *[System[(EventID='10')
        and TimeCreated[@SystemTime > '$ISO8601Date']]]
        and *[EventData[Data and (Data='$UserName')]]
"@
        $ProfEndXpath = @"
        *[System[(EventID='1')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[System[Security[@UserID='$($Logon.UserSID)']]]
"@
        $UserProfStartXPath = @"
        *[System[(EventID='1')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[System[Security[@UserID='$($Logon.UserSID)']]]
"@
        $UserProfEndXPath = @"
        *[System[(EventID='2')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[System[Security[@UserID='$($Logon.UserSID)']]]
"@
        $GPStartXPath = @"
        *[System[(EventID='4001')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[EventData[Data[@Name='PrincipalSamName'] 
        and (Data=`"$UserDomain\$UserName`")]] 
"@
        $GPEndXPath = @"
        *[System[(EventID='8001')
        and TimeCreated[@SystemTime > '$ISO8601Date']]]
        and *[EventData[Data[@Name='PrincipalSamName'] 
        and (Data=`"$UserDomain\$UserName`")]] 
"@
        $GPScriptStartXPath = @"
        *[System[(EventID='4018')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[EventData[Data[@Name='PrincipalSamName'] 
        and (Data=`"$UserDomain\$UserName`")]] 
        and *[EventData[Data[@Name='ScriptType'] 
        and (Data='1')]]
"@
        $GPScriptEndXPath = @"
        *[System[(EventID='5018')
        and  TimeCreated[@SystemTime>='$ISO8601Date']]]
        and *[EventData[Data[@Name='PrincipalSamName'] 
        and (Data=`"$UserDomain\$UserName`")]] 
        and *[EventData[Data[@Name='ScriptType'] 
        and (Data='1')]]
"@
        $UserinitXPath = @"
        *[System[(EventID='4688')
        and TimeCreated[@SystemTime > '$ISO8601Date']]]
        and *[EventData[Data[@Name='ProcessId'] 
        and (Data=`'$($Logon.WinlogonPID)`')]] 
        and *[EventData[Data[@Name='NewProcessName'] 
        and (Data='C:\Windows\System32\userinit.exe')]] 
"@
        $ShellXPath = @"
        *[System[(EventID='4688')
        and TimeCreated[@SystemTime > '$ISO8601Date']]] 
        and *[EventData[Data[@Name='SubjectLogonId'] 
        and (Data=`'$($Logon.LogonID)`')]] 
        and *[EventData[Data[@Name='NewProcessName'] 
        and (Data=`"C:\Program Files (x86)\Citrix\system32\icast.exe`" or Data=`"C:\Windows\explorer.exe`")]]
"@
        $ExplorerXPath = @"
        *[System[(EventID='4688')
        and TimeCreated[@SystemTime > '$ISO8601Date']]] 
        and *[EventData[Data[@Name='SubjectLogonId'] 
        and (Data=`'$($Logon.LogonID)`')]] 
        and *[EventData[Data[@Name='NewProcessName'] 
        and (Data=`"C:\Windows\explorer.exe`")]]
"@
    }
    process {
        if ((Get-Service -Name BrokerAgent -ErrorAction SilentlyContinue) -and ($HDXSessionId)) {
            Get-ODataPhase
        }
        if ($Logon.Type -eq 10) {
            Get-PhaseEvent -PhaseName 'Network Providers' -StartProvider 'Microsoft-Windows-Security-Auditing' `
            -EndProvider 'Microsoft-Windows-Security-Auditing' -StartXPath $NPStartXpath -EndXPath $NPEndXPath
            # Only if OData query succeeded run this block
            if ($Script:LogonStartDate) {
                $SmssPID = ((Get-WinEvent -ProviderName 'Microsoft-Windows-Security-Auditing' -FilterXPath $WinlogonStartXpath `
                -ErrorAction SilentlyContinue).Properties.Value)[7]
                $SMSSStartXpath = @"
                *[System[(EventID='4688')]]
                and *[EventData[Data[@Name='NewProcessId'] 
                and (Data=`'$SmssPID`')]] 
                and *[EventData[Data[@Name='NewProcessName'] 
                and (Data='C:\Windows\System32\smss.exe')]] 
"@
                $SMSSEndXpath = @"
                *[System[(EventID='4689')]]
                and *[EventData[Data[@Name='ProcessId'] 
                and (Data=`'$SmssPID`')]] 
                and *[EventData[Data[@Name='ProcessName'] 
                and (Data='C:\Windows\System32\smss.exe')]] 
"@
                Get-PhaseEvent -PhaseName 'Session Init' -StartProvider 'Microsoft-Windows-Security-Auditing' `
                -EndProvider 'Microsoft-Windows-Security-Auditing' -StartXPath $SMSSStartXpath -EndXPath $SMSSEndXpath
            }
        }
        if (Get-WinEvent -ListProvider 'Citrix Profile management' -ErrorAction SilentlyContinue) {
            Get-PhaseEvent -PhaseName 'Citrix Profile Mgmt' -StartProvider 'Citrix Profile management' `
            -EndProvider 'Microsoft-Windows-User Profiles Service' -StartXPath $ProfStartXpath -EndXPath $ProfEndXpath
        }
        Get-PhaseEvent -PhaseName 'User Profile' -StartProvider 'Microsoft-Windows-User Profiles Service' `
        -EndProvider 'Microsoft-Windows-User Profiles Service' -StartXPath $UserProfStartXPath -EndXPath $UserProfEndXPath
        Get-PhaseEvent -PhaseName 'Group Policy' -StartProvider 'Microsoft-Windows-GroupPolicy' `
        -EndProvider 'Microsoft-Windows-GroupPolicy' -StartXPath $GPStartXPath -EndXPath $GPEndXPath
        Get-PhaseEvent -PhaseName 'GP Scripts' -StartProvider 'Microsoft-Windows-GroupPolicy' `
        -EndProvider 'Microsoft-Windows-GroupPolicy' -StartXPath $GPScriptStartXPath -EndXPath $GPScriptEndXPath 
        Get-PhaseEvent -PhaseName 'Pre-Shell (Userinit)' -StartProvider 'Microsoft-Windows-Security-Auditing' `
        -EndProvider 'Microsoft-Windows-Security-Auditing' -StartXPath $UserinitXPath -EndXPath $ShellXPath
        if ($CUDesktopLoadTime) {
        Get-PhaseEvent -PhaseName 'Shell' -StartProvider 'Microsoft-Windows-Security-Auditing' `
        -StartXPath $ExplorerXPath -CUAddition $CUDesktopLoadTime
        }
        if (($Script:Output).Length -lt 2) {
            $PSCmdlet.WriteWarning("Not enough data for that session, Aborting function...")
            Throw 'Could not find more than a single phase, script is aborted'
        }
        $LogonTimeReal = $Logon.FormatTime
        $Script:Output = $Script:Output | Sort-Object StartTime
        if ($Script:LogonStartDate) {
            $Script:LogonStartDate = $Script:LogonStartDate.ToLocalTime()
            if ($Script:Output[-1].PhaseName -eq "Shell" -or $Script:Output[-1].PhaseName -eq "Pre-Shell (Userinit)") {
                $TotalDur = "{0:N1}" -f (New-TimeSpan -Start $Script:LogonStartDate -End $Script:Output[-1].EndTime `
                | Select-Object -ExpandProperty TotalSeconds) `
                + " seconds"
            }
            else {
                $TotalDur = 'N/A'
            }
            $Deltas = New-TimeSpan -Start $Script:LogonStartDate -End $Script:Output[0].StartTime
            $Script:Output[0] | Add-Member -MemberType NoteProperty -Name TimeDelta -Value $Deltas -Force
            $LogonTimeReal =  (Get-Date -Date $Script:LogonStartDate -UFormat %r)
        }
        else {
            if ($Script:Output[-1].PhaseName -eq "Shell" -or $Script:Output[-1].PhaseName -eq "Pre-Shell (Userinit)") {
            $TotalDur = "{0:N1}" -f (New-TimeSpan -Start $Logon.LogonTime -End $Script:Output[-1].EndTime `
            | Select-Object -ExpandProperty TotalSeconds) `
            + " seconds"
            }
            else {
                $TotalDur = 'N/A'
            }
            $Deltas = New-TimeSpan -Start $Logon.LogonTime -End $Script:Output[0].StartTime
            $Script:Output[0] | Add-Member -MemberType NoteProperty -Name TimeDelta -Value $Deltas -Force
        }
        for($i=1;$i -le $Script:Output.length-1;$i++) {
            $Deltas = New-TimeSpan -Start $Script:Output[$i-1].EndTime -End $Script:Output[$i].StartTime
            $Script:Output[$i] | Add-Member -MemberType NoteProperty -Name TimeDelta -Value $Deltas -Force
        }
    }
    end {
        Write-Output "User name:`t $UserName `
Logon Time:`t $LogonTimeReal `
Logon Duration:`t $TotalDur"
        $Format = @{Expression={$_.PhaseName};Label="Logon Phase"}, `
        @{Expression={'{0:N1}' -f $_.Duration};Label="Duration (s)"}, `
        @{Expression={'{0:hh:mm:ss.f}' -f $_.StartTime};Label="Start Time"}, `
        @{Expression={'{0:hh:mm:ss.f}' -f $_.EndTime};Label="End Time"}, `
        @{Expression={'{0:N1}' -f ($_.TimeDelta | Select-Object -ExpandProperty TotalSeconds)};Label="Interim Delay"}
        $Script:Output | Format-Table $Format -AutoSize
        if ($Script:GPAsync) {
        "Group Policy asynchronous scripts were processed for $Script:GPAsync seconds"
        }
    }
}