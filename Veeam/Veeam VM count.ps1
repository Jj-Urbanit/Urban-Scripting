Import-Module SQLPS -ErrorAction Stop
Set-Location SQLSERVER:\sql\sisydsvr02\veeamsql2012\databases
(Invoke-Sqlcmd -Query "SELECT COUNT(id) FROM [VeeamBackup].[dbo].[Backup.Model.LicensedVms]").Column1