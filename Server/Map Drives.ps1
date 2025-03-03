<#
.Synopsis
    Map Network Drive via Group Membership
.DESCRIPTION
    This script is used to map network drives based on group membership in the scenario where GPO isn't available.
.EXAMPLE
    Only modify the section below #Map Network Drives, Modify the following below: 
        1. Group Name.
        2. Drive Letter.
        3. Path to Share.
.EXAMPLE
    Another Example of how to use the cmdlet
#>

#Script Name: Map Network Drives.ps1
#Creator: Shayan
#Date: 15/02/2019
#Updated:
#References, if any: 

#Variables

#Parameters

# Queries user account in AD for user group membership

$strName = $env:username

function get-GroupMembership($DNName,$cGroup){
    
    $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"

    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $strFilter

    $objPath = $objSearcher.FindOne()
    $objUser = $objPath.GetDirectoryEntry()
    $DN = $objUser.distinguishedName
        
    $strGrpFilter = "(&(objectCategory=group)(name=$cGroup))"
    $objGrpSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objGrpSearcher.Filter = $strGrpFilter
    
    $objGrpPath = $objGrpSearcher.FindOne()
    
    If (!($objGrpPath -eq $Null)){
        
        $objGrp = $objGrpPath.GetDirectoryEntry()
        
        $grpDN = $objGrp.distinguishedName
        $ADVal = [ADSI]"LDAP://$DN"
    
        if ($ADVal.memberOf.Value -eq $grpDN){
            $returnVal = 1
            return $returnVal = 1
        }else{
            $returnVal = 0
            return $returnVal = 0
    
        }
    
    }else{
            $returnVal = 0
            return $returnVal = 0
    
    }
        
}

# Map network drives

$result = get-groupMembership $strName "Domain Users"
if ($result -eq '1') {
    $(New-Object -ComObject WScript.Network).RemoveNetworkDrive("H:");
    $(New-Object -ComObject WScript.Network).MapNetworkDrive("H:", "\\ShareName");
}

$result = get-groupMembership $strName "Group name"
if ($result -eq '1') {
    $(New-Object -ComObject WScript.Network).RemoveNetworkDrive("I:");
    $(New-Object -ComObject WScript.Network).MapNetworkDrive("I:", "\\ShareName");
} (edited) 