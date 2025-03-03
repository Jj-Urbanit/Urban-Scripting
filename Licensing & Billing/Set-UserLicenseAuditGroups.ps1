Function Set-UserLicenseAuditGroups
{
    # Get Domain information
    $DomainInformationObject = Get-ADDomain

    # Create the OU 
    New-ADOrganizationalUnit `
        -Name:"SPLA" `
        -Path:"$($DomainInformationObject.DistinguishedName)" `
        -ProtectedFromAccidentalDeletion:$true -Server:"$($DomainInformationObject.InfrastructureMaster)" `
        -Description "Organisational Unit for the Security Groups used for The Missing Link SPLA Licensing" `
        -Verbose
    Set-ADObject `
        -Identity:"OU=SPLA,$($DomainInformationObject.DistinguishedName)" `
        -ProtectedFromAccidentalDeletion:$true `
        -Server:"$($DomainInformationObject.InfrastructureMaster)" `
        -Verbose

    # Create The Security Groups
    $SecurityGroupArray = 
        @(
        "SPLA_Windows Remote Desktop Services",
        "SPLA_Microsoft Office Standard",
        "SPLA_Microsoft Office Pro Plus",
        "SPLA_Microsoft Visio Standard",
        "SPLA_Microsoft Project Standard",
        "SPLA_Exchange Server Standard",
        "SPLA_Exchange Server Enterprise",
        "SPLA_Microsoft SQL Server Standard Core",
        "SPLA_Microsoft SQL Server Standard",
        "SPLA_SharePoint Server Standard",
        "SPLA_Webroot - Endpoint Protection",
        "SPLA_Webroot - Web Security Service",
        "SPLA_Citrix XenApp Base",
        "SPLA_Citrix XenApp Platinum",
        "SPLA_N-Central Monitoring Agent"
        )
    foreach ($SecurityGroupString in $SecurityGroupArray) 
    {
        New-ADGroup `
            -GroupCategory:"Security" `
            -GroupScope:"Global" `
            -Name:"$SecurityGroupString" `
            -Path:"OU=SPLA,$($DomainInformationObject.DistinguishedName)" `
            -SamAccountName:"$SecurityGroupString" -Server:"$($DomainInformationObject.InfrastructureMaster)" `
            -Description "Security Group used for The Missing Link SPLA Licensing" `
            -Verbose
        Set-ADObject `
            -Identity:"CN=$SecurityGroupString,OU=SPLA,$($DomainInformationObject.DistinguishedName)" `
            -ProtectedFromAccidentalDeletion:$true `
            -Server:"$($DomainInformationObject.InfrastructureMaster)" `
            -Verbose
    }

}