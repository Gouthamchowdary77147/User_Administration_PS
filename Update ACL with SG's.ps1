$CSVFilePath = Read-Host "Enter CSV File Path"
$LogFilePath = Read-Host "Enter Log File Path"
$DataImport = Import-Csv -Path $CSVFilePath

if ($DataImport.Count -eq 0) {
    Write-Host "CSV file at $CSVFilePath is empty"
    Add-Content -Path $LogFilePath -Value "CSV file at $CSVFilePath is empty"
    exit
}

foreach ($Group in $DataImport) {
    # Name of the resource
    $GroupName = $Group.GroupName
    # Name of the Job title
    $Title = $Group.JobTitle
    # Department of the Job Title
    $Department = $Group.Department
    # Category
    $Category = $Group.Category

    # Check if any of the input fields are empty
    if (-not $GroupName -or -not $Title -or -not $Department -or -not $Category) {
        Write-Host "Incomplete information in the CSV file for entry $($Group)"
        Add-Content -Path $LogFilePath -Value "Incomplete information in the CSV file for entry $($Group)"
        continue
    }

    try {
        # Check if the Input GroupName is available in AD or not
        $GroupInfo = Get-ADGroup -Filter { Name -eq $GroupName }
        if (-not $GroupInfo) {
            Write-Host "$GroupName not found"
            Add-Content -Path $LogFilePath -Value "$GroupName not found"
            continue
        }

        # Custom TitleName matching ACL in AD
        $TitleName = $Title -Replace "Director", "Dir" -Replace "Vice President", "VP" `
                              -Replace "Senior", "Sr" -Replace "Junior", "Jr" `
                              -Replace "\(", "" -Replace "\)", "" -Replace "\s", ""

        # Custom Category Matching ACL
        $CategoryName = $Category -Replace "\s", ""

        # Building ACL Name
        $ACLName = "ACL_CT_$TitleName`_$CategoryName"

        # Checking if the ACL is available or not
        $ACLGroup = Get-ADGroup -Filter { Name -eq $ACLName }
        if (-not $ACLGroup) {
            Write-Host "ACL group $ACLName not found"
            Add-Content -Path $LogFilePath -Value "ACL group $ACLName not found"
            continue
        }

        # Adding Input group as a member to ACLName we created above
        Add-ADGroupMember -Identity $ACLName -Members $GroupName
        Add-Content -Path $LogFilePath -Value "Added $GroupName to $ACLName"

    } catch {
        Write-Host "Unable to complete task for $GroupName"
        Add-Content -Path $LogFilePath -Value "Unable to complete task for $GroupName"
        continue
    }
}

# Retrieve and display members of each ACL group
foreach ($Group in $DataImport) {
    if ($ACLName) {
        $ACL = Get-ADGroup -Filter { Name -eq $ACLName }
        if ($ACL) {
            $Output = Get-ADGroupMember -Identity $ACL
            Write-Host "Members of $ACLName: $Output"
        }
    }
}
