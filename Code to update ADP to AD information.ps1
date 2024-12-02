# Importing CSV file
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Infrastructure\AD data match with ADP\Changes need to be made\AD to ADP.csv"
$UserData = Import-Csv -Path $CSVFilePath

foreach ($User in $UserData) 
    {
   # $FirstName      = $User.FirstName
    #$LastName       = $User.LastName
    $DisplayName    = $User.DisplayName
    $SamAccountName = $User.SamAccountName
    $Title          = $User.Title
    $Department     = $User.Department
    $Description    = $User.Description
    $HireDate       = $User.Info
    $ManagerName    = $User.ManagerDisplayName
    $Company        = $User.Company

    $AccountDescription = "$Title | $Department | $HireDate"
    $HiringDate = "Hiring Date- "+$HireDate

    # Fetch user information from AD
    $UserADInfo = Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -Properties *

    if ($UserADInfo.SamAccountName) 
        {
            # Fetch manager information
            $Managers = Get-ADUser -Filter {Name -eq $ManagerName} -Property *
        
            if ($ManagerName -and $ManagerName.Trim() -and $Managers.DistinguishedName -ne "") 
                {
                    # Update user information including Manager
                    Set-ADUser  -Identity $UserADInfo.SamAccountName -Clear info
                    Set-ADUser  -Identity $UserADInfo.SamAccountName -DisplayName $DisplayName -Title $Title -Company $Company -Description $AccountDescription -Department $Department -Manager $Managers.DistinguishedName -Replace @{info= $HiringDate}
                          
                    Write-Host "Successfully updated user: $SamAccountName"

                    # Fetch updated user information
                    $UpdatedUserInfo = Get-ADUser -Identity $SamAccountName -Properties *

                    # Create an array of custom objects to store the old and new information
                    $UserInfoTable = @()

                    # Add the old and new information to the array


                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "DisplayName"
                        OldUserInfo    = $UserADInfo.DisplayName
                        NewUserInfo    = $UpdatedUserInfo.DisplayName
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Title"
                        OldUserInfo    = $UserADInfo.Title
                        NewUserInfo    = $UpdatedUserInfo.Title
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Department"
                        OldUserInfo    = $UserADInfo.Department
                        NewUserInfo    = $UpdatedUserInfo.Department
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "HiringDate"
                        OldUserInfo    = $UserADInfo.info
                        NewUserInfo    = $UpdatedUserInfo.Info
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Description"
                        OldUserInfo    = $UserADInfo.Description
                        NewUserInfo    = $UpdatedUserInfo.Description
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "ManagerName"
                        OldUserInfo    = $UserADInfo.Manager
                        NewUserInfo    = $UpdatedUserInfo.Manager
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Company"
                        OldUserInfo    = $UserADInfo.Company
                        NewUserInfo    = $UpdatedUserInfo.Company
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Hiring Date"
                        OldUserInfo    = $UserADInfo.info
                        NewUserInfo    = $UpdatedUserInfo.info
                    }

                    # Display the information in a table format
                    $UserInfoTable | Format-Table -AutoSize

                }
            else
                {
                 # Update user information excluding Manager
                    Set-ADUser  -Identity $adUser.SamAccountName -DisplayName $DisplayName -Title $Title -Company $Company -Description $AccountDescription -Department $Department -Replace @{info=$HiringDate}
                          
                    Write-Host "Successfully updated user: $SamAccountName excluding Manager Information"

                    # Fetch updated user information
                    $UpdatedUserInfo = Get-ADUser -Identity $SamAccountName -Properties *

                     # Create an array of custom objects to store the old and new information
                    $UserInfoTable = @()

                    # Add the old and new information to the array

                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "DisplayName"
                        OldUserInfo    = $UserADInfo.DisplayName
                        NewUserInfo    = $UpdatedUserInfo.DisplayName
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Title"
                        OldUserInfo    = $UserADInfo.Title
                        NewUserInfo    = $UpdatedUserInfo.Title
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Department"
                        OldUserInfo    = $UserADInfo.Department
                        NewUserInfo    = $UpdatedUserInfo.Department
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "HiringDate"
                        OldUserInfo    = $UserADInfo.HiringDate
                        NewUserInfo    = $UpdatedUserInfo.Info
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Description"
                        OldUserInfo    = $UserADInfo.Description
                        NewUserInfo    = $UpdatedUserInfo.Description
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Company"
                        OldUserInfo    = $UserADInfo.Company
                        NewUserInfo    = $UpdatedUserInfo.Company
                    }
                    $UserInfoTable += [PSCustomObject]@{
                        Property       = "Hiring Date"
                        OldUserInfo    = $UserADInfo.info
                        NewUserInfo    = $UpdatedUserInfo.info
                    }
                    # Display the information in a table format
                    $UserInfoTable | Format-Table -AutoSize
                }
        } 
    else 
        {
         Write-Host "Unable to find user $SamAccountName in AD."
        }
}
