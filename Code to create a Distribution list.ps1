do {
    # Prompt for all necessary information to create the distribution list
    $DisplayName = Read-Host "Enter the Display Name of the Distro"
    $DistroEmailAddress = Read-Host "Enter Distro Email Address"
    $DistroDescription = Read-Host "Enter Description of the Distribution List"
    $DistroOwner = Read-Host "Enter the Email Address of the Owner"
    $DistroMembers = Read-Host "Enter the Email Address of the members separated by ','"
    $DistroMembersList = @($DistroMembers.Split(","))  # Split members by comma into an array
    $DistroType = Read-Host "Enter 'Distribution' for Distribution List and 'Security' for Mail Enabled Security Group"

    # Check that all fields are filled
    if ($null -ne $DisplayName -and $null -ne $DistroEmailAddress -and $null -ne $DistroDescription -and $null -ne $DistroOwner -and $null -ne $DistroMembers -and $null -ne $DistroType) {
        try {
            # Create the distribution group with provided details
            New-DistributionGroup -DisplayName $DisplayName -Alias $DisplayName -Description $DistroDescription -ManagedBy $DistroOwner -Type $DistroType -ErrorAction Stop -PrimarySmtpAddress $DistroEmailAddress -Name $DisplayName
            Write-Host "Distro with Email Address $DistroEmailAddress is created" -ForegroundColor Cyan

            # Loop through each member in the list and add them to the distro
            foreach ($Member in $DistroMembersList) {
                try {
                    Add-DistributionGroupMember -Identity $DistroEmailAddress -Member $Member -ErrorAction Stop
                    Write-Host "Added $Member to Distro $DistroEmailAddress" -ForegroundColor Cyan
                }
                catch {
                    Write-Host "Unable to add $Member to Distro $DistroEmailAddress" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "Unable to create Distro with Email Address $DistroEmailAddress" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Please ensure all required fields are filled." -ForegroundColor Yellow
    }

    # Ask if the user wants to create another distribution list
    $Continue = Read-Host "Enter YES to create another Distro or enter EXIT"
} while ($Continue -eq "YES")
