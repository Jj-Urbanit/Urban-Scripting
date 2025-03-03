$EnabledADUsers = $null
$DisabledADUsers = $null

$CrackedAccounts = @(
    'amiller',
    'pazoury_admin',
    'jgunning',
    'scunningham',
    'pselby',
    'hferguson',
    'kperez',
    'eferguson_admin',
    'ccallister',
    'dward',
    'ddorotheou',
    'bhawkins',
    'rbereny',
    'mogrady',
    'bsewell',
    'ncativo',
    'cmiller',
    'scoffey',
    'ksingh',
    'phany',
    'zboyadjian',
    'baskeydoran',
    'mduncan',
    'rdelautour',
    'mgummerson',
    'ibm_test1',
    'aleave',
    'Guest',
    'linkroom',
    'SM_a8a6432fe6b143989',
    'SM_13f97bbf5f3e49e4a',
    'SM_aca0004da65d4c499',
    'SM_9a1384d46acf45739',
    '$E93000-584HDVF2KUQ7',
    'SM_16dd819725c14bcca',
    'SM_d24584ffc41648ecb',
    'techroom',
    'marketingcalendar',
    'Alex',
    'SM_492a611b4b8e4c579',
    'SmartPATH',
    'securityprojects',
    'faxes',
    'aunic',
    'licensing',
    'purchaseorder',
    'svc_exclaimer',
    'security.helpdesk',
    'documents',
    'backup',
    'tibrademo',
    'mfranklin',
    'reception'
)

$ADUsers = @()

Foreach ($CrackedAccount in $CrackedAccounts) {
    $ADUsers += Get-ADUser -Identity $CrackedAccount -Properties *
}

$EnabledADUsers = $ADUsers | ?{$_.enabled -eq $true}

$DisabledADUsers = $ADUsers | ?{$_.enabled -eq $false}

$DisabledADUsers.DistinguishedName  | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $(New-RandomPassword -MinPasswordLength 16) -Force -Verbose) 