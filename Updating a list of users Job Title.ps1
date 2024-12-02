# Define the user data with their new job titles
$userData = @(
    @{
        UserName = "Felecia.Smith"
        NewJobTitle = "VP of Member Services"
    },
    @{
        UserName = "Alyssa.Bliven"
        NewJobTitle = "Director of Member Services"
    },
    @{
        UserName = "Lillian.Clemons"
        NewJobTitle = "Hub Supervisor"
    },
    @{
        UserName = "Shontietta.Wilson"
        NewJobTitle = "Hub Supervisor"
    },
    @{
        UserName = "Alexis.Porter"
        NewJobTitle = "Project Manager, Quality & Training"
    },
    @{
        UserName = "Isaac.Galarza"
        NewJobTitle = "Care Advocate Team Lead"
    },
    @{
        UserName = "Chastany.Beaver"
        NewJobTitle = "Care Advocate Team Lead"
    },
    @{
        UserName = "Masielle.Voelker"
        NewJobTitle = "Care Advocate Team Lead"
    },
    @{
        UserName = "Jarey.Lawson"
        NewJobTitle = "Quality Assurance Coach"
    },
    @{
        UserName = "Kadeem.AlUqdah"
        NewJobTitle = "Quality Assurance Coach"
    }
)

# Loop through the user data and update job titles
foreach ($user in $userData) {
    $userName = $user["UserName"]
    $newJobTitle = $user["NewJobTitle"]

    # Get the user by SamAccountName
    $userObject = Get-ADUser -Filter { SamAccountName -eq $userName }

    if ($userObject) {
        # Update the job title
        Set-ADUser -Identity $userObject -Title $newJobTitle -Description $newJobTitle
        Write-Host "Updated job title for $userName to $newJobTitle"
        Get-AdUser -Identity $userObject -Properties Title | Select-Object GivenName, Description, Title
    } else {
        Write-Host "User $userName not found."
    }
}
