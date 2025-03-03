<#
"accounts","service desk" | Get-LicenseAudit | Export-Csv C:\temp\$($(get-date).year)$($(get-date).month).csv -NoTypeInformation
#>
Function Get-LicenseAudit{ # Do "accounts","service desk" | AP-Get-LicenseAudit -Verbose -OutVariable variable -- then work with the variable
    [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    Param(

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,16)]
        [Alias("name")] 
        [string[]]$Username = $null,

        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,126)]
        [Alias("group")] 
        [string[]]$Groupname = $null,

        [switch]$count

    )
    Begin{}
    Process{

            # Collect all the groups, with all of their properties
            $AllGroupsAndProperties = Get-ADGroup -Filter * 

            # Create an empty array
            $AllGroupsObjectArray = @()

            # Enumerate through all of the group properties 
            foreach ($AllGroups in $AllGroupsAndProperties) {

                # Add the name and distinguished name of each grou tp the $AllGroupsObject object
                $AllGroupsObject = New-Object -TypeName PSObject -Property @{
                    'name' = $AllGroups.Name
                    'DistinguishedName' = $AllGroups.DistinguishedName
                }

                # Add each object to the array
                $AllGroupsObjectArray += $AllGroupsObject
            }

            # Collect all the distinguished names of the groups, from the array
            $DistinguishedName = $AllGroupsObjectArray | ?{$_.name -eq $Groupname} | select DistinguishedName 
            
            try {
                # Create an empty array
                $UserArray = @()

                # collect all users, and the SAM/ memberof properties
                $UserArray += Get-ADUser -Filter * -Properties Name, LastLogonDate, SamAccountName, memberof | select Name, SamAccountName, memberof 

                # Collect all the users who are disabled although logged in last month
                # Modified this wotuhout test, check if it's broken
                $UserArray += Get-ADUser -Filter * -Properties Name, LastLogonDate, SamAccountName, memberof | 
                    ?{$_.Enabled -eq $false -and 
                      $_.LastLogonDate.month -eq $(get-date).Month -and
                      $_.LastLogonDate.Year -eq $(get-date).Year}

            } Catch {
                # writer a warning if there was an issue with the filter finding a user name 
                Write-Warning "Unable to find user name under Filter" 

            }
            
            # From the collected array of users in the Try block, get each user in $userObject (it's actually a collection not an array) 
            # Put the results in to the usernameandgrouparray variable 
            $UserNameAndGroupArray = foreach ($UserObject in $UserArray){

                # Foreach each of the groups listed in the expanded results of memberof 
                foreach ($GroupObject in $UserObject.memberof){

                    # Create a new object to store the group name plus the user name
                    # This will output more than 1 object for each user. Each group with have it's own object for readibility and so we can count
                    $UserNameAndGroupObject = New-Object -TypeName PSObject -Property @{
                    'Name' = $UserObject.Name 
                    'UserName' = $UserObject.SamAccountName
                    'Group' = $GroupObject
                    }

                    # Can't remember why I have this here 
                    # Possible issue with the loop I believe??? FUCK 
                    $UserNameAndGroupObject
                }

            }

            switch ($Count){

                # if you specified to use the switch, do the below
                $true {

                    # Filter the collection to only contain the groups required
                    $FilteredUserNameAndGroupArray = $UserNameAndGroupArray | ?{$_.group -contains $DistinguishedName.DistinguishedName.ToString()} 

                    # Create a new object to display the contents of the totals and the counts
                    # accounts team couldn't care less about the specific users, that's for the account manager 
                    $CountObject = New-Object -TypeName PSObject -Property @{
                    'Group' = $Groupname
                    'License Count' = $($($FilteredUserNameAndGroupArray | measure).count)
                    }
                }

                # Default output if $true isn't specified or if count isn't even listed as it's a switch 
                Default {
                    
                    # Filter the collection to only contain the groups required
                    $FilteredUserNameAndGroupArray = $UserNameAndGroupArray | ?{$_.group -contains $DistinguishedName.DistinguishedName.ToString()} 

                    # Modify the Group name to be a Name, and not DistinguishedName as it looks horrible for normal use
                    $FilteredUserNameAndGroupArray | select -Property Name, Username, @{n="Group";e={$Groupname}} 
                }
            }

            # End out put 
            $CountObject
            Write-Verbose "TOTAL USERS : $($($UserArray | measure).count)"
            Write-Verbose "GROUP NAME  : $Groupname"
            Write-Verbose "TOTAL USERS in $Groupname : $($($FilteredUserNameAndGroupArray | measure).count)" # Count how many users are in this group

    }#Process

    End{
    }#End

}

Function AP-Get-SPLAAudit 
{

# Use switches for each group, and a function for task, All, SPLA_Microsoft... 
# Use a switches for each task ie. Count/ List
    
}


