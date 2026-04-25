#Requires -Version 5.1
# Writes CIM OS + optional hardware summary to imports/ (sanitize before commit).
param(
  [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports")
)
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = Join-Path $OutDir "windows-inventory-$(Get-Date -Format 'yyyyMMddTHHmmss').txt"
$lines = @()
$lines += "=== Get-CimInstance Win32_OperatingSystem ==="
$lines += (Get-CimInstance Win32_OperatingSystem | Format-List * | Out-String)
$lines += "=== wsl -l -v ==="
$lines += (wsl -l -v 2>&1 | Out-String)
$lines += "=== podman version ==="
$lines += (podman version 2>&1 | Out-String)
$lines | Set-Content -Path $out -Encoding utf8
Write-Host "Wrote $out"
