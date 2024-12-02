# Parameters
$SharePointSiteUrl = "https://employerdirect.sharepoint.com/_layouts/15/sharepoint.aspx"
$RelativeFilePath = "/:x:/r/sites/ITHelpdeskTeam/_layouts/15/Doc.aspx?sourcedoc=%7BC8B91A87-6AEB-498A-8AF3-C103B338376B%7D&file=HRJIRA.xlsx&action=default&mobileredirect=true"
$LocalDownloadPath = "C:\Users\ext.goutham.gummadi\OneDrive - EDHC\Desktop\CA Bulk CSV's MASTER\TESTING"
$WaitTimeInSeconds = 3  # Time to wait in seconds (1 hour in this example)

# Function to download the file
function Download-SharePointFile {
    param (
        [string]$SharePointSiteUrl,
        [string]$RelativeFilePath,
        [string]$LocalDownloadPath
    )
    
    Connect-PnPOnline -Url $SharePointSiteUrl -UseWebLogin
  Get-PnPTenantSite -Url $RelativeFilePath | ForEach-Object {
        $web = $_.Web
        $file = $_.File
        $fileStream = $web.GetFileByServerRelativeUrl($file.ServerRelativePath).OpenBinaryStream()
        $fileStream.Stream.CopyTo([System.IO.File]::Create($LocalDownloadPath))
    }
        Disconnect-PnPOnline
}

# Wait for the specified time
Write-Host "Waiting for $($WaitTimeInSeconds) seconds before downloading..."
Start-Sleep -Seconds $WaitTimeInSeconds

# Download the SharePoint file
Write-Host "Downloading SharePoint file..."
Download-SharePointFile -SharePointSiteUrl $SharePointSiteUrl -RelativeFilePath $RelativeFilePath -LocalDownloadPath $LocalDownloadPath
