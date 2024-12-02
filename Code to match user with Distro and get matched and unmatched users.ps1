# Initialize arrays
$UsersinAD = [System.Collections.Generic.List[Object]]::new()
$MatchedUsers = [System.Collections.Generic.List[Object]]::new()
$UnmatchedUsers = [System.Collections.Generic.List[Object]]::new()

# Fetch all AD users with the specified proxy address
$ADUsers = Get-ADUser -Filter * -Properties DisplayName, proxyAddresses | Where-Object {
    $_.proxyAddresses -match "SMTP:.*@lanterncare\.com"
}

foreach ($User in $ADUsers) {
    $UsersinAD.Add($User)
}

# Fetch distribution group members
$GroupMembers = Get-DistributionGroupMember -Identity "Migration_To_Lantern@edhc.com"

# Compare AD users with group members
foreach ($GroupMember in $GroupMembers) {
    $GroupMemberDisplayName = $GroupMember.DisplayName
    $MatchedUser = $UsersinAD | Where-Object { $_.DisplayName -eq $GroupMemberDisplayName }
    
    if ($MatchedUser) {
        $MatchedUsers.Add($GroupMemberDisplayName)
    } else {
        $UnmatchedUsers.Add($GroupMemberDisplayName)
    }
}

# Output results
Write-Output "List of Matched Users:"
$MatchedUsers | ForEach-Object { Write-Output $_ }

Write-Output "List of Unmatched Users:"
$UnmatchedUsers | ForEach-Object { Write-Output $_ }
