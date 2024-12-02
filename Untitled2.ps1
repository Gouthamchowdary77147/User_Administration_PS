foreach ($User in $UserData) 
    {
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

        $ExistingUser= Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -Properties *
        if($ExistingUser)
            {
            $HiringDate = $User.HiringDate
        $HireDate = "Hiring Date - $HiringDate"
         
        $ManagerUser = Get-ADUser -Filter {SamAccountName -eq $Manager}
        # Create the user
        New-ADUser -GivenName $GivenName -Surname $Surname -Name $Name -DisplayName $DisplayName -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -Enabled $true -Title $Title -Department $Department -Description $Description -EmailAddress $EmailAddress -Path "OU= New Users, OU=People,DC=corp,DC=edhc,DC=com" -Manager $ManagerUser
  
        # Updating Company info based on type of employment 
        if($Contractor -eq 'TRUE')
        {
            Set-ADUser -Identity $SamAccountName -Company $Company
            Write-Host "User company name is $Company"
        }
        else
        {
            Set-ADUser -Identity $SamAccountName -Company "EDHC"
        }

  

 
        if ($Title -eq 'Care Advocate') 
        {
          # Assuming $SamAccountName is already defined
          Set-ADUser -Identity $SamAccountName -Clear info
          Set-ADUser -Identity $SamAccountName -Replace @{info = $HireDate}
          $targetGroup = Get-ADUser -Filter {SamAccountName -eq "catemplate"} -SearchBase "CN=Template CareAdvocate,OU=People,DC=corp,DC=edhc,DC=com" -Properties * -ErrorAction SilentlyContinue
          Write-Host "$targetGroup"
          # Get group memberships of the target group
          $targetMemberships = Get-ADPrincipalGroupMembership -Identity $targetGroup.SamAccountName
          $CAUsers= Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -SearchBase "OU=People,DC=corp,DC=edhc,DC=com"
          # Add the target user to each group
          foreach ($group in $targetMemberships) 
          {
              Add-ADGroupMember -Identity $group -Members $CAUsers
              Add-Content -Path $LogFile -Value "Added $SamAccountName to $group"
              Write-Host "Added $SamAccountName to $group"
          }
          Add-Content -Path $LogFile -Value "User $targetUser added to all groups of $targetGroup."

          Write-Host "User $targetUser added to all groups of $targetGroup."
        } 
    
        else 
        {
            # Use PowerShell array for $BaseGroups
            $BaseGroups = @("SG_EmployeeVPNAccess", "SG_KnowBe4", "SG_File_BaseAccess", "SG_DocuSign_EDHC_CA")

            foreach ($group in $BaseGroups) 
            {
                Set-ADUser -Identity $SamAccountName -Clear info
                Set-ADUser -Identity $SamAccountName -Replace @{info = $HireDate}
                $TargetUsers= Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -SearchBase "OU=People,DC=corp,DC=edhc,DC=com"
                Add-ADGroupMember -Identity $group -Members $TargetUsers 
                Add-Content -Path $LogFile -Value "Added $SamAccountName to $group"
                Write-Host "Added $SamAccountName to $group"
            
            }
        }
    
    
    
 Start-Sleep -Seconds 1200
    foreach ($User in $UserData) 
    {
       
    
        # Retrieve the user from Active Directory

        $TargetUser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}

        if ($TargetUser -ne $null) 
        {
            Write-Host "Found user: $($TargetUser.SamAccountName)"
            Add-Content -Path $LogFile -Value "Found user: $($TargetUser.SamAccountName)"
            # Retrieve the user's email address
            $UserEmailAddress = $TargetUser.UserPrincipalName
            $DistributionList = @("all@edhc.com")

            foreach ($dl in $DistributionList) 
            {         
                # Add the user to the distribution group
                Add-DistributionGroupMember -Identity $dl -Member $UserEmailAddress
                Write-Output "Added $($TargetUser.SamAccountName) to $dl"
                Add-Content -Path $LogFile -Value "Added $($TargetUser.SamAccountName) to $dl"
            }
            $MailEnabledSecurityGroup= @("defend_users@edhc.com")
            foreach($SG in $MailEnabledSecurityGroup)
            {
                Add-DistributionGroupMember -Identity $SG -Member $UserEmailAddress
                Add-Content -Path $LogFile -Value "Added $($TargetUser.SamAccountName) to $SG"
                Write-Output "Added $($TargetUser.SamAccountName) to $SG"
            }

        } 
        else 
        {

            Write-Host "User not found: $SamAccountName"
            Add-Content -Path $LogFile -Value "User not found: $SamAccountName"
        }
}
            }
        else
            {
            
            }