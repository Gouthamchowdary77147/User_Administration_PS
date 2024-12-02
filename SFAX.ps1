# Define variables
$URL = "https://app.sfaxme.com/appLogin.aspx?ReturnUrl=%2fsettingsUsers.aspx"
$ShortcutLocation = "$env:Public\Desktop\SFAX.lnk"

# Create a shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $URL
$Shortcut.Save()
