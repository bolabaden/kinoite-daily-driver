#Requires -Version 5.1
# Writes CIM OS + optional hardware summary to imports/ (sanitize before commit).
# Works when launched from a minimal `PATH` (e.g. Windows PowerShell 1.0) — soft-fail optional tools.
param(
  [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports")
)
$ErrorActionPreference = "Stop"
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($machinePath -or $userPath) {
  $env:Path = @($env:Path, $machinePath, $userPath) -join ";" 2>$null
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = Join-Path $OutDir "windows-inventory-$(Get-Date -Format 'yyyyMMddTHHmmss').txt"
$lines = @()
$lines += "=== Get-CimInstance Win32_OperatingSystem ==="
$lines += (Get-CimInstance Win32_OperatingSystem | Format-List * | Out-String)
$lines += "=== wsl -l -v ==="
$lines += (wsl -l -v 2>&1 | Out-String)
$lines += "=== wsl --version (optional) ==="
$lines += (wsl --version 2>&1 | Out-String)
$lines += "=== podman version ==="
if (Get-Command podman -ErrorAction SilentlyContinue) {
  $op = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $lines += ([string](& podman version 2>&1))
  $ErrorActionPreference = $op
} else {
  $lines += "(podman not on PATH in this session; Machine+User PATH is merged in this script.)"
}
$lines | Set-Content -Path $out -Encoding utf8
Write-Host "Wrote $out"
