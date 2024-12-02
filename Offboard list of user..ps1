# Connect to Azure AD
Connect-AzAccount

$OffboardList = @("User1", "User2")  # Add your user display names here

foreach ($OB in $OffboardList) {
    $User = Get-ADUser -Filter { DisplayName -eq $OB }
    Add-ADGroupMember -Identity "Terminated Users" -Members $User

    if ($User) {
        Set-ADUser -Identity $User -Enabled $false
        $RGM = Get-ADPrincipalGroupMembership -Identity $User

        if ($RGM -contains "Domain Users") {
            Write-Host "Skipping Domain"
        } else {
            foreach ($Group in $RGM) {
                Remove-ADGroupMember -Identity $Group -Members $User
                Write-Output "Removed $User from $Group"
            }
        }
        Move-ADObject
    }
     else {
        Write-Host "User $OB not found."
    }


}
