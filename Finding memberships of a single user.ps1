# Retrieve user based on SamAccountName and check if the user exists
Connect-AzureAD
$Euser = Get-ADUser -Filter {SamAccountName -eq "catemplate"} -Properties * -SearchBase "OU=Service Admins,OU=Users,DC=corp,DC=edhc,DC=com"
Write-Host "$Euser"

if ($Euser) {
    # Get the user's group memberships
    $Groups = Get-ADPrincipalGroupMembership -Identity $Euser.SamAccountName
    Write-Host "$Groups"

    if ($Groups) {
        # Loop through each group and output the group name
        foreach ($Group in $Groups) {
            Write-Host "Group: $($Group.Name)"
        }
    } else {
        Write-Host "User '$($Euser.Name)' is not a member of any groups."
    }
} else {
    Write-Host "User with SamAccountName $($Euser.name) not found."
}
