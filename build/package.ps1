# Package Builder — Creating the distributable .zip bundle
# ============================================================

param(
    [string]$ComponentDir = "./components",
    [string]$ScriptDir = "./scripts",
    [string]$OutputDir = "./build/output"
)

Write-Host "============================================"
Write-Host "  Building DevOps Toolkit Package"
Write-Host "============================================"

# Create staging directory
$stagingDir = "./build/staging/DevOpsToolkit"
New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null
New-Item -ItemType Directory -Force -Path "$stagingDir/components" | Out-Null
New-Item -ItemType Directory -Force -Path "$stagingDir/scripts" | Out-Null
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# Copy components (downloaded installers)
Write-Host "Copying component installers..."
Copy-Item -Path "$ComponentDir/*" -Destination "$stagingDir/components/" -Force

# Copy scripts
Write-Host "Copying scripts..."
Copy-Item -Path "$ScriptDir/install-all.ps1" -Destination "$stagingDir/scripts/" -Force
Copy-Item -Path "$ScriptDir/verify-install.ps1" -Destination "$stagingDir/scripts/" -Force

# Copy launcher
Write-Host "Copying launcher..."
Copy-Item -Path "./build/INSTALL.bat" -Destination "$stagingDir/" -Force

# Create README
$readme = @"
============================================
  DevOps Toolkit Installer
  Built: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
============================================

CONTENTS:
  - Notepad++ (Text Editor)
  - Git (Version Control)
  - Python 3.12 (Programming Language)
  - AWS CLI v2 (Cloud Management)

HOW TO INSTALL:
  1. Extract this zip to any folder
  2. Right-click INSTALL.bat → Run as Administrator
  3. Wait for all installations to complete
  4. Check the verification report

SILENT INSTALL (Command Line):
  powershell -ExecutionPolicy Bypass -File scripts\install-all.ps1

VERIFY INSTALLATION:
  powershell -ExecutionPolicy Bypass -File scripts\verify-install.ps1
"@
Set-Content -Path "$stagingDir/README.txt" -Value $readme

# Create zip
$zipPath = Join-Path $OutputDir "DevOpsToolkit-Setup.zip"
Write-Host "Creating zip package..."

if ($IsLinux) {
    # Use zip command on Linux
    Push-Location "./build/staging"
    & zip -r "../../$zipPath" "DevOpsToolkit/"
    Pop-Location
} else {
    Compress-Archive -Path "$StagingDir\*" -DestinationPath "$OutputPath"
}

# Generate checksum
Write-Host "Generating checksum..."
if ($IsLinux) {
    $hash = & sha256sum $zipPath | ForEach-Object { $_.Split(" ")[0] }
} else {
    $hash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash
}
Set-Content -Path "$zipPath.sha256" -Value "$hash  DevOpsToolkit-Setup.zip"

# Summary
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Host ""
Write-Host "============================================"
Write-Host "  Package Built Successfully!"
Write-Host "  File: $zipPath"
Write-Host "  Size: $zipSize MB"
Write-Host "  SHA256: $hash"
Write-Host "============================================"

