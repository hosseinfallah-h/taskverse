# ============================================================
# TaskVerse - Test runner (fails fast)
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

# --- Ruff ---
Write-Host "[test] ruff check ..." -ForegroundColor Cyan
ruff check app tests
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] ruff check failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# --- Pytest ---
Write-Host "[test] pytest ..." -ForegroundColor Cyan
pytest --cov=app --cov-report=term-missing
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] pytest failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] all checks passed" -ForegroundColor Green