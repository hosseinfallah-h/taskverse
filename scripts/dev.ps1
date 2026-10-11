# ============================================================
# TaskVerse - Dev launcher (PowerShell)
# Activates venv and starts uvicorn from the backend folder.
# Works in both PowerShell 5.1 and PowerShell 7+.
# ============================================================

$ErrorActionPreference = "Stop"

# Force UTF-8 output so we see clean text
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

$repoRoot    = Resolve-Path (Join-Path $PSScriptRoot "..")
$backendPath = Join-Path $repoRoot "backend"
$venvActivate = Join-Path $backendPath "venv\Scripts\Activate.ps1"

# --- Ensure venv exists ---
if (-not (Test-Path $venvActivate)) {
    Write-Host "[setup] Creating venv..." -ForegroundColor Yellow
    Push-Location $backendPath
    python -m venv venv
    Pop-Location
    Write-Host "[ok] venv created" -ForegroundColor Green
}

# --- Activate ---
& $venvActivate
Write-Host "[ok] venv activated" -ForegroundColor Green

# --- Move into backend so 'app' is importable ---
Set-Location $backendPath

# --- Ensure deps installed ---
$marker = Join-Path $backendPath "venv\.deps_installed"
if (-not (Test-Path $marker)) {
    Write-Host "[setup] Installing dependencies..." -ForegroundColor Yellow
    python -m pip install --upgrade pip
    pip install -r requirements-dev.txt
    New-Item -ItemType File -Force -Path $marker | Out-Null
    Write-Host "[ok] deps installed" -ForegroundColor Green
}

# --- Ensure .env exists ---
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "[setup] .env created from .env.example - review it!" -ForegroundColor Yellow
}

# --- Start uvicorn ---
Write-Host ""
Write-Host "Starting uvicorn on http://localhost:8000" -ForegroundColor Cyan
Write-Host "  Docs: http://localhost:8000/docs"        -ForegroundColor Cyan
Write-Host "  Stop: Ctrl+C"                            -ForegroundColor Cyan
Write-Host ""

uvicorn app.main:app --reload --port 8000 --host 0.0.0.0