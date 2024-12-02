# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Users SMTP change\SMTP Rebranding.csv"
$LogFile = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Users SMTP change\RollOverLogFile.csv"


# Import the CSV data
$UserData = Import-Csv -Path $CSVFilePath
#Array to save logfile results
$Results=@()


# Log the start of the script
Add-Content -Path $LogFile -Value "Starting Script"
# Iterate over each user in the CSV data
foreach ($User in $UserData) 
    {
    #Importing CSV Date
    $SAM = $User.SamAccountName
    #Checking if the user in CSV file is present in AD or not
    $UserStatus= Get-ADUser -Identity $SAM -Properties *
    #If user is present in AD making changes to SMTP address
    if($UserStatus)
        {
        $RecoveryProxy= $UserStatus.proxyAddresses     
#Actual code that is making the change                     
        Set-ADUser -Identity $SAM -Replace @{proxyAddresses=$RecoveryProxy}
 
       
            $Results += [PSCustomObject]@{                
                OldProxyAddresses = ($CurrentProxy -join ", ")
                NewProxyAddresses = ($NewUserStatus.proxyAddresses -join ", ")
                ChangeStatus      = $ChangeStatus
            }
            }
        
    else
        {
        Write-Host "User $SAM not found in AD"
        }
    }

$Results | Export-Csv -Path $LogFile  -NoTypeInformation -Encoding UTF8
