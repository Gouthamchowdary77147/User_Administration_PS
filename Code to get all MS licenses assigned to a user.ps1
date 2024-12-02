# Install and import the Microsoft Azure Active Directory module
# Install-Module -Name MSOnline -Force -AllowClobber
# Import-Module MSOnline

# Connect to Microsoft 365 (you'll be prompted to enter your credentials)
Connect-MsolService

# Get information about a specific user, including the license details
$user = Get-MsolUser -UserPrincipalName ext.goutham.gummadi@edhc.com
Set-MsolUser -

# Display the license details
$user.Licenses | ForEach-Object {
    Write-Host "SKU: $($_.AccountSkuId)"
   # Write-Host "Status: $($_.ServiceStatus)"
    Write-Host "$($user)"
}
