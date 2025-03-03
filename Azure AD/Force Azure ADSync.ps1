#To Be run on the server that has the Azure ADSync tools installed. Normally it would be recommended to run both. 
#It will take under 5 minutes to run both unless in very large AD environments.  
Import-Module ADSync

#To run a full sync
Start-ADSyncSyncCycle -PolicyType Initial

#To run a Delta sync
Start-ADSyncSyncCycle -PolicyType Delta