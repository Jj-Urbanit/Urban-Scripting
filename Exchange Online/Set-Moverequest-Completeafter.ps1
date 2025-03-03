#
# Set_Moverequest_Completeafter.ps1
#
$migrationbatchname = read-host -prompt "enter the migration batch name"
$migrationbatchnameexist = Get-migrationbatch
if (!((($migrationbatchnameexist|Select-Object -ExpandProperty Identity).name) -contains $migrationbatchname))
{
    write-host "migration batch name is incorrect. Please check and try again"
    exit
}
$users = get-migrationuser -BatchId $migrationbatchname
foreach ($user in $users)
{
    #Set-MoveRequest -Identity $user.identity -CompleteAfter (Get-Date "31/01/2018 2:00 AM").ToUniversalTime()
    Get-MoveRequest -Identity $user.Identity | Get-MoveRequestStatistics
}