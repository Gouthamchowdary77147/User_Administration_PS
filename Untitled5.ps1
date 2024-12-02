# Replace 'YourOU' with the actual name of your Organizational Unit
$OUDistinguishedName = "OU=People,DC=corp,DC=edhc,DC=com"

# Replace 'YourMailEnabledSecurityGroup' with the actual name of your mail-enabled security group
$SecurityGroupName = "Defend_Users@edhc.com"

$UsersInOU = Get-ADUser -Filter * -SearchBase $OU

# Get the members of the Azure mail-enabled security group
$SecurityGroupMembers = Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq '$SecurityGroupName'").ObjectId

# Compare and find users not in the security group
$UsersNotInSecurityGroup = $UsersInOU | Where-Object { $user = $_; -not ($SecurityGroupMembers.UserPrincipalName -contains $user.UserPrincipalName) }

# Display the results
Write-Host "Users in OU '$OU' not in the Azure mail-enabled security group '$SecurityGroupName':"
foreach ($user in $UsersNotInSecurityGroup) {
    Write-Host "$($user.SamAccountName) - $($user.UserPrincipalName)"
}