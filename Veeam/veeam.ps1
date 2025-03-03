$CloudTenantsresponse = $null
$JobsQueryresponse = $null
$User = "svc_veeam"
$Password = #
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force 
$Credentials = New-Object -TypeName System.Management.Automation.PScredential ($User, $SecurePassword)
$AuthQuery = @{
    uri = "http://ausyd1vmgmt001.cloud.themissinglink.com.au:9399/api/sessionMngr/?v=v1_2";
    Method = 'POST';
} 
$AuthKey = Invoke-WebRequest @AuthQuery -Credential $Credentials

$CloudTenantsQuery = @{
    uri = "http://ausyd1vmgmt001.cloud.themissinglink.com.au:9399/api/cloud/tenants";
    Method = 'GET';
    Headers = @{'X-RestSvcSessionId' = $AuthKey.Headers['X-RestSvcSessionId'];
    } 
}

$JobsQuery = @{
    uri = "http://ausyd1vmgmt001.cloud.themissinglink.com.au:9399/api/logonSessions";
    Method = 'GET';
    Headers = @{'X-RestSvcSessionId' = $AuthKey.Headers['X-RestSvcSessionId'];
    } 
}

#$CloudTenantsresponse = invoke-restmethod @CloudTenantsQuery
#$CloudTenantsresponse.EntityReferences.Ref

$JobsQueryresponse = invoke-restmethod @jobsQuery
$JobsQueryresponse.EntityReferences.Ref