# Import the Active Directory module
Import-Module ActiveDirectory

# Define the root OU
$rootOU = "OU=People,DC=corp,DC=edhc,DC=com"
$CurrentDate= Get-Date -Format "dd-MM-yyyy-HH-mm"

# Define the CSV file path
$csvFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Backups\CurrentActiveUsers$CurrentDate.csv"

# Retrieve all user accounts from the specified OU and its sub-OUs
$userAccounts = Get-ADUser -Filter * -SearchBase $rootOU -SearchScope Subtree -Property *

# Prepare an array to hold user data
$userData = @()

# Loop through the user accounts
foreach ($user in $userAccounts) {
$CurrentProxy= $User.proxyAddresses

    # Add the user's information and manager's display name to the userData array
    $userData += [PSCustomObject]@{
       
        SamAccountName    = $user.SamAccountName
        EmailAddress      = $user.EmailAddress
        proxyAddresses    = ($CurrentProxy -join ",")
    }
}

# Export the user data to a CSV file
$userData | Export-Csv -Path $csvFilePath  -NoTypeInformation -Encoding UTF8


Write-Host "User accounts have been exported to $csvFilePath"
