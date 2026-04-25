#Requires -Version 5.1
<#
  Runs every plan-related capture in one go (see silverblue_wsl_workspace_ec9c3c8b.plan.md + WORKSPACE_STATUS).
  Writes into ../imports/ with a shared timestamp; also writes CAPTURE-MANIFEST-<stamp>.txt
#>
param(
  [string]$KinoiteDistro = "Kinoite-WS2"
)
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "imports"
$stamp = Get-Date -Format "yyyyMMddTHHmmss"
$manifest = [System.Collections.Generic.List[string]]::new()

$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($machinePath -or $userPath) {
  $env:Path = @($env:Path, $machinePath, $userPath) -join ";"
}
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Add-Manifest {
  param([string]$Path, [string]$Label)
  if (Test-Path -LiteralPath $Path) {
    $i = Get-Item -LiteralPath $Path
    [void]$manifest.Add(("OK  {0,-50} {1,12} {2}" -f $Label, $i.Length, $i.Name))
  } else {
    [void]$manifest.Add("MISS $Label")
  }
}

Write-Host "=== [1/10] export-winget.ps1 ===" 
& (Join-Path $PSScriptRoot "export-winget.ps1") 2>&1 | Out-String | Write-Host
$wg = Get-ChildItem -Path $outDir -Filter "winget-export-*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($wg) { Add-Manifest $wg.FullName "winget export" }

Write-Host "=== [2/10] run-windows-inventory.ps1 ===" 
& (Join-Path $PSScriptRoot "run-windows-inventory.ps1") 2>&1 | Write-Host
$inv = Get-ChildItem -Path $outDir -Filter "windows-inventory-*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($inv) { Add-Manifest $inv.FullName "CIM+WSL+podman" }

$wingetExe = $null
if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetExe = (Get-Command winget).Source }
elseif (Test-Path "$env:LocalAppData\Microsoft\WindowsApps\winget.exe") {
  $wingetExe = "$env:LocalAppData\Microsoft\WindowsApps\winget.exe"
}
if ($wingetExe) {
  Write-Host "=== [3/10] winget list (plan Windows C) ===" 
  $listOut = Join-Path $outDir "winget-list-$stamp.txt"
  & $wingetExe list --accept-source-agreements 2>&1 | Set-Content -Path $listOut -Encoding utf8
  Add-Manifest $listOut "winget list"
} else { Write-Warning "winget not found, skip list" }

Write-Host "=== [4/10] list-windows-shortcuts to imports/ ===" 
$shortOut = Join-Path $outDir "start-menu-shortcuts-$stamp.txt"
& (Join-Path $PSScriptRoot "list-windows-shortcuts.ps1") -OutFile $shortOut
Add-Manifest $shortOut "Start Menu+Desktop lnk"

Write-Host "=== [5/10] inv-scoop-list ===" 
& (Join-Path $PSScriptRoot "inv-scoop-list.ps1") 2>&1 | Write-Host
$sc = Get-ChildItem -Path $outDir -Filter "scoop-list-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($sc) { Add-Manifest $sc.FullName "scoop list" }

Write-Host "=== [6/10] inv-startapps-sample ===" 
& (Join-Path $PSScriptRoot "inv-startapps-sample.ps1") 2>&1 | Write-Host
$sa = Get-ChildItem -Path $outDir -Filter "startapps-sample-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($sa) { Add-Manifest $sa.FullName "Get-StartApps" }

Write-Host "=== [7/10] inv-reliability-sample to file ===" 
$relOut = Join-Path $outDir "reliability-events-sample-$stamp.txt"
$relText = $null
try {
  $ev = Get-WinEvent -LogName "Microsoft-Windows-Diagnostics-Performance/Operational" -MaxEvents 8 -ErrorAction Stop
  if ($ev) { $relText = $ev | Format-List TimeCreated, Id, Message | Out-String } else { $relText = "(no events returned)" }
} catch {
  $relText = "(reliability log: $($_.Exception.Message))"
}
$relText | Set-Content -Path $relOut -Encoding utf8
Add-Manifest $relOut "reliability perf (sample)"

Write-Host "=== [8/10] sample event logs to file ===" 
$evOut = Join-Path $outDir "application-error-sample-$stamp.txt"
$start = (Get-Date).AddHours(-24)
$ev = Get-WinEvent -FilterHashtable @{ LogName = "Application"; Level = 2, 3; StartTime = $start } -MaxEvents 30 -ErrorAction SilentlyContinue
if ($ev) { $ev | Format-Table TimeCreated, Id, ProviderName, Message -Wrap | Out-String | Set-Content -Path $evOut -Encoding utf8 }
else { "No level 2/3 application events in last 24h (or access denied)" | Set-Content -Path $evOut -Encoding utf8 }
Add-Manifest $evOut "App log errors 24h"

Write-Host "=== [9/10] inv-hardware-outline ===" 
& (Join-Path $PSScriptRoot "inv-hardware-outline.ps1") 2>&1 | Write-Host
$hw = Get-ChildItem -Path $outDir -Filter "hardware-outline-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($hw) { Add-Manifest $hw.FullName "CIM hardware outline" }

Write-Host "=== [10/10] WSL $KinoiteDistro in-distro check ===" 
$wslOut = Join-Path $outDir "wsl-$KinoiteDistro-verify-$stamp.txt"
$wslBody = @()
$wslBody += "=== wsl -d $KinoiteDistro (rpm-ostree, wsl.conf) ==="
$wslBody += (wsl -d $KinoiteDistro -- bash -lc "echo '== whoami =='; whoami; echo '== /etc/wsl.conf =='; cat /etc/wsl.conf 2>&1; echo '== rpm-ostree =='; rpm-ostree status 2>&1" 2>&1)
$wslText = $wslBody -join "`n"
$wslText | Set-Content -Path $wslOut -Encoding utf8
Add-Manifest $wslOut "WSL Kinoite verify"

# Host tools
$vbox = Get-Command VBoxManage -ErrorAction SilentlyContinue
$toolsOut = Join-Path $outDir "host-tools-$stamp.txt"
$tools = @"
=== run-full-plan-capture $stamp ===
Date: $(Get-Date -Format o)
VirtualBox: $(if ($vbox) { 'VBoxManage: ' + $vbox.Source } else { 'VBoxManage: not on PATH' })
"@
$tools | Set-Content -Path $toolsOut -Encoding utf8
Add-Manifest $toolsOut "host tools hint"

# Manifest
$manPath = Join-Path $outDir "CAPTURE-MANIFEST-$stamp.txt"
$hdr = @"
Plan capture (silverblue WSL + Win11 inventory). All paths relative to this repo: imports/
Run: $(Join-Path (Split-Path -Parent $PSCommandPath) 'run-full-plan-capture.ps1') from PowerShell 5+ with full PATH merge.
"@
$manBody = @($hdr, "" , ($manifest -join "`n"), "", "=== wsl -l -v (quick) ===", (wsl -l -v 2>&1 | Out-String)) -join "`n"
[System.IO.File]::WriteAllText($manPath, $manBody, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $manPath"
Get-Content -Path $manPath
Write-Host "=== Done. Newest files use stamp $stamp ===" 
