# ============================================================
# TaskVerse - Ultimate flutter run
# Rebuilds the ADB reverse bridge, verifies it, then launches.
# ============================================================

$ErrorActionPreference = "Continue"

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$mobilePath = Join-Path $repoRoot "mobile"

Write-Host "[1/5] Killing stale adb daemon..." -ForegroundColor Cyan
adb kill-server 2>&1 | Out-Null
Start-Sleep -Milliseconds 400

Write-Host "[2/5] Starting adb daemon..." -ForegroundColor Cyan
adb start-server 2>&1 | Out-Null
Start-Sleep -Milliseconds 800

Write-Host "[3/5] Checking device..." -ForegroundColor Cyan
$devices = adb devices | Out-String
Write-Host $devices

# Look for any line like: <serial><whitespace>device
$hasDevice = ($devices -split "`n" | Where-Object {
    $_ -match "^\S+\s+device\s*$"
}).Count -gt 0

if (-not $hasDevice) {
    Write-Host ""
    Write-Host "[ERROR] No device online." -ForegroundColor Red
    Write-Host "  Fix: unlock phone, replug USB, accept the prompt." -ForegroundColor Yellow
    Write-Host "  Then re-run this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "[4/5] Building ADB reverse bridge..." -ForegroundColor Cyan
adb reverse --remove-all 2>&1 | Out-Null
adb reverse tcp:8000 tcp:8000 2>&1 | Out-Null
$bridge = adb reverse --list
Write-Host $bridge
if ($bridge -notmatch "tcp:8000") {
    Write-Host "[ERROR] Reverse bridge failed." -ForegroundColor Red
    exit 1
}

Write-Host "[5/5] Launching flutter run..." -ForegroundColor Cyan
Write-Host ""
Set-Location $mobilePath
flutter run