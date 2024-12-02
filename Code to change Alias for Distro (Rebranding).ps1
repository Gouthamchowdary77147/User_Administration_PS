# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Distros\ext.goutham.gummadi\OneDrive - EDHC\Desktop\SMTP Rebranding.csv"
$LogFile = "C:\Distros\ext.goutham.gummadi\OneDrive - EDHC\Desktop\SMTP logfile.csv"


# Import the CSV data
$DistroData = Import-Csv -Path $CSVFilePath
#Array to save logfile results
$Results=@()


# Log the start of the script
Add-Content -Path $LogFile -Value "Starting Script"
# Iterate over each Distro in the CSV data
foreach ($Distro in $DistroData) 
    {
    #Importing CSV Date
    $DistroEmail = $Distro.DistroEmailAccountName
    #Checking if the Distro in CSV file is present in AD or not
    $DistroStatus= Get-ADDistro -Identity $DistroEmail -Properties *
    #If Distro is present in AD making changes to SMTP address
    if($DistroStatus)
        {
        #Getting Current Aliases
        $CurrentAlias= $DistroStatus.Aliases
        #Creating Primary SMTP using DistroEmail
        $PrimaryAlias= "SMTP:"+$DistroEmail+"@lanterncare.com"
        #If the current Aliases contain new domain in primary or secondary
        if($CurrentAlias -contains $PrimaryAlias.ToLower())
            {
            $NewAlias = $CurrentAlias -replace $PrimaryAlias.ToLower(), "$PrimaryAlias"
            }
        #Checking if current Aliases already has expected Alias address
        elseif($CurrentAlias -contains $PrimaryAlias)
            {
            $NewAlias = $CurrentAlias
            }
        #Checking if current Alias address is empty
        elseif($CurrentAlias -eq $null)
            {
            $NewAlias =$CurrentAlias
            }
        else
            {                    
            #Converting Current Alias Addresses to Secondary
            $SecondaryAlias= $CurrentAlias | ForEach-Object{$_.ToLower()}
            #Concatinating 
            $NewAlias = $PrimaryAlias+","+$SecondaryAlias
            }

                
#Actual code that is making the change                     
        Set-ADDistro -Identity $DistroEmail -Replace @{Aliases=$NewAlias -split ","}
 
        #Cross checking if the changes are made as expected or not
        #Distro information after update
        $NewDistroStatus= Get-ADDistro -Identity $DistroEmail -Properties *
        if($NewDistroStatus)
            {
            #Checking if the Alias Address is changed or not.Making sure the new Alias address did not clear out old ones
            if(($NewDistroStatus.Aliases -contains $DistroStatus.Aliases) -or ($NewDistroStatus.Aliases -eq $DistroStatus.Aliases))
                {
                $ChangeStatus ="Passed"
                }
            else
                {
                $ChangeStatus ="Failed"
                }
            $Results += [PSCustomObject]@{                
                OldAliases = ($CurrentAlias -join ", ")
                NewAliases = ($NewDistroStatus.Aliases -join ", ")
                ChangeStatus      = $ChangeStatus
            }
            }
        }
    else
        {
        Write-Host "Distro $DistroEmail not found in AD"
        }
    }

$Results | Export-Csv -Path $LogFile  -NoTypeInformation -Encoding UTF8
