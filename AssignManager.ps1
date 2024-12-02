
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\CA Bulk CSV's MASTER\Bulk Active Directory.csv"
$UserData = Import-Csv -Path $CSVFilePath

# #You should define the variable $EndUser before using it in the loop
#$EndUser = $null

foreach ($User in $UserData) {
    $GivenName = $User.GivenName
    $Surname = $User.Surname
    $Name = $User.Name
    $DisplayName = $User.DisplayName  # Corrected a typo in this variable name
    $SamAccountName = $User.SamAccountName
    $UserPrincipalName = $User.UserPrincipalName
    $AccountPassword = $User.AccountPassword
    $Title = $User.Title
    $Department = $User.Department
    $Description = $User.Description
    $EmailAddress = $User.EmailAddress
    $Contractor= $User.Contractor
    $Company= $User.Company
    $Manager = $User.Manager
    $CurrentUser= Get-ADUser -Filter {SamAccountName -eq $SamAccountName}
    #EndManager= Get-ADUser -Filter {CN -eq "Ryan Burke"}
    $DL= Get-DistributionGroup -Identity "all@edhc.com"
     Add-DistributionGroupMember -Identity $DL -Member $CurrentUser

    }