#Install Microsoft Teams PowerShell Module
Install-Module -Name MicrosoftTeams   
Import-Module –Name MicrosoftTeams  
Connect-MicrosoftTeams  

#Connect by providing specific credentials
$Cred=Get-Credential 
Connect-MicrosoftTeams –Credential $Cred 

#Get all commands from the cmdlet
Get-Command –Module MicrosoftTeams 

#Disconnect
Disconnect-MicrosoftTeams 

#Create and Manage Teams
New-Team –DisplayName <TeamName> 
Set-Team -GroupId <TeamId> -Description "Teams description updated" -Visibility "Public"  

#Add Members to Team
Add-TeamUser -GroupId <TeamId> -User <UPN>  
Add-TeamUser -GroupId <TeamId> -User <UPN> -Role Owner  

#Remove Users from Teams
Remove-TeamUser –GroupId <teams groupid> -User <MemberUPN>
#Removed from owner role in Project Team.
Remove-TeamUser –GroupId <ProjectTeams id> -User John@contoso.com -Role Owner 
#Removed from Project Team 
Remove-TeamUser –GroupId <ProjectTeams id> -User John@contoso.com 

#Create Channel in Teams
New-TeamChannel -GroupId <Teams groupid> -DisplayName <ChannelName>  
New-TeamChannel -GroupId 126b90a5-e65a-4fef-98e3-d9b49f4acf12 -DisplayName "Confidential" -MembershipType Private  

#Add Members to Teams Private Channel
Add-TeamChannelUser –GroupId <TeamId> -DisplayName <PrivateChannelName> -User <UPN>  
Add-TeamChannelUser –GroupId <TeamId> -DisplayName <PrivateChannelName> -User <UPN> -Role <Owner>

#Remove Members from Private Channel
Remove-TeamChannelUser –GroupId <teams groupid> -User <OwnerUPN> -Role Owner  
Remove-TeamChannelUser –GroupId <teams groupid> -User <MemberUPN> 

#Archive Team
Set-TeamArchivedState –GroupId <Team id> -Archived $true  
Set-TeamArchivedState –GroupId <Team id> -Archived $false  

#Delete Teams and Channels
Remove-Team –GroupId <teams groupid> 
Remove-TeamChannel –GroupId <teams groupid> - DisplayName <ChannelName>  

