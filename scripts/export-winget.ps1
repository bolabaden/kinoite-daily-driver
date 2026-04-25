#Requires -Version 5.1
param(
  [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports")
)
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format "yyyyMMddTHHmmss"
$json = Join-Path $OutDir "winget-export-$stamp.json"
Write-Host "Exporting winget packages to $json"
winget export $json --accept-source-agreements
Write-Host "Done. Review and sanitize before git commit."
