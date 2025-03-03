# The -properties filter is necessary because Get-ADGroup does not expose the Description field by default. 
# It will output to the grid, which can be copied to a spreadsheet. 

Get-ADGroup -filter * -properties * | ft name,groupcategory,description | Out-File C:\temp\groupsnames.csv