# Import the Active Directory module
#Import-Module ActiveDirectory

# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Final list to change\EP Final users list for SMTP change.csv"
$LogFile = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Final list to change\EP Final users Log File 09-17-2024-01-35.csv"


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
    $CurrentProxy= $User.proxyAddress
    #Checking if the user in CSV file is present in AD or not
    $UserStatus= Get-ADUser -Identity $SAM -Properties *
    Write-Host "$UserStatus"
   #If user is present in AD making changes to SMTP address
    if($UserStatus)
        {
        #Getting Current proxyAddresses
        # Assuming $UserStatus.proxyAddresses is an array of proxy addresses
        #$CurrentProxy = $UserStatus.proxyAddresses
        #$CurrentProxyString= $CurrentProxy -replace(" ",",")
        # Convert each proxy address to lowercase
         Write-Host "Current Proxy is : $CurrentProxy"
        $SecondaryProxy = $CurrentProxy | ForEach-Object { $_.ToLower() }
        
	
        Write-Host "Current Proxy is : $CurrentProxyString"
        #Creating Primary SMTP using SAM
        $PrimaryProxy= "SMTP:"+$SAM+"@lanterncare.com"
        $DefaultProxy= "smtp:"+$SAM+"@edhc.com"
        #If the current proxyAddresses contain new domain in primary or secondary
        if($CurrentProxy -eq $PrimaryProxy.ToLower())
            {
            $NewProxy = ($CurrentProxy -replace $PrimaryProxy.ToLower(), "$PrimaryProxy")+","+$DefaultProxy
            Write-Host "New Proxy1 is : $NewProxy"
            }
        #Checking if current proxyaddresses already has expected proxy address
        elseif($CurrentProxy -eq $PrimaryProxy)
            {
            $NewProxy = $CurrentProxy+","+$DefaultProxy
            Write-Host "New Proxy2 is : $NewProxy"
            }
        #Checking if current proxy address is empty
        elseif($CurrentProxy -eq $null)
            {
            $NewProxyArray = @($PrimaryProxy,$SecondaryProxy,$DefaultProxy) | Where-Object {$_ -ne ""}
            $NewProxy =$PrimaryProxy+","+$DefaultProxy
            Write-Host "New Proxy3 is : $NewProxy"
            }
        else
            {                    
            #Concatinating 
            $NewProxyArray = @($PrimaryProxy,$SecondaryProxy,$DefaultProxy) | Where-Object {$_ -ne ""}
            Write-Host "New Proxy4 is : $NewProxyArray"
            $NewProxy = $NewProxyArray -join ','
            Write-Host "New Proxy4 is : $NewProxy"
            }
            $NewProxyArray= $NewProxy -split ","
            $UniqueProxyArray = $NewProxyArray | Select-Object -Unique
            $UniqueProxyString= $UniqueProxyArray -join ","

#Set-ADUser -Identity $SAM -Clear proxyAddresses
 Set-ADUser -Identity $SAM -Add @{proxyAddresses = $UniqueProxyString -split ","}

 $NewProxyArray=@()
 $NewProxy=""
 
        #Cross checking if the changes are made as expected or not
        #User information after update
        $NewUserStatus= Get-ADUser -Identity $SAM -Properties *
        if($NewUserStatus)
            {
            #Checking if the Proxy Address is changed or not.Making sure the new proxy address did not clear out old ones
            if(($NewUserStatus.proxyAddresses -contains $UserStatus.proxyAddresses) -or ($NewUserStatus.proxyAddresses -eq $UserStatus.proxyAddresses))
                {
                $ChangeStatus ="Passed"
                }
            else
                {
                $ChangeStatus ="Failed"
                }
            $Results += [PSCustomObject]@{                
                OldProxyAddresses = ($CurrentProxy -join ", ")
                NewProxyAddresses = ($NewUserStatus.proxyAddresses -join ", ")
                ChangeStatus      = $ChangeStatus
            }
            }
        $CurrentProxy=""
        $SecondaryProxy=""
        $PrimaryProxy=""
        $DefaultProxy=""
        }
    else
        {
        Write-Host "User $SAM not found in AD"
                    $Results += [PSCustomObject]@{                
                OldProxyAddresses = $SAM
                NewProxyAddresses = "AD account not found"
                ChangeStatus      = "Failed"

                                                   }
        }
    }

$Results | Export-Csv -Path $LogFile  -NoTypeInformation -Encoding UTF8
