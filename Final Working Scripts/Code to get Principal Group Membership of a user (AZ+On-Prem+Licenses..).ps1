# Check and connect to Exchange Online
if (!(Get-PSSession | Where-Object {$_.ConfigurationName -eq 'Microsoft.Exchange'})) {
    Write-Host "Connecting to Exchange Online..."
    Connect-ExchangeOnline | Out-Null
} else {
    Write-Host "Already connected to Exchange Online."
}

# Check and connect to Microsoft Graph
try {
    # Try a simple Graph command to see if it's connected
    Get-MgUser -Top 1 -ErrorAction Stop | Out-Null
    Write-Host "Already connected to Microsoft Graph."
} catch {
    Write-Host "Connecting to Microsoft Graph..."
    Connect-MgGraph -Scopes "user.read.all" | Out-Null
}

# Check and connect to Azure Account
if (!(Get-AzContext)) {
    Write-Host "Connecting to Azure Account..."
    Connect-AzAccount | Out-Null
} else {
    Write-Host "Already connected to Azure Account."
}

# Check and connect to Azure AD
try {
    # Check for a basic Azure AD command to validate the session
    Get-AzureADUser -Top 1 -ErrorAction Stop | Out-Null
    Write-Host "Already connected to Azure AD."
} catch {
    Write-Host "Connecting to Azure AD..."
    Connect-AzureAD | Out-Null
}




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
    $UserLicenseDetails |ForEach-Object{ Write-Host "License Name: $($_.SkuPartNumber)" -ForegroundColor DarkGray}
    }
    Catch
    {
    Write-Host "Unable to retrieve License info"
    }
    $groupDetailsList = @()
    # Get the groups the user is a member of
    $UserAZGroupInfo = Get-MgUserMemberOf -UserId $UserAZInfo.Id
    
    # Loop through each group the user is a member of and get full details
    $UserAZGroupInfo | ForEach-Object {
        try {
        $groupDetails = Get-MgGroup -GroupId $_.Id
        $groupDetailsList += [PSCustomObject]@{
            "Group Name" = $groupDetails.DisplayName
            "Group ID"   = $groupDetails.Id
        }

        if ($groupDetails.GroupType -eq "DistributionGroup") {
            Remove-DistributionGroupMember -Identity $groupDetails.Id -Member $UserAZInfo.Id
        }
    } catch {
        Write-Host "Failed to retrieve details for group ID: $($_.Id)" -ForegroundColor Red
    }
    }
    $groupDetailsList | Format-Table -AutoSize

} else {
    Write-Host "User with UPN $UserPrincipalName not found." -ForegroundColor Yellow
}
    # Ask if the user wants to continue for another user
    $continue = Read-Host "Do you want to get information for another user? (Y/N)"

} while ($continue -eq "Y")
Write-Host "Script Completed" -ForegroundColor Red