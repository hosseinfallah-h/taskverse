# ============================================================
# TaskVerse - Query recent logs (dev tool)
# ============================================================

param(
    [string]$Level = "",
    [int]$User = 0,
    [switch]$Audit,
    [int]$Limit = 20
)

$ErrorActionPreference = "Stop"

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

$repoRoot    = Resolve-Path (Join-Path $PSScriptRoot "..")
$backendPath = Join-Path $repoRoot "backend"

& (Join-Path $backendPath "venv\Scripts\Activate.ps1")
Set-Location $backendPath

$args = @("scripts/check_logs.py", "--limit", $Limit)
if ($Level) { $args += @("--level", $Level) }
if ($User -gt 0) { $args += @("--user", $User) }
if ($Audit) { $args += "--audit" }

python @args