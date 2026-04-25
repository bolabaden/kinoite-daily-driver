#Requires -Version 5.1
param([string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports"))
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if (-not $scoop) { Write-Host "Scoop not on PATH; skip."; exit 0 }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = Join-Path $OutDir "scoop-list-$(Get-Date -Format 'yyyyMMddTHHmmss').txt"
scoop list 2>&1 | Set-Content -Path $out -Encoding utf8
Write-Host "Wrote $out"
