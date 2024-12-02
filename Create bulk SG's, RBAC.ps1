Import-Module ActiveDirectory

# Define the CSV file path
$CSVFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\Birthrights\RBAC Bulk upload.csv"
$GroupsData = Import-Csv $CSVFilePath

# Log file path
$LogFilePath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\Birthrights\RBAC_Bulk_Upload_Log.txt"
Add-Content -Path $LogFilePath -Value "`n`nExecution Time: $(Get-Date)`n"

foreach ($group in $GroupsData) {
    try {
        $RBACName = $group.RBAC
        $RBACDescription = $group.Description
        $RBACManagedBy = $group.Manager
        $RBACDepartment = $group.Department

        # Clean the RBAC name
        $RBACName = $RBACName.Trim()
        $RBACName = $RBACName -replace '[\\/:*?"<>|]', ''

        # Get the owner (manager)
        $Owner = Get-ADUser -Filter "Name -eq '$($RBACManagedBy)'" -Properties SamAccountName
        
        if ($null -eq $Owner) {
            throw "Manager '$RBACManagedBy' not found in AD."
        }

        # Check if the group already exists
        $existingGroup = Get-ADGroup -Filter "Name -eq '$RBACName'" -ErrorAction SilentlyContinue
        
        if ($null -ne $existingGroup) {
            throw "Group '$RBACName' already exists."
        }

        # Create the AD group
        New-ADGroup -Name $RBACName -Description $RBACDescription -GroupCategory Security -ManagedBy $Owner.SamAccountName -GroupScope Global -Path "OU=$RBACDepartment,OU=RBAC,OU=Access Control,DC=corp,DC=edhc,DC=com"

        # Log success
        Add-Content -Path $LogFilePath -Value "Created group: $RBACName, Managed by: $($Owner.SamAccountName)"
    }
    catch {
        # Log error
        Add-Content -Path $LogFilePath -Value "Error creating group: $RBACName - $_"
    }
}

Write-Host "Execution complete. Check the log file for details: $LogFilePath"
