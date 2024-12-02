# Retrieve all users in the specified Organizational Unit
$Users = Get-ADUser -Filter * -SearchBase "OU=People,DC=corp,DC=edhc,DC=com" -Properties proxyAddresses, UserPrincipalName

# Initialize arrays to hold Lanterncare and EDHC primary SMTP addresses
$PrimarySMTPLanterncare = @()
$PrimarySMTPEDHC = @()

# Loop through each user
foreach ($User in $Users) {
    $ProxyAddresses = $User.proxyAddresses

    # Check if proxy addresses are available
    if ($ProxyAddresses) {
        # Filter and capture the primary SMTP address for each domain
        $PrimarySMTPLanterncare += $ProxyAddresses | Where-Object { $_ -cmatch '^SMTP:.*@lanterncare\.com$'} |   ForEach-Object { $_ -replace "^SMTP:", "" }
        $PrimarySMTPEDHC += $ProxyAddresses | Where-Object { $_ -cmatch '^SMTP:.*@edhc\.com$' } |   ForEach-Object { $_ -replace "^SMTP:", "" }
    } else {
        # If no proxy addresses, add UserPrincipalName based on the domain
        if ($User.UserPrincipalName -match '@lanterncare\.com$') {
            $PrimarySMTPLanterncare += $User.UserPrincipalName
        } elseif ($User.UserPrincipalName -match '@edhc\.com$') {
            $PrimarySMTPEDHC += $User.UserPrincipalName
        }
    }
}

# Output results
Write-Host "Lanterncare emails:" -ForegroundColor Red
$PrimarySMTPLanterncare | ForEach-Object { Write-Host $_ }

Write-Host "EDHC emails:" -ForegroundColor Red
$PrimarySMTPEDHC | ForEach-Object { Write-Host $_ }
