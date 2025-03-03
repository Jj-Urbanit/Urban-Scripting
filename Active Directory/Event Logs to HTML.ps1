clear-host
#System Event Log Query
$SystemEvents = '<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(Level=1  or Level=2) and TimeCreated[timediff(@SystemTime) &lt;= 2592000000]]]</Select>
    <Suppress Path="System">*[System[(EventID=36874 or EventID=3 or EventID=36887 or EventID=10016 or EventID=6008 or EventID=1006 or EventID=7023 or EventID=7031 or EventID=7032)]]</Suppress>
  </Query>
</QueryList>'
#App Log Query
$ApplicationEvents = '<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1  or Level=2) and TimeCreated[timediff(@SystemTime) &lt;= 2592000000]]]</Select>
    <Suppress Path="Application">*[System[(EventID=0 or EventID=216 or EventID=505 or EventID=1511 or EventID=513 or EventID=1008 or EventID=8001 or EventID=5973 or EventID=4999 or EventID=1023 or EventID=2004)]]</Suppress>
  </Query>
</QueryList>'

$ServerToCheck = @('BUD-DC-02','BUD-DC-03','BUD-ACCOUNTING','BUD-MERLIN','BUD-PRINT-01')

$path = "C:\Scripts\Event Logs\"

Function GenerateLogs
{   Param(
        [Parameter(Mandatory=$True)] [String]$ServerName,
        [Parameter(Mandatory=$True)] [String]$QueryName,
        [Parameter(Mandatory=$True)] [String]$LogName)
    $LogFileName = "$path\EventLogs $pattern - $ServerName - $LogName.html"
    Get-WinEvent -ComputerName ${ServerName} -FilterXML ${QueryName} -ErrorAction SilentlyContinue | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message |Convertto-html | Out-file $LogFileName
}

#Maitneance - Clear last logs
Get-ChildItem -Path $path *.html | foreach { Remove-Item -Path $_.FullName }
Get-ChildItem -Path $path *.txt | foreach { Remove-Item -Path $_.FullName }

#Set Flag for if errors occur
$ErrorCheck = $False
$ErrorLogFileName = "$Path\Error Log for Event Log HTML Reports.txt"

#Generate Logs for Each Server
foreach($Server in $ServersToCheck){
    try
    {
      GenerateLogs -ServerName $Server -QueryName $SystemEvents -LogName 'SystemEvents'
      GenerateLogs -ServerName $Server -QueryName $ApplicationEvents -LogName 'ApplicationEvents'
    }
    Catch
    {
      $ErrorCheck = $true
      $ServerError = $_.Exception.Message
      $ErrorLog = "Error with ${Server}:  + $ServerError"
      Add-Content -path $ErrorLogFileName -Value $ErrorLog
    }
}
