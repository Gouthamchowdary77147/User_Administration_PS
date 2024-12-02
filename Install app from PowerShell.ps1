# Define the username and password
$username = "edhc.com\ep.goutham.gummadi"
$password = "Chowdary.h3025"

# Convert the plain text password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create a PSCredential object
$cred = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Start the process with the credentials
Start-Process -FilePath "S:\Technology\Infrastructure\Goutham Automation\SSMS-Setup-ENU.exe" -Credential $cred
