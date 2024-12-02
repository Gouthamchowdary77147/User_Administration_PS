$SamAccountName = "nkeba.berryman"
$EndUser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}
Write-Host "$EndUser"
$Groups = Get-ADPrincipalGroupMembership -Identity $EndUser

foreach ($Group in $Groups) {
    # Add-ADGroupMember -Identity $Group -Members $EndUser
    # Write-Host "Added $SamAccountName to $Group"
    Write-Host "$($Group.name)"
}
