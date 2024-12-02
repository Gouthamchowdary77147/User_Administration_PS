Connect-ExchangeOnline
#Getting Current Date and Time
$CurrentDateTime= Get-Date -Format "mm-dd-yyy-hh-mm"
#Input CSV file
$ImportFilePath= "C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\Bulk Active Directory.csv"
#Output Log File
$LogFile="C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\User Log files\UserLogFile-$CurrentDateTime.txt"
$ExchangeLogfile= "C:\Users\ext.goutham.gummadi\EDHC\Technology - Infrastructure\Onboarding Automation files\Exchange Logfile\ExchangeLogFile-$CurrentDateTime.txt"
#Importing Input data
$OnboardingUsersData= Import-Csv -Path $ImportFilePath
Add-Content -Path $LogFile -Value "Starting Script $CurrentDateTime"
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
	
	#Checking if the user account already exists
    try
        {
	    $UserAccountInfo= Get-ADUser -Identity $SamAccountName -Properties *
	    if($UserAccountInfo)
            {
            Add-Content -Path $LogFile -Value "$DisplayName account already exists"
            Write-Host "$DisplayName account already exists"
                        #Updating Info Tab
            }
        }
     catch
        {
        Add-Content -Path $LogFile -Value "Creating $DisplayName account"
        Write-Host "Creating $DisplayName account"
        #Creating User account
        $ManagerInfo= Get-ADUser -Identity $Manager -Properties *
         try 
            {
            New-ADUser -GivenName $GivenName -Surname $Surname -Name $Name -DisplayName $DisplayName `
                -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName `
                -AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) -Enabled $true `
                -Title $Title -Department $Department -Description $Description -EmailAddress $EmailAddress `
                -Path "OU=New Users,OU=People,DC=corp,DC=edhc,DC=com" -Manager $ManagerInfo.SamAccountName -Company $Company
            }
        catch 
            {
            Add-Content -Path $LogFile -Value "Failed to create user account for $DisplayName : $_"
            Write-Host "Failed to create user account for $DisplayName : $_"
            continue
            }
        #Checking if the account is created or not
        $UserAccountInfo= Get-ADUser -Identity $SamAccountName -Properties *
        if($UserAccountInfo)
            {
            #Updating Info Tab
            try
                {
                Set-ADUser -Identity $SamAccountName -Replace @{info= $Hiredate}
                }
            catch
                {
                Write-Host "Unable to update Info tab for user $DisplayName"
                Add-Content -Path $LogFile -Value "Unable to update Info tab for user $DisplayName"
                }
                #checking if the user is a Care Advocate or not
            if($UserAccountInfo.title -like "Care Advocate")
                 {
                  try
                     {
                      #Getting memberships from RBAC
                      $TemplateInfo= Get-ADuser -Identity catemplate -Properties *
                      $RelavantGroups= Get-ADPrincipalGroupMembership -Identity $TemplateInfo.SamAccountName 
                      if($RelevantGroups)
                            {                           
                            foreach($Group in $RelevantGroups)
                                {
                                try
                                    {
                                    Add-ADGroupMember -Identity $Group -Members $UserAccountInfo.SamAccountName
                                    Add-Content -Path $LogFile -Value "Added $SamAccountName to group $($Group.Name)"
                                    }
                                catch
                                    {
                                    Write-Host "Unable to add $Group to $($Useraccountinfo.DisplayName)"
                                    Add-Content -Path $LogFile -Value "Unable to add $Group to $($Useraccountinfo.DisplayName)"
                                    }
                                }
                            }
                        else
                            {
                            Write-Host "RelevantGroups are not found for user $($UserAccountInfo.DisplayName)"
                            Add-Content -Path $LogFile -Value "RelevantGroups are not found for user $($UserAccountInfo.DisplayName)"
                            }               
                        }
                    catch
                        {
                        Add-Content -Path $LogFile -Value "Unable to find Membership of CaTemplate for user $DisplayName"
                        Write-Host "Unable to find M<embership of CaTemplate for user $DisplayName"
                        }
                }
                else
                    {
                    $BaseGroups = @("SG_EmployeeVPNAccess", "SG_KnowBe4", "SG_File_BaseAccess", "SG_DocuSign_EDHC_CA")
                    foreach ($Group in $BaseGroups) 
                        {
                        try 
                            {
                            Add-ADGroupMember -Identity $Group -Members $UserAccountInfo.SamAccountName
                            Add-Content -Path $LogFile -Value "Added $($UserAccountInfo.SamAccountName) to base group $Group"
                            }
                        catch 
                            {
                            Write-Host "Unable to add $($UserAccountInfo.SamAccountName) to base group $Group"
                            Add-Content -Path $LogFile -Value "Unable to add $($UserAccountInfo.SamAccountName) to base group $Group : $_"
                            }
                        }
           
                    }   
            }
        }
        $UserAccountInfo=$null
    }
Write-Host "Starting Exchange assignments"
Start-Sleep -Seconds 1200

#Assigning Distro's to user accounts.


foreach($User in $OnboardingUsersData)
    {
    $SamAccountName = $User.SamAccountName
    try
        {
        #Checking if the input SamAccountName account exists
        $UserAccountInfo= Get-ADUser -Identity $SamAccountName -Properties *
        $UserEmailaddress= $UserAccountInfo.UserPrincipalName
        if($UserAccountInfo)
            {
            Write-Host "$($UserAccountInfo.DisplayName) account is found for Echange assignments"
            Add-Content -Path $ExchangeLogfile -Value "$($UserAccountInfo.DisplayName) account is found for Echange assignments"
            $UserEmailAddress = $UserAccountInfo.UserPrincipalName
            $DistributionList = @("all@edhc.com")
            # Add the user to each distribution list
            foreach ($dl in $DistributionList) 
                {
                try
                    {
                    Add-DistributionGroupMember -Identity $dl -Member $UserEmailAddress
                    Write-Output "Added $($UserAccountInfo.SamAccountName) to $dl"
                    Add-Content -Path $ExchangeLogfile -Value "Added $($UserAccountInfo.DisplayName) to $dl"
                    }
                Catch
                    {
                    Write-Host "Error: $($_.Exception.Message)"
                    Add-Content -Path $ExchangeLogfile -Value "Error adding $($UserAccountInfo.DisplayName) to $dl : $ErrorMessage"
                    }
                }

            $MailEnabledSecurityGroup = @("defend_users@edhc.com")
            foreach ($SG in $MailEnabledSecurityGroup) 
                {
                try
                    {
                    Add-DistributionGroupMember -Identity $SG -Member $UserEmailAddress
                    Add-Content -Path $ExchangeLogfile -Value "Added $($UserAccountInfo.DisplayName) to $SG"
                    Write-Output "Added $($UserAccountInfo.SamAccountName) to $SG"
                    }
                Catch
                    {
                    Write-Host "Error: $($_.Exception.Message)"
                    Add-Content -Path $ExchangeLogfile -Value "Error adding $($UserAccountInfo.DisplayName) to $SG : $ErrorMessage"
                    }
                }
            }
        }
    Catch
        {
        $ErrorMessage = $_.Exception.Message
        Add-Content -Path $ExchangeLogfile -Value "$SamAccountName user is not found for Exchange assignments"
        Write-Host "$SamAccountName user is not found for Exchange assignments"
        }
        $UserAccountInfo=$null
    }