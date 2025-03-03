$DaysToShow = (Get-Date).AddDays(-1)
$EventIDs = 4740,4728,4732,4756,4735,4624,4625,4648,4663,4929,4928
$EventProvider = "Security"

Write-Progress -activity "Gathering events ..."
$Events = Get-WinEvent -Computername localhost -FilterHashtable @{Logname=$EventProvider;Id=$EventIDs;starttime=$DaysToShow} -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

[int]$count = $Events.Count
$j = 0
# Parse out the event message data            
ForEach ($Event in $Events) {            
	# Convert the event to XML            
	$eventXML = [xml]$Event.ToXml()            
	# Iterate through each one of the XML message properties            
	if($event.Id -eq '4624'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "An account was successfully logged on."}
	if($event.Id -eq '4648'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A logon was attempted using explicit credentials."}
	if($event.Id -eq '4740'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A user account was locked out."}
	if($event.Id -eq '4728'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A member was added to a security-enabled local group."}
	if($event.Id -eq '4732'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A member was added to a security-enabled local group."}
	if($event.Id -eq '4756'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A member was added to a security-enabled local group."}
	if($event.Id -eq '4735'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "A security-enabled local group was changed."}
	if($event.Id -eq '4625'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "An account failed to log on."}
	if($event.Id -eq '4663'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "The user and logon session that performed the action."}
	if($event.Id -eq '4628'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "DCShadow. Active Directory replica source naming context established"}
	if($event.Id -eq '4629'){ Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "EventMessage" -Value "DCShadow. Active Directory replica source naming context removed."}

	For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {       
		# Append these as object properties            
		Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'           
	} 
	Write-Progress -activity "Processing events ..." -status "Status: $j of $count" -PercentComplete (($j / $count)*100)
	$j++
} 
Write-Progress -activity "Output events ..."
$Events | Select-Object TimeCreated,ProcessId,EventMessage,TaskDisplayName,LogonType,LogonProcessName,AuthenticationPackageName,LmPackageName,SubjectUserSid,SubjectUserName,SubjectDomainName,SubjectLogonId,TargetUserSid,TargetUserName,TargetDomainName,Status,FailureReason,WorkstationName,ProcessName,IpAddress,IpPort,Id,ProviderName,LogName,ThreadId,MachineName,UserId,ActivityId | Out-GridView