 Connect-ExchangeOnline 
$CSVFilePath = "C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\Bulk Active Directory.csv"
$UserData = Import-Csv -Path $CSVFilePath
$LogFile= "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\CA Bulk CSV's MASTER\LogFile.txt"

# Log script start
Add-Content -Path $LogFile -Value "Starting script"

foreach ($User in $UserData) 
    {
    $GivenName = $User.GivenName
    $Surname = $User.Surname
    $Name = $User.Name
    $DisplayName = $User.DisplayName
    $SamAccountName = $User.SamAccountName
    $UserPrincipalName = $User.UserPrincipalName
    $AccountPassword = $User.AccountPassword
    $Title = $User.Title
    $Department = $User.Department
    $Description = $User.Description
    $EmailAddress = $User.EmailAddress
    $Contractor = $User.Contractor
    $Company = $User.Company
    $Manager = $User.Manager
    $HiringDate = $User.HiringDate
    $Ticket= $User.JIRAAD
    $HireDate = "Hiring Date - $HiringDate | Ticket- $Ticket"
    
    #Checking if the row is empty
    If($Name)
        {    
        # Find Manager if available
        $ManagerUser = Get-ADUser -Filter {SamAccountName -eq $Manager}
        if($ManagerUser)
            {
            # Create the user
            New-ADUser -GivenName $GivenName -Surname $Surname -Name $Name -DisplayName $DisplayName `
            -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName `
            -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -Enabled $true `
            -Title $Title -Department $Department -Description $Description -EmailAddress $EmailAddress `
            -Path "OU=New Users,OU=People,DC=corp,DC=edhc,DC=com" -Manager $ManagerUser

            # Update company information based on contractor status
            if ($Contractor -eq 'TRUE') 
                {
                Set-ADUser -Identity $SamAccountName -Company $Company
                Write-Host "User company name is $Company"
                } 
            else 
                {
                Set-ADUser -Identity $SamAccountName -Company "EDHC"
                }
            #Updating Hiring date and Onbaording Ticket information
            if($HiringDate)
                {
                # Update user info with hire date
                Set-ADUser -Identity $SamAccountName -Clear info
                Set-ADUser -Identity $SamAccountName -Replace @{info = $HireDate}
                }
            else
                {
                Write-Host "$DisplayName is missing Hiring Date"
                }                
            # Handle group memberships based on the title
            if ($Title -eq 'Care Advocate') 
                {                
                # Retrieve the template user for Care Advocate
                $targetGroup = Get-ADUser -Identity catemplate -Properties MemberOf
                $targetMemberships = $targetGroup.MemberOf | Get-ADGroup | Select-Object Name
                # Get current user to be added to groups
                $CAUsers = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty SamAccountName
                # Add the user to each group that the template is a member of
                foreach ($group in $targetMemberships) 
                    {
                    Add-ADGroupMember -Identity $group.Name -Members $CAUsers
                    Add-Content -Path $LogFile -Value "Added $SamAccountName to $($group.Name)" 
                   
                    }                
                } 
            else 
                {
                # Add the user to default groups
                $BaseGroups = @("SG_EmployeeVPNAccess", "SG_KnowBe4", "SG_File_BaseAccess", "SG_DocuSign_EDHC_CA")

                foreach ($group in $BaseGroups) 
                    {
                    Add-ADGroupMember -Identity $group -Members $SamAccountName -ErrorVariable $ErrorArray -ErrorAction SilentlyContinue
                    if($ErrorArray -gt 0)
                        {
                        Add-Content -Path $LogFile -Value "Not Added $SamAccountName to $group"
                        Write-Host "Not Added $SamAccountName to $group"
                        }
                    else
                        {
                        Write-Host "Added $SamAccountName to $group"
                        }
                    }
                }
            }
        }
    else
        {
        Write-Host "End of CSV file"
        }
    }
    
#Start-Sleep -Seconds 1200
# Add users to distribution lists after they have been created
foreach ($User in $UserData) {
    $SamAccountName = $User.SamAccountName
    if($SamAccountName)
    {
    # Retrieve the user from Active Directory
    $TargetUser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}

    if ($TargetUser -ne $null) {
        Write-Host "Found user: $($TargetUser.SamAccountName)"
        Add-Content -Path $LogFile -Value "Found user: $($TargetUser.SamAccountName)"

        # Get the user's email address
        $UserEmailAddress = $TargetUser.UserPrincipalName
        $DistributionList = @("all@edhc.com")

        # Add the user to each distribution list
        foreach ($dl in $DistributionList) {
            Add-DistributionGroupMember -Identity $dl -Member $UserEmailAddress
            Write-Output "Added $($TargetUser.SamAccountName) to $dl"
            Add-Content -Path $LogFile -Value "Added $($TargetUser.SamAccountName) to $dl"
        }

        $MailEnabledSecurityGroup = @("defend_users@edhc.com")
        foreach ($SG in $MailEnabledSecurityGroup) {
            Add-DistributionGroupMember -Identity $SG -Member $UserEmailAddress
            Add-Content -Path $LogFile -Value "Added $($TargetUser.SamAccountName) to $SG"
            Write-Output "Added $($TargetUser.SamAccountName) to $SG"
        }
    } else {
        Write-Host "User not found: $SamAccountName"
        Add-Content -Path $LogFile -Value "User not found: $SamAccountName"
    }

    }
    else
    {
    Write-Host "End of CSV file"
   
    }
}

