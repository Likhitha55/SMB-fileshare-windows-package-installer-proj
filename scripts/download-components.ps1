# Download Component Installers from Official Sources
# Works on both Windows (native) and Linux (pwsh)

param(
    [string]$OutputDir = "./components"
)

Write-Host "  Downloading Component Installers"
Write-Host "  Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "============================================"

# Create output directory
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# Define components to download
$components = @(
    @{
        Name = "Notepad++"
        Url  = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.1/npp.8.7.1.Installer.x64.exe"
        File = "npp-installer.exe"
    },
    @{
        Name = "Git"
        Url  = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.1/Git-2.47.0-64-bit.exe"
        File = "git-installer.exe"
    },
    @{
        Name = "Python"
        Url  = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe"
        File = "python-installer.exe"
    },
    @{
        Name = "AWS CLI"
        Url  = "https://awscli.amazonaws.com/AWSCLIV2.msi"
        File = "awscli-installer.msi"
    }
)

$totalSize = 0

foreach ($comp in $components) {
    $outPath = Join-Path $OutputDir $comp.File
    Write-Host ""
    Write-Host "--- Downloading $($comp.Name) ---"
    Write-Host "  URL: $($comp.Url)"
    
    try {
        # Use curl on Linux, Invoke-WebRequest on Windows
        if ($IsLinux) {
            & curl -L -o $outPath $comp.Url --progress-bar
        } else {
            Invoke-WebRequest -Uri $comp.Url -OutFile $outPath -UseBasicParsing
        }
        
        $fileSize = (Get-Item $outPath).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
        $totalSize += $fileSize
        Write-Host "Downloaded: $($comp.File) ($fileSizeMB MB)"
    }
    catch {
        Write-Host "FAILED: $($comp.Name) - $_"
        exit 1
    }
}

$totalMB = [math]::Round($totalSize / 1MB, 2)
Write-Host ""
Write-Host "  All downloads complete!"
Write-Host "  Total size: $totalMB MB"
Write-Host "  Files in: $OutputDir"
Write-Host "============================================"

# List all downloaded files
Get-ChildItem $OutputDir | Format-Table Name, @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}}

