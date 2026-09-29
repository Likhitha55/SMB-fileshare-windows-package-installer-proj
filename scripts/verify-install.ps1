# Verification Script, Checking all installed components
# Run on the TARGET Windows VM after installation
# ============================================================

param(
    [string]$ReportDir = "C:\DevOpsToolkit\reports"
)

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

$reportFile = Join-Path $ReportDir "verify-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

function Write-Report {
    param([string]$Message)
    Write-Host $Message
    Add-Content -Path $reportFile -Value $Message
}

Write-Report "  DevOps Toolkit Verification Report"
Write-Report "  Machine: $env:COMPUTERNAME"
Write-Report "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Report "============================================"
Write-Report ""

$checks = @()

# Refresh PATH so newly installed tools are found
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# ---- 1. Check Notepad++ ----
Write-Report "--- Notepad++ ---"
$nppPath = "C:\Program Files\Notepad++\notepad++.exe"
if (Test-Path $nppPath) {
    $version = (Get-Item $nppPath).VersionInfo.ProductVersion
    Write-Report "  Status: Installed"
    Write-Report "  Version: $version"
    Write-Report "  Path:    $nppPath"
    $checks += @{Name="Notepad++"; Status="PASS"; Version=$version}
} else {
    Write-Report "  Status: NOT FOUND"
    $checks += @{Name="Notepad++"; Status="FAIL"; Version="N/A"}
}

# ---- 2. Check Git ----
Write-Report ""
Write-Report "--- Git ---"
try {
    $gitVersion = & git --version 2>&1
    Write-Report "  Status: Installed"
    Write-Report "  Version: $gitVersion"
    $checks += @{Name="Git"; Status="PASS"; Version=$gitVersion}
} catch {
    Write-Report "  Status: NOT FOUND"
    $checks += @{Name="Git"; Status="FAIL"; Version="N/A"}
}

# ---- 3. Check Python ----
Write-Report ""
Write-Report "--- Python ---"
try {
    $pyVersion = & python --version 2>&1
    Write-Report "  Status: Installed"
    Write-Report "  Version: $pyVersion"
    $checks += @{Name="Python"; Status="PASS"; Version=$pyVersion}
} catch {
    Write-Report "  Status: NOT FOUND"
    $checks += @{Name="Python"; Status="FAIL"; Version="N/A"}
}

# ---- 4. Check AWS CLI ----
Write-Report ""
Write-Report "--- AWS CLI ---"
try {
    $awsVersion = & aws --version 2>&1
    Write-Report "  Status: Installed"
    Write-Report "  Version: $awsVersion"
    $checks += @{Name="AWS CLI"; Status="PASS"; Version=$awsVersion}
} catch {
    Write-Report "  Status: NOT FOUND"
    $checks += @{Name="AWS CLI"; Status="FAIL"; Version="N/A"}
}

# ---- Summary ----

Write-Report "============================================"
Write-Report "  Verification Summary"
Write-Report "============================================"

$passed = ($checks | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($checks | Where-Object { $_.Status -eq "FAIL" }).Count

foreach ($c in $checks) {
    Write-Report "  $($c.Status) | $($c.Name) | $($c.Version)"
}

Write-Report ""
Write-Report "  Total: $($checks.Count) | Passed: $passed | Failed: $failed"
Write-Report "  Report: $reportFile"
Write-Report "============================================"

if ($failed -gt 0) {
    Write-Report "VERIFICATION FAILED — $failed component(s) missing!"
    exit 1
}

Write-Report "ALL COMPONENTS VERIFIED SUCCESSFULLY!"
exit 0

