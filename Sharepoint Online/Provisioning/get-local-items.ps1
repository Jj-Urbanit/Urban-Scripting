#
# get_local_items.ps1
#
# If folder structure to be used to create libraries, this script gets relevant info directly to be manipulated in provisioning scripts. Directory name for library name and folder path for path to copy content from
Get-ChildItem | select name,fullname | export-csv -path .\temp.csv -NoTypeInformation