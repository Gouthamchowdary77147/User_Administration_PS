# Connect to ExchangeOnline
Connect-ExchangeOnline
# Specify the distribution list name
$DistributionList = "EDHCsales@edhc.com"

# List of users to remove from the distribution list
$UsersToRemove = @("John Zutter")

# Remove users from the distribution list
foreach ($user in $UsersToRemove) {
    Remove-DistributionGroupMember -Identity $DistributionList -Member $user -Confirm:$false
    Write-Host "Removed $user from $DistributionList"
}
