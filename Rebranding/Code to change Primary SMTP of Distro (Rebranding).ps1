Connect-ExchangeOnline
# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Final list to change\AllDistributionLists09-16-2024_22-28.csv"
$LogFile = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Backups\AllDistributionLists09-17-2024_01-15LogFile.csv"
#Importing CSV file
$DistroData= Import-Csv -Path $CSVFilePath 
#Creating a file to track if the changes are successful or not
$ChangeValidation=@()
Foreach($Distro in $DistroData)
    {
    $EmailAddress = $Distro.EmailAddress
    #Getting Distribution list information
    $DistributionInfo= Get-DistributionGroup -Identity $EmailAddress | Select-Object PrimarySmtpAddress
    $OldPrimarySMTP = $DistributionInfo.PrimarySmtpAddress
    if($DistributionInfo)
        {
        #Creating new Primary SMTP Address
        $NewPrimarySMTP= $EmailAddress.replace("edhc","lanterncare")

#Actual code     
        Set-DistributionGroup -Identity $EmailAddress -PrimarySmtpAddress $NewPrimarySMTP

        #Checking if the changes are made or not.
        $NewDistributionInfo= Get-DistributionGroup -Identity $EmailAddress 
        if($NewDistributionInfo)
            {
            if($NewDistributionInfo.PrimarySmtpAddress -eq $NewPrimarySMTP)
                {
                $ChangeStatus= "Passed"
                $LogPrimarySMTP= $NewPrimarySMTP
                $ChangeValidation+=[PSCustomObject]@{
                OldPrimarySMTP = ($OldPrimarySMTP -join ",")
                NewPrimarySMTP = ($LogPrimarySMTP -join ",")
                ChangeStatus = $ChangeStatus
                                                    }
                }
            else
                {
                $ChangeStatus = "Failed"
                $LogPrimarySMTP= "OldPrimarySMTP"
                $ChangeValidation+=[PSCustomObject]@{
                OldPrimarySMTP = ($OldPrimarySMTP -join ",")
                NewPrimarySMTP = ($LogPrimarySMTP -join ",")
                ChangeStatus = $ChangeStatus
                                                    }
                }
            }
        else
            {
            $ChangeStatus = "New Distro Not found"
            $LogPrimarySMTP = "New Distro Not found"
            $ChangeValidation+=[PSCustomObject]@{
            OldPrimarySMTP = ($OldPrimarySMTP -join ",")
            NewPrimarySMTP = ($LogPrimarySMTP -join ",")
            ChangeStatus = $ChangeStatus
                                                }
            }

        }
    else
        {
        $ChangeStatus = "Old Distro Not found"
        $LogPrimarySMTP = "Old Distro Not found"
        $ChangeValidation+=[PSCustomObject]@{
        OldPrimarySMTP = ($OldPrimarySMTP -join ",")
        NewPrimarySMTP = ($LogPrimarySMTP -join ",")
        ChangeStatus = $ChangeStatus
        }
        }
        $OldPrimarySMTP=""
        $NewPrimarySMTP=""
        $DistributionInfo=""
        $NewDistributionInfo=""
    }

    $ChangeValidation | Export-Csv -Path $LogFile -NoTypeInformation -Encoding UTF8