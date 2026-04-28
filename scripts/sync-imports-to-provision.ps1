#Requires -Version 5.1
param(
  [string] $RepoRoot = $(if ($env:KINOITE_WORKSPACE_ROOT) { $env:KINOITE_WORKSPACE_ROOT.TrimEnd('\', '/') } else { "" }),
  [switch] $Strict
)
$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = (Split-Path -Parent $PSScriptRoot) }
$py = Join-Path $RepoRoot "scripts\sync_imports_to_provision.py"
if (-not (Test-Path -LiteralPath $py)) { Write-Error "Missing $py"; exit 2 }
$exe = Get-Command python -ErrorAction SilentlyContinue
if (-not $exe) { $exe = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $exe) { Write-Error "python/python3 required"; exit 2 }
$args = @("--repo", $RepoRoot)
if ($Strict) { $args += "--strict" }
& $exe.Source $py @args
exit $LASTEXITCODE
