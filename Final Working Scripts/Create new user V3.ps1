﻿Connect-ExchangeOnline | Out-Null
Connect-MgGraph -Scopes "User.read.all" | Out-Null
#Getting Current Date and Time
Connect-AzureAD | Out-Null
$CurrentDateTime= Get-Date -Format "mm-dd-yyy-hh-mm"
$OnboardingUsersData= $null
#Input CSV file
$ImportFilePath= "C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\Bulk Active Directory.csv"
#Output Log File
$LogFile="C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\User Log files\UserLogFile-$CurrentDateTime.txt"
$ExchangeLogfile= "C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\Exchange Logfile\ExchangeLogFile-$CurrentDateTime.txt"
#Importing Input data
$OnboardingUsersData= Import-Csv -Path $ImportFilePath
Add-Content -Path $LogFile -Value "Starting Script $CurrentDateTime"













    Function add-UserToBaseGroups{
        param(
            [String]$SamAccountName,
            [String[]]$BaseGroups,
            [String]$LogFile
        )
        foreach ($Group in $BaseGroups) 
                            {
                            try 
                                {
                                Add-ADGroupMember -Identity $Group -Members $SamAccountName
                                Add-Content -Path $LogFile -Value "Added $($SamAccountName) to base group $Group"
                                }
                            catch 
                                {
                                Write-Host "Unable to add $($SamAccountName) to base group $Group"
                                Add-Content -Path $LogFile -Value "Unable to add $($SamAccountName) to base group $Group : $_"
                                }
                            }
    }












foreach($User in $OnboardingUsersData)
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
	
	#Creating New variable to store oboarding and offboarding data
	
	$Hiredate= "Hiring date is: $HiringDate | Jira Ticket- $Ticket"

    #Check if the user account already exists
    try
        {
        $UserAccountInfo= Get-ADUser -Identity $SamAccountName -Properties * -ErrorAction Stop
        Write-Host "$($DisplayName)'s account is already made"
                       
        if($UserAccountInfo)
            {
            Add-Content -Path $LogFile -Value "$DisplayName account already exists"
            Write-Host "$DisplayName Account Already exists"
            if($UserAccountInfo.title -eq "Care Advocate")
                        {
                        try
                            {
                            #Getting RBAC memberships
                            $TemplateInfo = Get-ADUser -Identity catemplate -Properties MemberOf
                            $RelavantGroups = $TemplateInfo.MemberOf | Get-ADGroup | Select-Object Name
                            # Get current user to be added to groups
                            $CAUsers = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty SamAccountName
                            # Add the user to each group that the template is a member of
                            if($RelavantGroups)
                                {
                                foreach ($group in $RelavantGroups) 
                                    {
                                    Add-ADGroupMember -Identity $group.Name -Members $CAUsers
                                    Add-Content -Path $LogFile -Value "Added $SamAccountName to $($group.Name)" 
                                    }
                                 }   
                            else
                                {
                                Write-Host "Template is found but unable to retrive groups"
                                }
                            }

                        catch
                            {
                            Write-Host "catemplate is not found"
                            }
                        }
                    else
                        {
                        $BaseGroups = @("SG_EmployeeVPNAccess", "SG_KnowBe4", "SG_File_BaseAccess", "SG_DocuSign_EDHC_CA")
                        add-UserToBaseGroups -SamAccountName $UserAccountInfo.SamAccountName -BaseGroups $BaseGroups -LogFile $LogFile
                        }
            }
            }
        catch
            {
            Write-Host "User account does not exists"
           

                $ManagerInfo= Get-ADUser -Identity $Manager -Properties * -ErrorAction SilentlyContinue
                if($ManagerInfo)
                    {

                    #If manager is found making new accounts
                    try
                        {
                        New-ADUser -GivenName $GivenName -Surname $Surname -Name $Name -DisplayName $DisplayName `
                        -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName `
                        -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -Enabled $true `
                        -Title $Title -Department $Department -Description $Description -EmailAddress $EmailAddress `
                        -Path "OU=New Users,OU=People,DC=corp,DC=edhc,DC=com" -Manager $ManagerInfo.SamAccountName -Company $Company -ErrorAction Stop
                        Write-Host "$DisplayName account is made with Manager info"
                        Add-Content -Path $LogFile -Value "$DisplayName account is made with manager info"
                        }
                    catch
                        {
                        Add-Content -Path $LogFile -Value "Creating $DisplayName account"
                        Write-Host "Unable to create new account (Manager account is found)"
                        }
                    }
                else
                    {

                    #If Manager is not found making new accounts
                    try
                        {
                        Add-Content -Path $LogFile -Value "Creating $DisplayName account"
                        New-ADUser -GivenName $GivenName -Surname $Surname -Name $Name -DisplayName $DisplayName `
                        -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName `
                        -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -Enabled $true `
                        -Title $Title -Department $Department -Description $Description -EmailAddress $EmailAddress `
                        -Path "OU=New Users,OU=People,DC=corp,DC=edhc,DC=com" -Company $Company -ErrorAction Stop
                        Write-Host "$DisplayName account is made without Manager info"
                        Add-Content -Path $LogFile -Value "$DisplayName account is made without manager info"
                        }
                    catch
                        {
                        Add-Content -Path $LogFile -Value "Unable to create new account (Manager account is not found)"
                        Write-Host "Unable to create new account (Manager account is not found)"
                        }
                    }           

            #Checking if the account is created and available in AD or not.

  Start-Sleep -Seconds 5          
                $UserAccountInfoPostCreation= Get-ADUser -Identity $SamAccountName -Properties * -ErrorAction SilentlyContinue
                if($UserAccountInfoPostCreation)
                    {
                    Write-Host "User account is found in AD"
                    try
                        {
                        Set-ADUser -Identity $UserAccountInfoPostCreation.SamAccountName -Replace @{info= $Hiredate} 
                        }
                    catch
                        {
                        Write-Host "Unable to update Hiring date for user $DisplayName"
                        }
                    #Assigning groups to user
                    $UserTitlePostAccountCreation= $UserAccountInfoPostCreation.Title
                    if($UserTitlePostAccountCreation -eq "Care Advocate")
                        {
                        try
                            {
                            #Getting RBAC memberships
                            $TemplateInfo = Get-ADUser -Identity catemplate -Properties MemberOf
                            $RelavantGroups = $TemplateInfo.MemberOf | Get-ADGroup | Select-Object Name
                            # Get current user to be added to groups
                            $CAUsers = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty SamAccountName
                            # Add the user to each group that the template is a member of
                            if($RelavantGroups)
                                {
                                foreach ($group in $RelavantGroups) 
                                    {
                                    Add-ADGroupMember -Identity $group.Name -Members $CAUsers
                                    Write-Host "Added $SamAccountName to $($group.Name)"
                                    Add-Content -Path $LogFile -Value "Added $SamAccountName to $($group.Name)" 
                                    }
                                 }   
                            else
                                {
                                Write-Host "Template is found but unable to retrive groups"
                                }
                            }

                        catch
                            {
                            Write-Host "catemplate is not found"
                            }
                        }
                    else
                        {
                        $BaseGroups = @("SG_EmployeeVPNAccess", "SG_KnowBe4", "SG_File_BaseAccess", "SG_DocuSign_EDHC_CA")
                        add-UserToBaseGroups -SamAccountName $UserAccountInfoPostCreation.SamAccountName -BaseGroups $BaseGroups -LogFile $LogFile
                        }          

                    }
                else
                    {
                    Write-Host "User account is not created properly please check for user $DisplayName"
                    }
           


    $UserAccountInfo= $null
    $UserAccountInfoPostCreation= $null
    $ManagerInfo= $null
    $TemplateInfo= $null
    $RelavantGroups= $null
    $UserTitlePostAccountCreation=$null
    }
    }


