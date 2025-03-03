#Get full list
Get-CMApplication | Select LocalizedDisplayName, CI_UniqueID

#Search for specific app by ID
Get-CMApplication | Where-Object {$_.CI_UniqueID -like "ScopeId_861B1374-57BE-4C6C-B2A6-73524B005738/Application_267616ca*"} | Select LocalizedDisplayName, CI_UniqueID