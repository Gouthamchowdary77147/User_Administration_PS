do
{
# Define the User Principal Name (UPN)
$UserPrincipalName = Read-Host "Enter the UPN of user to get Principal Group Memberships:"

# Get detailed user information
$UserAZInfo = Get-MgUser -UserId $UserPrincipalName

# Check if the user exists before proceeding
if ($UserAZInfo) {
    # Get license details of the user
    try
    {
    $UserLicenseDetails = Get-MgUserLicenseDetail -UserId $UserAZInfo.Id
    $UserLicenseDetails |ForEach-Object{ 
    Write-Host "License Name: $($_.SkuPartNumber)" -foregrou
    } 
    }
    Catch
    {
    Write-Host "Unable to retrieve License info"
    }
    # Get the groups the user is a member of
    $UserAZGroupInfo = Get-MgUserMemberOf -UserId $UserAZInfo.Id
    
    # Loop through each group the user is a member of and get full details
    $UserAZGroupInfo | ForEach-Object {
        try {
            $groupDetails = Get-MgGroup -GroupId $_.Id
            Write-Host "Group Name: $($groupDetails.DisplayName) | Group ID: $($groupDetails.Id)" -ForegroundColor Cyan
        } catch {
            Write-Host "Failed to retrieve details for group ID: $_.Id" -ForegroundColor Red
        }
    }
} else {
    Write-Host "User with UPN $UserPrincipalName not found." -ForegroundColor Yellow
}
    # Ask if the user wants to continue for another user
    $continue = Read-Host "Do you want to get information for another user? (Y/N)"

} while ($continue -eq "Y")
Write-Host "Script Completed" -ForegroundColor Red