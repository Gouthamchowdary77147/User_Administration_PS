Connect-ExchangeOnline
$CurrentDateTime= Get-Date -Format "MM-dd-yyyy_HH-mm"
$MS365Groups= "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\MS365Groups$CurrentDateTime.csv"
$DLList= "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\AllDistributionLists$CurrentDateTime.csv"
$MS365GroupsData=@()
$DistroData=@()
$AllMS365Groups = Get-UnifiedGroup -Filter *
$Distributionlist = Get-DistributionGroup
foreach($Group in $AllMS365Groups)
    {
    $EachGroupName= $Group.DisplayName
    $EachGroupSMTP= $Group.PrimarySmtpAddress
    $EachGroupEmail= $Group.EmailAddresses
    $MS365GroupsData += [PSCustomObject]@{
        DisplayName = $EachGroupName
        EmailAddress= $EachGroupSMTP
        PrimarySMTP= ($EachGroupEmail -join ",")
        }
    }
foreach($DL in $Distributionlist)
    {
    $EachDLName= $DL.DisplayName
    $EachDLSMTP= $DL.PrimarySmtpAddress
    $EachDLEmail= $DL.EmailAddresses
    $DistroData += [PSCustomObject]@{
        DisplayName = $EachDLName
        EmailAddress= $EachDLSMTP
        PrimarySMTP= ($EachDLEmail -join ",")
        }
    }

$DistroData | Export-Csv -Path $DLList -NoTypeInformation -Encoding UTF8
$MS365GroupsData | Export-Csv -Path $MS365Groups -NoTypeInformation -Encoding UTF8