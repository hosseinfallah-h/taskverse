# ============================================================
# TaskVerse - Test runner
# ============================================================

$ErrorActionPreference = "Stop"

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

$repoRoot    = Resolve-Path (Join-Path $PSScriptRoot "..")
$backendPath = Join-Path $repoRoot "backend"

& (Join-Path $backendPath "venv\Scripts\Activate.ps1")
Set-Location $backendPath

Write-Host "[test] ruff check ..." -ForegroundColor Cyan
ruff check app tests

Write-Host "[test] pytest ..." -ForegroundColor Cyan
pytest --cov=app --cov-report=term-missing