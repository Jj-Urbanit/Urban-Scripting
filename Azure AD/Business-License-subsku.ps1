#
# Business-License_subsku.ps1
#
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-msolservice -Credential $UserCredential
#Function Set-BusinessLicenseOption
#{
  $AccountSkuId = (Get-MsolAccountSku | Where-Object {$_.AccountSkuID -like "*Business*"}).AccountSkuID
  #change it to All
  $LicensedUsers = (Get-MsolUser -all | Where-Object { $_.IsLicensed -eq $true } | Select-Object UserPrincipalName)
	ForEach ($User in $LicensedUsers) 
  {
    $Upn = $User.UserPrincipalName
	$AssignedLicenses = (Get-MsolUser -UserPrincipalName $Upn).Licenses
    $MICROSOFTBOOKINGS = "Disabled";
	$FORMS_PLAN_E1 = "Disabled";
	$FLOW_O365_P1 = "Disabled";
    $POWERAPPS_O365_P1 = "Disabled";
    $O365_SB_Relationship_Management = "Disabled";
    $TEAMS1 = "Disabled";
    $PROJECTWORKMANAGEMENT = "Disabled";
    $SWAY = "Disabled";
    $INTUNE_O365 = "Disabled";
    $SHAREPOINTWAC = "Disabled";
    $OFFICE_BUSINESS = "Disabled";
    $YAMMER_ENTERPRISE = "Disabled";
    $EXCHANGE_S_STANDARD = "Disabled";
    $MCOSTANDARD = "Disabled";
    $SHAREPOINTSTANDARD = "Disabled";
      ForEach ($License in $AssignedLicenses) 
      {
          If ($License.AccountSkuId -eq "$AccountSkuId") 
          {       
              ForEach ($ServiceStatus in $License.ServiceStatus) 
              {
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "MICROSOFTBOOKINGS" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $MICROSOFTBOOKINGS = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "FORMS_PLAN_E1" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $FORMS_PLAN_E1 = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "POWERAPPS_O365_P1" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $POWERAPPS_O365_P1 = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "TEAMS1" -and ($ServiceStatus.ProvisioningStatus -ne "Disabled" -or $ServiceStatus.ProvisioningStatus  -ne "PendingProvisioning") ) { $TEAMS1 = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "PROJECTWORKMANAGEMENT" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $PROJECTWORKMANAGEMENT = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "SWAY" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $SWAY = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "INTUNE_O365" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $INTUNE_O365 = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "YAMMER_ENTERPRISE" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $YAMMER_ENTERPRISE = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "O365_SB_Relationship_Management" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $O365_SB_Relationship_Management = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "FLOW_O365_P1" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $FLOW_O365_P1 = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "OFFICE_BUSINESS" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $OFFICE_BUSINESS = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "MCOSTANDARD" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $MCOSTANDARD = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTWAC" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $SHAREPOINTWAC = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTSTANDARD" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $SHAREPOINTSTANDARD = "Enabled" }
                  If ($ServiceStatus.ServicePlan.ServiceName -eq "EXCHANGE_S_STANDARD" -and $ServiceStatus.ProvisioningStatus -ne "Disabled") { $EXCHANGE_S_STANDARD = "Enabled" }
              }
              $DisabledOptions = @()
              If ($MICROSOFTBOOKINGS -eq "Disabled") { $DisabledOptions += "MICROSOFTBOOKINGS" }
              #If ($FORMS_PLAN_E1 -eq "Disabled") { $DisabledOptions += "FORMS_PLAN_E1" }
              If ($POWERAPPS_O365_P1 -eq "Disabled") { $DisabledOptions += "POWERAPPS_O365_P1" }
              If ($TEAMS1 -eq "Disabled") { $DisabledOptions += "TEAMS1" }
              If ($PROJECTWORKMANAGEMENT -eq "Disabled") { $DisabledOptions += "PROJECTWORKMANAGEMENT" }
              If ($SWAY -eq "Disabled") { $DisabledOptions += "SWAY" }
              If ($INTUNE_O365 -eq "Disabled") { $DisabledOptions += "INTUNE_O365" }
              If ($YAMMER_ENTERPRISE -eq "Disabled") { $DisabledOptions += "YAMMER_ENTERPRISE" }
              If ($O365_SB_Relationship_Management -eq "Disabled") { $DisabledOptions += "O365_SB_Relationship_Management" }
              If ($FLOW_O365_P1 -eq "Disabled") { $DisabledOptions += "FLOW_O365_P1" }
              #If ($OFFICE_BUSINESS -eq "Disabled") { $DisabledOptions += "OFFICE_BUSINESS" }
              #If ($MCOSTANDARD -eq "Disabled") { $DisabledOptions += "MCOSTANDARD" }
              #If ($SHAREPOINTWAC -eq "Disabled") { $DisabledOptions += "SHAREPOINTWAC" }
              #If ($SHAREPOINTSTANDARD -eq "Disabled") { $DisabledOptions += "SHAREPOINTSTANDARD" }
              #If ($EXCHANGE_S_STANDARD -eq "Disabled") { $DisabledOptions += "EXCHANGE_S_STANDARD" }
              $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans $DisabledOptions
              Set-MsolUserLicense -User $Upn -LicenseOptions $LicenseOptions
          }
      }
  }
#}

#get-msoluser | set-businesslicenseoption