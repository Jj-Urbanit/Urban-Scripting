#
# Delete_package_orphaned_drivers.ps1
#

#Declare Arrays
$ActiveDrivers = @()
$RemovedDrivers = @()
$InactiveDrivers = @()

#Populate 'Inactive' driver array with all drivers
$InactiveDrivers = Get-CMDriver

#Iterate through each package, dump associated drivers to an array of active\associated drivers
Foreach ($Pkg in Get-CMDriverPackage){
    $drivers = Get-CMDriver -DriverPackageId $Pkg.PackageID
    Write-Host $drivers.count "|" $Pkg.Name
    Foreach ($driver in $drivers){
        $ActiveDrivers += $driver
    }
}
#Metrics
Write-Host $ActiveDrivers.Count "Active Drivers"
Write-Host $InactiveDrivers.Count "Total Drivers"
Write-Host "Estimated Drivers to remove:" ($InactiveDrivers.Count - $ActiveDrivers.Count)

#Take all drivers in the active driver array and compare against all drivers to get the unassociated ones.
$RemovedDrivers = Compare-Object $InactiveDrivers $ActiveDrivers -Property CI_UniqueID,ModelID -PassThru
Write-Host "Actual Drivers to remove:" $RemovedDrivers.Count

#Loop through & delete drivers
Foreach ($driver in $RemovedDrivers){
    Remove-CMDriver -Id $driver.CI_ID -Force
}