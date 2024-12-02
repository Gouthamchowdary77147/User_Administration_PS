# Define the path to the CSV file and the log file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Distro, 365 SMTP change\MS365Groups09-09-2024_10-54.csv"
$LogFile = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\Rebranding\Distro, 365 SMTP change\MS365Groups09-09-2024_10-54RollOverLogFile.csv"
#Importing CSV file
$MS365Data= Import-Csv -Path $CSVFilePath 
#Creating a file to track if the changes are successful or not
$RollOverValidation=@()
Foreach($DMS365Group in $MS365Data)
    {
    $EmailAddress = $MS365Group.EmailAddress
    $OldPrimarySMTP= $MS365Group.PrimarySMTP
    #Getting Distribution list information
    $MS365GroupInfo= Get-UnifiedGroup -Identity $EmailAddress
    if($DistributionInfo)
        {
         $NewPrimarySMTP= $EmailAddress.replace("edhc","lanterncare")
#Actual code     
        Set-UnifiedGroup -Identity $EmailAddress -PrimarySmtpAddress $OldPrimarySMTP

        #Checking if the changes are made or not.
        $OldMS365GroupInfo= Get-UnifiedGroup -Identity $EmailAddress 
        if($OldMS365GroupInfo)
            {
            if($OldMS365GroupInfo.PrimarySmtpAddress -eq $OldPrimarySMTP)
                {
                $RollOverStatus = "Passed"
                $LogPrimarySMTP= $OldMS365GroupInfo.PrimarySmtpAddress
                }
            else
                {
                $RollOverStatus = "Failed"
                $LogPrimarySMTP= "Failed to roll over"
                }
            }
        else
            {
            $ChangeStatus = " Distro Not found"
            $LogPrimarySMTP = "Distro Not found"
            }
        }
    else
        {
        $RollOverStatus = "Old Distro Not found"
        $LogPrimarySMTP = "Distro Not found"
        }

        $RollOverValidation+=[PSCustomObject]@{
        OldPrimarySMTP = ($OldPrimarySMTP -join ",")
        NewPrimarySMTP = ($LogPrimarySMTP -join ",")
        RollOverStatus = $RollOverStatus
        }

    }

    $RollOverValidation | Export-Csv -Path $LogFile -NoTypeInformation -Encoding UTF8