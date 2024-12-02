# Specify the user's SamAccountName
$UserSamAccountName = "jzutter"

# Get the user object
$User = Get-ADUser -Filter {SamAccountName -eq $UserSamAccountName} -SearchBase "OU=People,DC=corp,DC=edhc,DC=com"

if ($User) {
    # Get the manager's distinguished name
    $ManagerDN = $User.DistinguishedName

    # Get direct reports
    $DirectReports = Get-ADUser -Filter {Manager -eq $ManagerDN}

    if ($DirectReports) {
        Write-Host "Direct reports of $($User.SamAccountName):"
        foreach ($Report in $DirectReports) {
            Write-Host "- $($Report.SamAccountName)"
        }
    } else {
        Write-Host "No direct reports found for $($User.SamAccountName)."
    }
} else {
    Write-Host "User with SamAccountName '$UserSamAccountName' not found."
}
