#connect to exchange
#Connect-ExchangeOnline
# Replace 'YourDistributionGroupName' with the actual name of your distribution groups
$DistributionGroupNames = @("buzzclan@lanterncare.com")

foreach ($DistributionGroupName in $DistributionGroupNames) {
    # Get the distribution group details
    $DistributionGroup = Get-DistributionGroup -Identity $DistributionGroupName

    # Get the memberships of each distribution group
    $GroupMemberships = Get-DistributionGroupMember -Identity $DistributionGroupName
    $Owner = $DistributionGroup.ManagedBy | Select-Object DisplayName, JobTitle
    Write-Host "Distribution Group: $($DistributionGroup.DisplayName)"
    Write-Host "Group Owner: $Owner.DisplayName, $Owner.JobTitle"

    # Display the names of the members
    foreach ($member in $GroupMemberships) {
        $UserDetails = Get-User -Identity $member.Identity | Select-Object DisplayName, Title, UserPrincipalName, Department | Format-Table -Property Displayname, UserPrincipalName
        Write-Host "$($UserDetails.DisplayName), ($($UserDetails.Department))"
       Write-Host "$($UserDetails.DisplayName)- $($UserDetails.Department)" 
    }
}
