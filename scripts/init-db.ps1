# ============================================================
# TaskVerse - Initialize local PostgreSQL database
# Requires: PostgreSQL 14+ running locally
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

python scripts/init_db.py