#Requires -Version 5.1
param(
  [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports")
)
$ErrorActionPreference = "Stop"
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($machinePath -or $userPath) {
  $env:Path = @($env:Path, $machinePath, $userPath) -join ";" 2>$null
}
$wingetExe = $null
if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetExe = (Get-Command winget).Source } elseif (Test-Path "$env:LocalAppData\Microsoft\WindowsApps\winget.exe") {
  $wingetExe = "$env:LocalAppData\Microsoft\WindowsApps\winget.exe"
}
if (-not $wingetExe) {
  throw "winget not found. Add Windows Package Manager to PATH or run: $env:LocalAppData\Microsoft\WindowsApps\winget.exe (from User shell)."
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format "yyyyMMddTHHmmss"
$json = Join-Path $OutDir "winget-export-$stamp.json"
Write-Host "Exporting winget packages to $json (via $wingetExe)"
& $wingetExe export $json --accept-source-agreements
Write-Host "Done. Review and sanitize before git commit."
