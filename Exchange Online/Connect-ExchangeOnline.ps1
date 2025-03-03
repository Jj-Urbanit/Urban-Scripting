function Connect-EMS 
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateSet("The Missing Link Network Intergration Pty Ltd", "The Missing Link Network Intergration Pty Ltd - Office 365")]
        $Company
    )
    Begin 
    {}

    Process 
    {
        switch ($Company)
        {
            'The Missing Link Network Intergration Pty Ltd' 
            {
                $Credentials = Get-Credential
                $global:TMLOPS = New-PSSession `
                    -ConfigurationName Microsoft.Exchange `
                    -ConnectionUri http://TML-XCH-MB01/PowerShell/ `
                    -Credential $Credentials `
                    -Authentication Basic -AllowRedirection
                Import-PSSession $global:TMLOPS              
            }

            'The Missing Link Network Intergration Pty Ltd - Office 365' 
            {
                $Credentials = Get-Credential
                $global:TMLO365S = New-PSSession `
                    -ConfigurationName Microsoft.Exchange `
                    -ConnectionUri https://ps.outlook.com/powershell/ `
                    -Credential $Credentials `
                    -Authentication Basic -AllowRedirection
                Import-PSSession $global:TMLO365S                
            }

            Default 
            {}
        }

    }
    End 
    {}
}