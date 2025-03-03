$UserList = Import-csv -path 'c:\Temp\UsersToImport.csv'

ForEach ($User in $UserList){
    $UPNToCheck = $User.UPN
    $NumberToAssign = $User.Landline

    #Test Code
    Write-Output "~~~~     ~~~~ "
    Write-Output "User: $UPNToCheck  Assigned Phone Number: $NumberToAssign"

    #Assign number to user along with required parameters
    $identity = $UPNToCheck
    $phonenumber = "+$NumberToAssign"
    Set-CsPhoneNumberAssignment -Identity $identity -PhoneNumber $phonenumber -PhoneNumberType DirectRouting
    Grant-CsOnlineVoiceRoutingPolicy -Identity $identity -PolicyName Australia
    Grant-CsTenantDialPlan -Identity $identity -PolicyName 'AU-NSW-ACT-DP'
    Write-Output "~~~~     ~~~~ "
    #update User in Office
    Set-AzureADUser -ObjectId $UPNToCheck -TelephoneNumber $phonenumber
}