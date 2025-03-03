$Global:CWInfo = [pscustomobject] @{
    Company = 'TheMissingLink'
    User = 'PowerShellAPI_Company'
    Password = 'espy-jean-qQs'
    ServerRoot = 'https://connect.themissinglink.com.au/'
    ImpersonationMember = 'aplatanisiotis'
}

function Get-CWKeys {
    [string] $BaseUri = "$($CWInfo.ServerRoot)" + "v4_6_release/apis/3.0/system/members/$($CWInfo.ImpersonationMember)/tokens"
    [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3"
    [string] $ContentType = "application/json"
    [string] $Authstring = $CWInfo.company + '+' + $CWInfo.user + ':' + $CWInfo.password

    #Convert the user and pass (aka public and private key) to base64 encoding
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    #Create Header
    $header = [Hashtable] @{
        Authorization = ("Basic {0}" -f $encodedAuth)
        Accept        = $Accept
        Type          = "application/json"
        'x-cw-usertype' = "integrator" 
    };

    $body   = "{`"memberIdentifier`":`"$ImpersonationMember`"}"
    
    #execute the the request
    $response = Invoke-RestMethod -Uri $Baseuri -Method Post -Headers $header -Body $body -ContentType $contentType;
    
    #return the results
    return $response;
}  

Function Get-CWTicket {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [INT] $TicketID
    )

    [string] $BaseUri = "$($CWInfo.ServerRoot)" + "v4_6_Release/apis/3.0/service/tickets/$ticketID"
    [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3"
    [string] $ContentType = "application/json"
    [string] $Authstring = $CWInfo.company + '+' + $CWCredentials.publickey + ':' + $CWCredentials.privatekey
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers=@{
        "Authorization"="Basic $encodedAuth"
        }

    $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType $ContentType -Method Get

    If($JSONResponse){Return $JSONResponse}

    Else{Return $False}
}

Function Get-CWUser {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [String] $Username
    )

    [string] $BaseUri = "$($CWInfo.ServerRoot)" + "v4_6_Release/apis/3.0/system/members"
    [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3"
    [string] $ContentType = "application/json"
    [string] $Authstring = "$($CWInfo.Company)+" + $($CWcredentials.publickey) + ':' + $($CWCredentials.privatekey)
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers=@{
        "Authorization"="Basic $encodedAuth"
        }
    <#
    $Body = @{
    "conditions" = "firstname LIKE `"Bob`" AND lastname LIKE `"Marley`" AND company/id = 12345"
    }
    #>
    $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType $ContentType -Body $Body -Method Get

    If($JSONResponse) {
        Return $JSONResponse
    }

    Else {
        Return $False
    }

}

function Get-CWBoardInfo {
    param (
        [string] $BaseUri = "$($CWInfo.ServerRoot)" + "/v4_6_Release/apis/3.0/service/boards",
        [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3",
        [string] $ContentType = "application/json",
        [string] $Authstring = "$($CWInfo.Company)+" + $($CWcredentials.publickey) + ':' + $($CWCredentials.privatekey)
    )

        $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

        $Headers=@{
        "Authorization"="Basic $encodedAuth"
        }

        $Body = @{
        "fields" = "id,name"
        "conditions" = "name LIKE 'SUPPORT'"
        }

        $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Body $Body -Method Get

        If($JSONResponse) {
            Return $JSONResponse
        }

        Else {
            Return $False
        }
}

function New-CWTicket {
    <#
    .SYNOPSIS
        Creates a new ticket on a CW Board.

    .DESCRIPTION
        You pass this function a ticket object and it will create
        a ticket on the proper board.

    .NOTES
        Fields you can customize on the ticket:
            Summary
            Board
            Status
            Company
            Contact

    .EXAMPLE
        New-CWTicket -Ticket $Issue
    #>

    param (
        [Parameter(Mandatory = $True)]
        [Object] $Ticket
    )

    [string] $BaseUri = "$($CWInfo.ServerRoot)" + "/v4_6_Release/apis/3.0/service/tickets"
    [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3"
    [string] $ContentType = "application/json"
    [string] $Authstring = "YOUR_COMPANY+" + $($CWcredentials.publickey) + ':' + $($CWCredentials.privatekey)
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

<#
CW Has restrictions on the summary field about special characters and max length.
I'm removing those characters below and limiting the summary field to 75 characters.
If needed later this field can contain up to 100 characters max.
#>
$Summary = Format-SanitizedString -InputString $Ticket.summary
$Summary = $Summary.Replace('"', "'")
$Summary = $Summary.substring(0,75)

$Body= @"
{
    "summary"   :    "$Summary",
    "board"     :    {"name": "SUPPORT"},
    "status"    :    {"name": "Assigned"},
    "company"   :    {"id": "COMPANY ID"},
    "contact"   :    {"id": "CONTACT ID"}
}
"@


$Headers=@{
"Authorization"="Basic $encodedAuth"
}

    $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers -ContentType $ContentType -Method Post -Body $Body

    If($JSONResponse) {
        Return $JSONResponse
    }

    Else {
        Return $False
    }
}


Function Get-CWCompanies {
    param (
        #[Parameter(Mandatory = $true,Position = 0)]
        #[String]$Username
    )

    [string] $BaseUri = "$($CWInfo.ServerRoot)" + "v4_6_Release/apis/3.0/company/companies?pagesize=1000"
    [string] $Accept = "application/vnd.connectwise.com+json; version=v2015_3"
    [string] $ContentType = "application/json"
    [string] $Authstring = "$($CWInfo.Company)+" + $($CWcredentials.publickey) + ':' + $($CWCredentials.privatekey)
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

    $Headers=@{
        "Authorization"="Basic $encodedAuth"
        }
    $Body = @{
    #"conditions" = "city LIKE PYMBLE"
    }
    $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType $ContentType -Body $Body -Method Get

    If($JSONResponse) {
        Return $JSONResponse
    }

    Else {
        Return $False
    }

}