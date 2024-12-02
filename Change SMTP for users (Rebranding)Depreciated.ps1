# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\SMTP Rebranding.csv"
$LogFile = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\SMTP logfile.txt"

# Import the CSV data
$UserData = Import-Csv -Path $CSVFilePath

# Log the start of the script
Add-Content -Path $LogFile -Value "Starting Script"

# Iterate over each user in the CSV data
foreach ($User in $UserData) {
    $SAM = $User.SamAccountName
    $SMTP = $User.SMTP
    
    # Log the SAM and SMTP values
    Add-Content -Path $LogFile -Value "Processing user: $SAM with new SMTP: $SMTP"
    
    # Validate the SAM and SMTP values
    if ([string]::IsNullOrWhiteSpace($SAM) -or [string]::IsNullOrWhiteSpace($SMTP)) {
        Add-Content -Path $LogFile -Value "Invalid data for user: $SAM. Skipping."
        continue
    }
    
    # Get the current proxy addresses for the user
    $CurrentProxyAddress = Get-ADUser -Filter {SamAccountName -eq $SAM} -Properties proxyAddresses
    $Output= $CurrentProxyAddress.proxyAddresses
    Write-Host "Output: $Output"
    Add-Content -Path $LogFile -Value "Current proxy addresses for $SAM : $Output"
    
    # Initialize the new proxy addresses array with the new SMTP address
    $NewProxyAddress = @($SMTP)
    Write-Host "CSV SMTP: $NewProxyAddress"
    Add-Content -Path $LogFile -Value "New proxy address to be added: $SMTP"
    
    if ($CurrentProxyAddress.proxyAddresses) {
        # Convert each current proxy address to lowercase and add it to the new proxy addresses array
        foreach ($Proxy in $CurrentProxyAddress.proxyAddresses) {
            $LowercaseSMTP = $Proxy.ToLower()
            Write-Host "$LowercaseSMTP"
            Add-Content -Path $LogFile -Value "Processing existing proxy address: $LowercaseSMTP"
            
            if (-not $NewProxyAddress.Contains($LowercaseSMTP)) {
                $NewProxyAddress += $LowercaseSMTP
            }
        }
    }
    
    Write-Host "New Proxy Addresses: $NewProxyAddress"
    Add-Content -Path $LogFile -Value "Final proxy addresses for $SAM : $NewProxyAddress"
    
    # Update the proxy addresses for the user in Active Directory
    try {
    $EUser= Get-ADUser -Filter {SamAccountName -eq $SAM} 
        Set-ADUser -Identity $EUser -Replace @{$proxyAddresses= $NewProxyAddress}
        Add-Content -Path $LogFile -Value "Updated proxy addresses for user $SAM"
    } catch {
        Add-Content -Path $LogFile -Value "Failed to update proxy addresses for user $SAM. Error: $_"
    }
}

# Log the completion of the script
Add-Content -Path $LogFile -Value "Script Completed"
