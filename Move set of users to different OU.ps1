# Import the Active Directory module
Import-Module ActiveDirectory

# Define the CSV file path
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Documents\Move users to OU's.csv"

# Import the CSV file data
$UserData = Import-Csv -Path $CSVFilePath

# Prompt for the destination OU
#$OUName = Read-Host "Enter destination OU"

# Iterate through each user in the CSV data
foreach ($user in $UserData) {
    $GivenName = $user.FirstName
    $Surname = $user.LastName
  #  $Name = $user.Name
    $EmailAddress = $user.EmailAddress
   # $SAM= $user.SamAccountName
    $OUName=$user.Department
    $Title= $user.Title
    $Manager = $user.Manager
  
    # Retrieve the user object from Active Directory
    $TargetUser = Get-ADUser -Filter {UserPrincipalName -eq $SAM} -SearchBase "OU=People,DC=corp,DC=edhc,DC=com"
    $ManagerUser= Get-ADUser -Filter {UserPrincipalName -ew $Manager} -SearchBase "OU=People,DC=corp,DC=edhc,DC=com"
    
    if ($TargetUser) {
        # Construct the full target path using the specified OU
        $TargetPath = "OU=$OUName,OU=People,DC=corp,DC=edhc,DC=com"
        
        # Move the user object to the specified OU
        Move-ADObject -Identity $TargetUser.DistinguishedName -TargetPath $TargetPath
        Set-ADUser -Identity $TargetUser -Title $Title -Manager $Manager
        Write-Host "Moved user $Name ($SAM) to $OUName OU, Manager is updated to $Manager and Title to $Title"
    } else {
        Write-Host "User $Name ($SAM) not found in the specified search base."
    }
}
