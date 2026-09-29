# Silent Installer (Installing softwares in remote VM)
# Installs all components from the bundled package

param(
    [string]$ComponentDir = "C:\DevOpsToolkit\components",
    [string]$LogDir = "C:\DevOpsToolkit\logs"
)

# Create log directory
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$logFile = Join-Path $LogDir "install-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}


Write-Log "  DevOps Toolkit Silent Installer"
Write-Log "  Machine: $env:COMPUTERNAME"
Write-Log "============================================"

$results = @()

# ---- 1. Install Notepad++ ----
Write-Log "Installing Notepad++..."
$nppInstaller = Join-Path $ComponentDir "npp-installer.exe"
if (Test-Path $nppInstaller) {
    $proc = Start-Process -FilePath $nppInstaller -ArgumentList "/S" -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Log "Notepad++ installed successfully"
        $results += @{Name="Notepad++"; Status="Success"}
    } else {
        Write-Log "Notepad++ failed (exit code: $($proc.ExitCode))"
        $results += @{Name="Notepad++"; Status="Failed"}
    }
} else {
    Write-Log "Notepad++ installer not found"
    $results += @{Name="Notepad++"; Status="Not Found"}
}

# ---- 2. Install Git ----
Write-Log "Installing Git..."
$gitInstaller = Join-Path $ComponentDir "git-installer.exe"
if (Test-Path $gitInstaller) {
    $proc = Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Log "Git installed successfully"
        $results += @{Name="Git"; Status="Success"}
    } else {
        Write-Log "Git failed (exit code: $($proc.ExitCode))"
        $results += @{Name="Git"; Status="Failed"}
    }
} else {
    Write-Log "Git installer not found"
    $results += @{Name="Git"; Status="Not Found"}
}

# ---- 3. Install Python ----
Write-Log "Installing Python..."
$pyInstaller = Join-Path $ComponentDir "python-installer.exe"
if (Test-Path $pyInstaller) {
    $proc = Start-Process -FilePath $pyInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Log "Python installed successfully"
        $results += @{Name="Python"; Status="Success"}
    } else {
        Write-Log "Python failed (exit code: $($proc.ExitCode))"
        $results += @{Name="Python"; Status="Failed"}
    }
} else {
    Write-Log "Python installer not found"
    $results += @{Name="Python"; Status="Not Found"}
}

# ---- 4. Install AWS CLI ----
Write-Log "Installing AWS CLI..."
$awsInstaller = Join-Path $ComponentDir "awscli-installer.msi"
if (Test-Path $awsInstaller) {
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$awsInstaller`" /quiet /norestart" -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Log "AWS CLI installed successfully"
        $results += @{Name="AWS CLI"; Status="Success"}
    } else {
        Write-Log "AWS CLI failed (exit code: $($proc.ExitCode))"
        $results += @{Name="AWS CLI"; Status="Failed"}
    }
} else {
    Write-Log "AWS CLI installer not found"
    $results += @{Name="AWS CLI"; Status="Not Found"}
}



Write-Log "============================================"
Write-Log "  Installation Summary"
Write-Log "============================================"

$failed = 0
foreach ($r in $results) {
    Write-Log "  $($r.Name): $($r.Status)"
    if ($r.Status -ne "Success") { $failed++ }
}

Write-Log ""
Write-Log "  Total: $($results.Count) | Passed: $($results.Count - $failed) | Failed: $failed"
Write-Log "  Log: $logFile"
Write-Log "============================================"

if ($failed -gt 0) {
    Write-Log "Some installations failed!"
    exit 1
}

Write-Log "All installations completed successfully!"
exit 0

