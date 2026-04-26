#Requires -Version 5.1
param([string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports"))
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = Join-Path $OutDir "startapps-sample.txt"
try {
  Get-StartApps | Sort-Object Name | Format-Table -AutoSize | Out-String | Set-Content -Path $out -Encoding utf8
  Write-Host "Wrote $out"
} catch {
  Write-Host "Get-StartApps unavailable: $_"
  exit 0
}
