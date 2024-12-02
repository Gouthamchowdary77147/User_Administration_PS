# Open the HTML form in the default web browser
Start-Process "S:\Technology\Infrastructure\Goutham Automation\Security Group Creation HTML code.html" -WindowStyle Hidden

do {
    # Prompt for SG/ASG type
while ($true) {
    Write-Host "Close the Powershell Console"
    $TypeOfSG = Read-Host "What type of SG do you want to create? (Enter ASG for Azure SG and SG for On-prem)" 
    
    if ($TypeOfSG -eq "SG" -or $TypeOfSG -eq "ASG") {
        break
    }
    else {
        Write-Host "Invalid input. Please enter 'SG' for On-prem or 'ASG' for Azure SG only."
    }
}

# Prompt for subscription if ASG
if ($TypeOfSG -eq "ASG") {
    while ($true) {
        $Subscription = Read-Host "Enter the name of the Subscription this ASG is going to be used in (LC/BusOps/CCD/SPlus/LCNP)"
        if ($Subscription -in @("LC", "BusOps", "CCD", "SPlus", "LCNP")) {
            break
        }
        else {
            Write-Host "Invalid Input. Please enter 'LC', 'BusOps', 'CCD', 'SPlus', or 'LCNP'"
        }
    }
}

# Department List
$ListOfDepartments = @{
    "Account Management" = "AM"
    "Accounting" = "ACC"
    "Business Development" = "BD"
    "Business Operations" = "BUOPS"
    "Cancer Care Direct Delivery" = "CCD"
    "Claims" = "CMS"
    "Client Operations" = "COPS"
    "Consultant Relations" = "CRL"
    "Core Technology" = "CT"
    "Data Management" = "DM"
    "Engineering" = "ENG"
    "FP&A and Analytics" = "AL"
    "Human Resource" = "HR"
    "Information Security" = "IS"
    "Legal" = "LGL"
    "Marketing" = "MKT"
    "Member Services" = "MS"
    "Network Development" = "ND"
    "Partnerships" = "PTS"
    "Product" = "PRD"
    "Quality" = "QA"
    "Strategy" = "STGY"
}

# Display departments
foreach ($dept in $ListOfDepartments.GetEnumerator()) {
    Write-Host "$($dept.Key) = $($dept.Value)"
}

# Prompt for department abbreviation
while ($true) {
    $Department = Read-Host "Enter the Abbreviation of the department which owns the SG/ASG"
    if ($ListOfDepartments.Values -contains $Department) {
        Write-Host "Valid abbreviation: $Department"
        break
    }
    else {
        Write-Host "Invalid abbreviation. Please try again."
    }
}

# Prompt for additional details
Write-Host "Please use the complete name of the Application/Device/Server/VM/Service/Repo..." -ForegroundColor Red
$Application = Read-Host "Enter the name of the Application/Device/Server/VM/Service/Process/Repository.. that this SG/ASG gives access to or relates to"
$Environment = Read-Host "Enter the environment of the application (PRD, STG, DEV, TST, UAT) or type of application/software/plugin"
$TypeofData = Read-Host "Enter the type of data the SG/ASG gives access to (SQL, ETL, FileShare, SRS, PHI, STD, ALL)"
$TypeOfAccess = Read-Host "Enter the type of Access this SG/ASG gives to user (Super Admin(SA), Admin, Read(R), ReadWrite(RW), Write(W), Local Admin(LA), Read Masked(RM), Execute Procedures(ExeP), Read Only(RO), ByPass(BP))"
$TypeOfAccount = Read-Host "If the SG/ASG is giving access to any PRD and STG environments, enter EP else REG"

# Constructing SG Name
if ($TypeOfSG -eq "SG") {
    $SGName = "$TypeOfSG`_$Department"
    
    if ($Application) { $SGName += "_$Application" }
    if ($Environment) { $SGName += "_$Environment" }
    if ($TypeofData) { $SGName += "_$TypeofData" }
    if ($TypeOfAccess) { $SGName += "_$TypeOfAccess" }
    if ($TypeOfAccount -eq "EP") { $SGName += "_$TypeOfAccount" }
    
} else {
    $SGName = "$TypeOfSG`_$Subscription`_$Department"
 
    if ($Application) { $SGName += "_$Application" }
    if ($Environment) { $SGName += "_$Environment" }
    if ($TypeofData) { $SGName += "_$TypeofData" }
    if ($TypeOfAccess) { $SGName += "_$TypeOfAccess" }
    if ($TypeOfAccount -eq "EP") { $SGName += "_$TypeOfAccount" }
}



# Output the final SG Name
Write-Host "Final Name is: $SGName"
# Loop to keep the executable open until user decides to exit
while ($true) {
    $exitInput = Read-Host "Type 'Exit' to close the application"
    if ($exitInput -eq "Exit") {
        Write-Host "Exiting the application..."
        break
    }
    else {
        Write-Host "Invalid input. Please type 'Exit' to close the application."
    }
}
$Continue= Read-Host "Do you want to make another SG name?(Y/N)"
} while (
    $Continue -eq "Y"
)
