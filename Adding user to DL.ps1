# Install and import the Exchange Online PowerShell module
#Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
#Import-Module ExchangeOnlineManagement

# Connect to Exchange Online (you might need to provide credentials)
Connect-ExchangeOnline 

$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\MS Email Census 11.4.24.csv"
$UserData = Import-Csv -Path $CSVFilePath

foreach ($User in $UserData) {
   
    $EmailAddress = $User.names
    

    $TargetUser = Get-ADUser -Filter {UserPrincipalName -eq $EmailAddress}
    Write-Host "$TargetUser"
    
    if ($TargetUser -ne $null) {
        Write-Host "Found user: $($TargetUser.SamAccountName)"
        $DistributionList = "careadvocates@lanterncare.com"

        # Convert the user object to the required format
        #$Recipient = [Microsoft.Exchange.Configuration.Tasks.RecipientWithAdUserGroupIdParameter[Microsoft.Exchange.Configuration.Tasks.RecipientIdParameter]]$TargetUser.DistinguishedName

        # Add the user to the distribution group
        Add-DistributionGroupMember -Identity $DistributionList -Member $TargetUser
        Write-Output "Added $($TargetUser.SamAccountName) to $DistributionList"
    } else {
        Write-Host "User not found: $SamAccountName"
    }
}
