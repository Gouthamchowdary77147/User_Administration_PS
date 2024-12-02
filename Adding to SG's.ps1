$name = @("brittney.rahming")
$GroupNames = @("SG_CCD_File_AZ_MemberServices_m","SG_CCD_File_AZ_MemberServices_rw","SG_CCD_File_AZ_MemberServices_r")

foreach ($CurrentName in $name) {
    $User = Get-ADUser -Identity $CurrentName -Properties *
    $SAM= $User.SamAccountName
    
    if ($User -ne $null) {
        # Loop through the group names and add the user to each group
        foreach ($GroupName in $GroupNames) {
        $Group= get-adgroup -Identity $GroupName
            Add-ADGroupMember -Identity $Group -Members $SAM
            Write-Host "Added $($User.SamAccountName) to $GroupName"
        }
    } else {
        Write-Host "User '$CurrentName' not found."
    }
}
