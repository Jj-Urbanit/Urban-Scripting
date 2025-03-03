# https://technet.microsoft.com/en-us/library/dd939928(v=ws.10).aspx
# https://blogs.technet.microsoft.com/heyscriptingguy/2013/04/15/installing-wsus-on-windows-server-2012/

# Connect to vsphere

New-VM `
    -VMHost ausyd1esxi001.cloud.themissinglink.com.au `
    -Name "Windows Server 2016 Standard" `
    -MemoryMB "4096" `
    -NumCpu "2" `
    -DiskGB "80" `
    -DiskStorageFormat Thin `
    -Datastore "Shared" `
    -NetworkName "VLAN0005 Management" `
    -OutVariable
    -Verbose
New-DatastoreDrive -Name ISO -Datastore $(Get-Datastore -Name ISO)
Copy-DatastoreItem -Item C:\Users\aplatanisiotis\Downloads\SW_DVD9_Win_Svr_STD_Core_and_DataCtr_Core_2016_64Bit_English_-2_MLF_X21-22843.ISO -Destination ISO:\ -Verbose
New-CDDrive -VM "Windows Server 2016 Standard" -IsoPath "[ISO] \SW_DVD9_Win_Svr_STD_Core_and_DataCtr_Core_2016_64Bit_English_-2_MLF_X21-22843.ISO" -Verbose
Set-CDDrive -CD (Get-VM -Name "Windows Server 2016 Standard").CDDrives -Connected:$true -StartConnected:$true

Install-WindowsFeature -Name UpdateServices -IncludeManagementTools –WhatIf
New-Item -Path D: -Name WSUS -ItemType Directory
cd "C:\Program Files\Update Services\Tools\"
wsusutil.exe postinstall CONTENT_DIR=D:\WSUS

Invoke-BpaModel -ModelId Microsoft/Windows/UpdateServices
Get-BpaResult -ModelId Microsoft/Windows/UpdateServices | Select Title,Severity,Compliance | Format-List

#Get WSUS Server Object
$wsus = Get-WSUSServer

#Connect to WSUS server configuration
$wsusConfig = $wsus.GetConfiguration()

#Set to download updates from Microsoft Updates
Set-WsusServerSynchronization –SyncFromMU

#Set Update Languages to English and save configuration settings
$wsusConfig.AllUpdateLanguagesEnabled = $false           
$wsusConfig.SetEnabledUpdateLanguages(“en”)           
$wsusConfig.Save()

#Get WSUS Subscription and perform initial synchronization to get latest categories
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()

While ($subscription.GetSynchronizationStatus() -ne ‘NotProcessing’) {
    Write-Host “.” -NoNewline
    Start-Sleep -Seconds 5
}

Write-Host “Sync is done.”

#Configure the Platforms that we want WSUS to receive updates
Get-WsusProduct | 
    where-Object {
        $_.Product.Title -in (
            "Active Directory Rights Management Services Client 2.0",
            "Active Directory",
            "ASP.NET Web and Data Frameworks",
            "ASP.NET Web Frameworks",
            "Category for System Center Online Client",
            "Compute Cluster Pack",
            "Data Protection Manager 2006",
            "Developer Tools, Runtimes, and Redistributables",
            "Device Health",
            "Device Health",
            "Dictionary Updates for Microsoft IMEs",
            "Exchange Server 2010",
            "Exchange Server 2013",
            "Exchange Server 2016",
            "Firewall Client for ISA Server",
            "Local Publisher",
            "Locally published packages",
            "Microsoft Advanced Threat Analytics",
            "Microsoft Advanced Threat Analytics",
            "Microsoft Application Virtualization 4.5",
            "Microsoft Application Virtualization 4.6",
            "Microsoft Application Virtualization 5.0",
            "Microsoft Application Virtualization",
            "Microsoft Azure Information Protection Client",
            "Microsoft Azure Information Protection",
            "Microsoft Azure Site Recovery Provider",
            "Microsoft Azure",
            "Microsoft BitLocker Administration and Monitoring v1",
            "Microsoft BitLocker Administration and Monitoring",
            "Microsoft HealthVault",
            "Microsoft Monitoring Agent (MMA)",
            "Microsoft Monitoring Agent",
            "Microsoft Online Services Sign-In Assistant",
            "Microsoft Online Services",
            "Microsoft Security Essentials",
            "Microsoft SQL Server 2008 R2 - PowerPivot for Microsoft Excel 2010",
            "Microsoft SQL Server 2012",
            "Microsoft SQL Server 2014",
            "Microsoft SQL Server 2016",
            "Microsoft SQL Server PowerPivot for Excel",
            "Microsoft StreamInsight V1.0",
            "Microsoft StreamInsight",
            "Microsoft System Center Data Protection Manager",
            "Microsoft System Center DPM 2010",
            "Microsoft System Center Virtual Machine Manager 2007",
            "Microsoft System Center Virtual Machine Manager 2008",
            "MS Security Essentials",
            "Network Monitor 3",
            "Network Monitor",
            "New Dictionaries for Microsoft IMEs",
            "Office 2013",
            "Office 2016",
            "Office 365 Client",
            "OneCare Family Safety Installation",
            "Photo Gallery Installation and Upgrades",
            "Report Viewer 2005",
            "Report Viewer 2008",
            "Report Viewer 2010",
            "Search Enhancement Pack",
            "Service Bus for Windows Server 1.1",
            "SQL Server 2008 R2",
            "SQL Server 2008",
            "SQL Server 2012 Product Updates for Setup",
            "SQL Server 2014-2016 Product Updates for Setup",
            "SQL Server Feature Pack",
            "System Center 2012 - App Controller",
            "System Center 2012 - Data Protection Manager",
            "System Center 2012 - Operations Manager",
            "System Center 2012 - Orchestrator",
            "System Center 2012 - Virtual Machine Manager",
            "System Center 2012 R2 - Data Protection Manager",
            "System Center 2012 R2 - Operations Manager",
            "System Center 2012 R2 - Orchestrator",
            "System Center 2012 R2 - Virtual Machine Manager",
            "System Center 2012 SP1 - App Controller",
            "System Center 2012 SP1 - Data Protection Manager",
            "System Center 2012 SP1 - Operation Manager",
            "System Center 2012 SP1 - Virtual Machine Manager",
            "System Center 2016 - Data Protection Manager",
            "System Center 2016 - Operations Manager",
            "System Center 2016 - Orchestrator",
            "System Center 2016 - Virtual Machine Manager",
            "System Center Advisor",
            "System Center Configuration Manager 2007",
            "System Center Online",
            "System Center Virtual Machine Manager",
            "System Center",
            "Systems Management Server 2003",
            "Systems Management Server",
            "Threat Management Gateway Definition Updates for Network Inspection System",
            "Windows Defender",
            "Windows Embedded",
            "Windows Next Graphics Driver Dynamic update",
            "Windows Server 2008 R2",
            "Windows Server 2008 Server Manager Dynamic Installer",
            "Windows Server 2008",
            "Windows Server 2012 R2  and later drivers",
            "Windows Server 2012 R2",
            "Windows Server 2012",
            "Windows Server 2016",
            "Windows Server Drivers",
            "Windows Server Manager – Windows Server Update Services (WSUS) Dynamic Installer",
            "Windows Server Solutions Best Practices Analyzer 1.0",
            "Windows Server Technical Preview Language Packs"
        )
    } | 
        Set-WsusProduct

#Configure the Classifications
Get-WsusClassification | 
    Where-Object {
        $_.Classification.Title -in (
            ‘Update Rollups’,
            ‘Security Updates’,
            ‘Critical Updates’,
            ‘Service Packs’,
            ‘Updates’
        )
    } | 
        Set-WsusClassification

#Configure Synchronizations
$subscription.SynchronizeAutomatically=$true

#Set synchronization scheduled for midnight each night
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay=1
$subscription.Save()

#Kick off a synchronization
$subscription.StartSynchronization()