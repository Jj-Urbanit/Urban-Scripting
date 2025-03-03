#
# Get-Allsessions.ps1
#

#Get all collections and return how many sessions on each session host (currently only session collections, not desktop collections

$collections = get-rdsessioncollection
foreach ($collection in $collections) {
    $sesshosts = get-rdsessionhost -CollectionName $collection.CollectionName
    write-host ===================================================
    write-host Current Collection Name is $collection.CollectionName
    ForEach ($sesshost in $sesshosts){
        $count = (Get-RDUserSession -CollectionName $collection.CollectionName | where {$_.hostserver -eq $sesshost.Sessionhost}).count
        write-host ___________________________________________________
        write-host Session Host $sesshost.Sessionhost has $count current sessions
    }
}