Write-Host "Starting Exchange assignments"
Start-Sleep -Seconds 1200

foreach ($User in $OnboardingUsersData) 
    {
    $SamAccountName = $User.SamAccountName
    $UserPrincipalName= $User.UserPrincipalName
  
    if($SamAccountName)
        {
        # Retrieve the user from Active Directory
        $TargetUser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName}

        if ($null -ne $TargetUser) 
            {
            Write-Host "Found user: $($TargetUser.SamAccountName)"
            Add-Content -Path $LogFile -Value "Found user: $($TargetUser.SamAccountName)"

            # Get the user's email address
            $UserEmailAddress = $TargetUser.UserPrincipalName
            $AzureUserInfo= Get-MgUser -Filter "UserPrincipalName eq '$UserPrincipalName'" -Property *
            $AzureUserID= $AzureUserInfo.Id
            Update-MgUser -UserId $AzureUserId -UsageLocation 'US'           
            Add-AzureADGroupMember -ObjectId 7117a04c-2fe0-4029-9546-973ed72c54ed -RefObjectId $AzureUserID
            $SKUID= "05e9a617-0261-4cee-bb44-138d3ef5d965"
            Set-MgUserLicense -UserId $AzureUserInfo.Id -AddLicenses @{SKUId=$SKUID} -RemoveLicenses @()

            # Add the user to each distribution list
            $DistributionList = @("all@edhc.com")
            foreach ($dl in $DistributionList) 
                {
                Add-DistributionGroupMember -Identity $dl -Member $UserEmailAddress
                Write-Output "Added $($TargetUser.SamAccountName) to $dl"
                Add-Content -Path $LogFile -Value "Added $($TargetUser.SamAccountName) to $dl"
                }

            $MailEnabledSecurityGroup = @("defend_users@edhc.com")
            foreach ($SG in $MailEnabledSecurityGroup) 
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
    else
        {
        Write-Host "End of CSV file"
        }
    
    }

