#
# Delete_Driver_by_category.ps1
#
$category = read-host
$IDs = Get-CMDriver | where {$_.localizedcategoryinstancenames -like $category}
$count = ($IDs).count
write-host attempting to remove $count drivers
foreach ($ID in $IDs)
{
    remove-CMDriver -id $ID.CI_ID -Force
    write-host = "removing" $ID.LocalizedDisplayName "with Unique ID" $ID.CI_ID "and categories" $id.LocalizedCategoryInstanceNames
}