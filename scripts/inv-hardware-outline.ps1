#Requires -Version 5.1
param([string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "imports"))
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = Join-Path $OutDir "hardware-outline.txt"
@(
  "=== Win32_ComputerSystem ==="
  (Get-CimInstance Win32_ComputerSystem | Format-List * | Out-String)
  "=== Win32_Processor (sample) ==="
  (Get-CimInstance Win32_Processor | Select-Object -First 1 Name, NumberOfCores, MaxClockSpeed | Format-List | Out-String)
  "=== Win32_VideoController ==="
  (Get-CimInstance Win32_VideoController | Format-Table Name, DriverVersion -AutoSize | Out-String)
) | Set-Content -Path $out -Encoding utf8
Write-Host "Wrote $out"
