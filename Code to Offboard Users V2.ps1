Connect-ExchangeOnline | Out-Null
Connect-MgGraph | Out-Null
Connect-AzureAD | Out-Null
$SharedMailboxPath = "OU=Term: SharedMailboxes,OU=Terminated Users-Retain,DC=corp,DC=edhc,DC=com"
$NoSharedMailboxPath = "OU=Offboarded Users (No Sync),DC=corp,DC=edhc,DC=com"
do
{
    # Prompt for the user to offboard
    $OffboardedUser = Read-Host "Enter the SamAccountName of the user you want to offboard"

    # Finding if the user exists in Active Directory
    $UserInfo = Get-ADUser -Identity $OffboardedUser -Properties *
    $UserAzInfo= Get-MgUser -UserId $UserInfo.UserPrincipalName

    # Check if the user was found in AD
    if ($UserInfo) 
        {
        $LastWorkingDay = Read-Host "Enter Last Working day MM-DD-YYYY"
        $JIRANumber = Read-Host "Enter JIRA Ticket Number (HR-*****)"
        $NeedSharedMailbox = Read-Host "Need Shared Mailbox? (Y/N)"
        $UserSAM = $UserInfo.SamAccountName
        Write-Host "User SAM: $UserSAM"

        if ($NeedSharedMailbox -eq "Y") 
            {
            $Trustee = Read-Host "Enter the SamAccountName of the person who needs Shared Mailbox access"
            }

        $Title = $UserInfo.Title
        $Description = "OB | $Title | $LastWorkingDay | $JIRANumber"

        # Process group memberships
        $GroupMembership = Get-ADUser -Identity $UserSAM -Properties MemberOf | Select-Object -ExpandProperty MemberOf
        foreach ($Group in $GroupMembership) 
            {
            $GroupName = (Get-ADGroup -Identity $Group).Name
            Write-Host "Current Group is: $GroupName"
            if ($GroupName -ne "Domain Users") 
                {
                Remove-ADGroupMember -Identity $GroupName -Members $UserSAM -Confirm:$false
#Removing Azure AD Groups
#finding AZ Group information
                $GroupObjectId= (Get-MgGroup -Filter "DisplayName eq '$GroupName'").Id                
                try
                    {
                    Remove-AzureADGroupMember -ObjectId $GroupObjectID -MemberId $UserAzInfo.Id
                    }
                catch
                    {
                    # Display the error message in case of failure
                    Write-Host "Failed to remove user from group: $GroupName"
                    Write-Host "Error: $($_.Exception.Message)"
                    }
                } 
            else 
                {
                Write-Host "Not removing 'Domain Users' group"
                }
            }

        # Add user to Terminated Users group
        $TerminatedGroup = Get-ADGroup -Identity "TerminatedUsers"
        Add-ADGroupMember -Identity $TerminatedGroup.SamAccountName -Members $UserSAM -Confirm:$false

        # Update 'info' attribute with Offboarding date
        $UpdatedInfo = $UserInfo.info + "`n Offboarding Date - $LastWorkingDay | Offboarding TIcket Number- $JIRANumber"
        Set-ADUser -Identity $UserSAM -Description $Description -Replace @{info = $UpdatedInfo} -Clear Manager -Enabled $false

        # Set Primary Group ID (must be an integer, not a string)
        Set-ADUser -Identity $UserSAM -Replace @{primaryGroupID = 1716}

        # Remove user from 'Domain Users' group
        Remove-ADGroupMember -Identity "Domain Users" -Members $UserSAM -Confirm:$false

        # Converting to Shared Mailbox if needed
        if ($NeedSharedMailbox -eq "Y") 
            {
            $TrusteeInfo= Get-ADUser -Identity $Trustee -Properties *
            if ($TrusteeInfo) 
                {
                Set-Mailbox -Identity $UserInfo.UserPrincipalName -Type Shared
                Add-RecipientPermission -Identity $UserInfo.UserPrincipalName -Trustee $TrusteeInfo.UserPrincipalName -AccessRights SendAs
                Move-ADObject -Identity $UserInfo.DistinguishedName -TargetPath $SharedMailboxPath
                } 
            else 
                {
                Write-Host "Trustee Account not found"
                }
            } 
        else 
            {
            Write-Host "User does not need Shared Mailbox"
            }

        # Remove Licenses and Azure groups
        $UPN = $UserInfo.UserPrincipalName
        $UserAZInfo = Get-MgUser -Filter "Startswith(UserPrincipalName,'$UPN')"
        $LicenceInfo = Get-MgUserLicenseDetail -UserId $UserAZInfo.Id
        $LicenceInfo | ForEach-Object {
                                        Set-MgUserLicense -UserId $UserAZInfo.Id -AddLicenses @() -RemoveLicenses @($_.SkuId) | Out-Null
                                        }
        
        Move-ADObject -Identity $UserInfo.DistinguishedName -TargetPath $NoSharedMailboxPath
        } 
     else 
        {
        Write-Host "User not found in Active Directory."
        }

    $Continue = Read-Host "Do you want to offboard another user?(Y/N):"
} while ($Continue -eq "Y")

Write-Host "Script executed successfully" -ForegroundColor Red
