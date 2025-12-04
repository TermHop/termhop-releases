# install.ps1 - One-liner installer for TermHop Client (th) and Server (TermHop)
#

$ErrorActionPreference = "Stop"

Write-Host "TermHop Installer" -ForegroundColor Cyan
Write-Host "================"

# 1. Configuration
$Repo = "termhop/termhop-releases"
$InstallDir = "$env:LOCALAPPDATA\Programs\TermHop"
$BaseUrl = "https://github.com/$Repo/releases/latest/download"

# 2. Prepare Install Directory
if (-not (Test-Path -Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}
Write-Host "Installing to: $InstallDir" -ForegroundColor Gray

# 3. Download Files
# Windows binaries are always named th.exe and TermHop.exe in the release assets
# (based on build-and-publish.yml logic for Windows)

$WebClient = New-Object System.Net.WebClient

Write-Host "Downloading th.exe..." -NoNewline
$WebClient.DownloadFile("$BaseUrl/th.exe", "$InstallDir\th.exe")
Write-Host " OK" -ForegroundColor Green

Write-Host "Downloading TermHop.exe..." -NoNewline
$WebClient.DownloadFile("$BaseUrl/TermHop.exe", "$InstallDir\TermHop.exe")
Write-Host " OK" -ForegroundColor Green

# 4. Add to PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Adding to User PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path += ";$InstallDir"
    Write-Host "Path updated. You may need to restart your terminal." -ForegroundColor Yellow
}

# 5. Generate/Get Key
Write-Host "Generating/Retrieving Auth Key..." -NoNewline
$Key = & "$InstallDir\th.exe" -get-key
Write-Host " OK" -ForegroundColor Green

Write-Host ""
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "--------------------------------------------------"
Write-Host "Next Steps:"
Write-Host "1. Add the following key to your server's TermHop.yaml:"
Write-Host "$Key" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. **RESTART** the TermHop server (Right-click Tray -> Restart)."
Write-Host "3. Run 'th -init' to connect and configure your client."
Write-Host "--------------------------------------------------"
