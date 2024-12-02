# Connect to Azure and Exchange Online
Connect-AzAccount 
Connect-ExchangeOnline

# CSV File Path
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\MS Email Census 11.4.24.csv"
$UserData = Import-Csv -Path $CSVFilePath

# Specify the distribution list name
$DistributionList = "careadvocates@lanterncare.com"

foreach ($User in $UserData) {
    # Use the email address or UPN directly from the CSV file if available
    $UPN = $User.Names2

    if ($UPN) {
        try {
            # Attempt to add the user to the distribution list
            Add-DistributionGroupMember -Identity $DistributionList -Member $UPN -ErrorAction Stop
            Write-Host "Added $UPN to $DistributionList"
        } catch {
            Write-Host "Failed to add $UPN to $DistributionList : $_"
        }
    } else {
        Write-Host "No valid UPN found for user."
    }
}
