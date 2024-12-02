#This code is used to convert an existing Contactor into FTE

#Connect to necessary Modules
 Connect-AzureAD
#We are connecting to only "AzureAD" Module as the changes are targetted to On premises only
#This code is made to run as long as you Say Yes to "Do you want to convert another user to FTE"
Do
    {
#Asking admin the name of the user to be converted to FTE  
#This code block runs as long as you are not entering correct SamAccountName
    
    $JIRATicketNumber = $null
    $UserBeingConvertedToFTENewDisplayName = $null
    $UserBeingConvertedToFTENewFirstName = $null
    $UserBeingConvertedToFTENewLastName = $null
    $UserBeingConvertedToFTENewSamAccountName = $null
    $UserBeingConvertedToFTENewEmailAddress = $null
    $UserBeingConvertedToFTENewUPN = $null
    $UserBeingConvertedToFTEInfo= $null

    do
        {
        $UserBeingConvertedToFTE= Read-Host "Enter the SamAccountName of the user to be converted to FTE:"
        try
            {
            $UserBeingConvertedToFTEInfo= Get-ADUser -Identity $UserBeingConvertedToFTE -Properties * -ErrorAction Stop
            $UserFound=$true
            }
        catch
            {
            Write-Host "No account found with SamAccountName: $UserBeingConvertedToFTE."
            }                
        }  
    while(-not $UserFound)
    
 
        $ChangeDate = Read-Host "Enter the date from which user will be FTE (This is a required field)"
        $JIRATicketNumber= Read-Host "Enter the JIRA ticket Number (This is a required field)"
       

    $NewManager= Read-Host "Enter New Manager SamAccountName (Click enter if no change in Manager)"
    if($null -ne $NewManager)
        {
        try
            {
            $NewManagerInfo= Get-ADUser -Identity $NewManager -Properties * -ErrorAction Stop
            $UserFound=$true
            }
        catch
            {
            Write-Host "No account found with SamAccountName: $UserBeingConvertedToFTE."69*
            } 
        }
    else
        {
         # Nothing needed here if no change is made to the manager
        }

    $UserBeingConvertedToFTEDisplayName= $UserBeingConvertedToFTEInfo.DisplayName
    $UserBeingConvertedToFTEFirstname= $UserBeingConvertedToFTEInfo.GivenName
    $UserBeingConvertedToFTELastName= $UserBeingConvertedToFTEInfo.SurName
    $UserBeingConvertedToFTESamAccountName= $UserBeingConvertedToFTEInfo.SamAccountName
    Write-Host "User Sam is $UserBeingConvertedToFTESamAccountName"
    $UserBeingConvertedToFTEEmailAddress= $UserBeingConvertedToFTEInfo.EmailAddress
    $UserBeingConvertedToFTEUPN= $UserBeingConvertedToFTEInfo.UserPrincipalName
    $UserBeingConvertedToFTEProxyaddresses= $UserBeingConvertedToFTEInfo.proxyAddresses
    $UserBeingConvertedToFTEAttributeInfo= $UserBeingConvertedToFTEInfo.info
    if($null -ne $NewManagerInfo)
        {
        $UserBeingConvertedToFTEManager= $NewManagerInfo.SamAccountName            
        }
    else
        {
        $UserBeingConvertedToFTEManager= $UserBeingConvertedToFTEInfo.Manager    
        }
            
#Check if the user DisplayName, GivenName, SurName, SamAccountName, Emailaddress, UPN has "ext." in it and remove it
    if($UserBeingConvertedToFTEDisplayName -match "ext\.")
        {
        $UserBeingConvertedToFTENewDisplayName= $UserBeingConvertedToFTEDisplayName.replace("ext.","") 
        }
    else
        {
        $UserBeingConvertedToFTENewDisplayName= $UserBeingConvertedToFTEDisplayName
        }
    if($UserBeingConvertedToFTEFirstname -match "ext\.")
        {
        $UserBeingConvertedToFTENewFirstName= $UserBeingConvertedToFTEFirstName.replace("ext.","")
        }
    else
        {
        $UserBeingConvertedToFTENewFirstName= $UserBeingConvertedToFTEFirstName
        }
    if($UserBeingConvertedToFTELastName -match "ext\.")
        {
        $UserBeingConvertedToFTENewLastName= $UserBeingConvertedToFTELastName.replace("ext.","")
        }
    else
        {
        $UserBeingConvertedToFTENewLastName= $UserBeingConvertedToFTELastName
        }
    if($UserBeingConvertedToFTESamAccountName -match "ext\.")
        {
        $UserBeingConvertedToFTENewSamAccountName = $UserBeingConvertedToFTESamAccountName.replace("ext.","")
        }
    else
        {
         $UserBeingConvertedToFTENewSamAccountName= $UserBeingConvertedToFTESamAccountName
        }
    if($UserBeingConvertedToFTEEmailAddress -match "ext\.")
        {
        $UserBeingConvertedToFTENewEmailAddress= $UserBeingConvertedToFTEEmailAddress.replace("ext.","")
        }
    else
        {
         $UserBeingConvertedToFTEEmailAddress= $UserBeingConvertedToFTEEmailAddress
        }
    if($UserBeingConvertedToFTEUPN -match "ext\.")
        {
        $UserBeingConvertedToFTENewUPN= $UserBeingConvertedToFTEUPN.replace("ext.","")
        }
    else
        {
         $UserBeingConvertedToFTENewUPN= $UserBeingConvertedToFTEUPN
        }
   
        Set-ADUser -Identity $UserBeingConvertedToFTESamAccountName -GivenName $UserBeingConvertedToFTENewFirstName -Surname $UserBeingConvertedToFTENewLastName -DisplayName $UserBeingConvertedToFTENewDisplayName -Company "Lantern" -SamAccountName $UserBeingConvertedToFTENewSamAccountName -EmailAddress $UserBeingConvertedToFTENewEmailAddress -UserPrincipalName $UserBeingConvertedToFTENewUPN -Add @{proxyaddresses= @("SMTP:$UserBeingConvertedToFTENewEmailAddress","smtp:$UserBeingConvertedToFTEEmailAddress")} -ErrorAction Stop
        $NewInfo= "Date Converted to FTE = $ChangeDate | Jira Ticket Number = $JIRATicketNumber"
        Set-ADUser -Identity $UserBeingConvertedToFTENewSamAccountName -Add @{info=$NewInfo} -ErrorAction Stop

        Write-Host "User is converted to FTE"
     
#Checking if the changes are made correctly or not
    try
        {
        $UserBeingConvertedToFTEInfoAfterChange= Get-ADUser -Identity $UserBeingConvertedToFTENewSamAccountName -Properties * -ErrorAction Stop
        Write-Host "Found user with FTE SamAccountName"
        }
    catch
        {
        Write-Host "User FTE account is not found"
        }
    if($UserBeingConvertedToFTEInfoAfterChange.DisplayName -cmatch $UserBeingConvertedToFTENewDisplayName -and $UserBeingConvertedToFTEInfoAfterChange.GivenName -cmatch $UserBeingConvertedToFTENewFirstName -and $UserBeingConvertedToFTEInfoAfterChange.SurName -cmatch $UserBeingConvertedToFTENewLastName -and $UserBeingConvertedToFTEInfoAfterChange.SamAccoutnName -cmatch $UserBeingConvertedToFTENewSamAccountName -and $UserBeingConvertedToFTEInfoAfterChange.UserPrincipalName -cmatch $UserBeingConvertedToFTENewUPN -and $UserBeingConvertedToFTEInfoAfterChange.EmailAddress -cmatch $UserBeingConvertedToFTENewEmailAddress)
        {
        Write-Host "User is converted to FTE Successfully"
        Get-ADUser -Identity $UserBeingConvertedToFTENewSamAccountName -Properties * | Select-Object DisplayName, GivenName, SurName, EmailAddress, UserPrincipalName, ProxyAddresses, Info
        }
    else
        {
        Write-Host "USer is not converted to FTE Successfully"
        }
    $Continue= Read-Host "Do you want to convert another user to FTE (Y/N)"            
    }
While($Continue -eq "Y")