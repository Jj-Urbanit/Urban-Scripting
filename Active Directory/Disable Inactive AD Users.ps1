#Wintel-AD-Disable Active Directory User:

#for single:
Import-Module ActiveDirectory
Disable-ADAccount -Identity user1



#for bulk:

#imports active directory module to only corrent session as it is related to AD
Import-Module ActiveDirectory

#Takes input from users.csv file into this script
Import-Csv "C:\Users.csv" | ForEach-Object {

    #assign input value to variable-samAccountName 
    $samAccountName = $_."samAccountName"

    #get-aduser will retrieve samAccountName from domain users. if we found it will disable else it will go to catch
    try { Get-ADUser -Identity $samAccountName |
        Disable-ADAccount  
    }

    #It will run when we can't find user
    catch {
        #it will display the message
        Write-Host "user:"$samAccountname "is not present in AD"
    }
}