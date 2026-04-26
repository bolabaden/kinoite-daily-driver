#Requires -Version 5.1
<#
  Runs plan-related Windows + WSL capture in one pass.
  Writes into ../imports/ with a shared timestamp; also writes CAPTURE-MANIFEST-<stamp>.txt

  Bulk outputs (winget, inventory, CSV, etc.) are gitignored per repo .gitignore.
  Includes: registry Uninstall (ARP) CSV, Appx CSV, locale/network metadata (no Wi‑Fi PSK),
  Run keys, optional DISM features + pnputil drivers (may require elevation for useful output).
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

Write-Host "=== [1/16] export-winget.ps1 ==="
& (Join-Path $PSScriptRoot "export-winget.ps1") 2>&1 | Out-String | Write-Host
$wg = Get-ChildItem -Path $outDir -Filter "winget-export-*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($wg) { Add-Manifest $wg.FullName "winget export" }

Write-Host "=== [2/16] run-windows-inventory.ps1 ==="
& (Join-Path $PSScriptRoot "run-windows-inventory.ps1") 2>&1 | Write-Host
$inv = Get-ChildItem -Path $outDir -Filter "windows-inventory-*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($inv) { Add-Manifest $inv.FullName "CIM+WSL+podman" }

$wingetExe = $null
if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetExe = (Get-Command winget).Source }
elseif (Test-Path "$env:LocalAppData\Microsoft\WindowsApps\winget.exe") {
  $wingetExe = "$env:LocalAppData\Microsoft\WindowsApps\winget.exe"
}
if ($wingetExe) {
  Write-Host "=== [3/16] winget list (plan Windows C) ==="
  $listOut = Join-Path $outDir "winget-list-$stamp.txt"
  & $wingetExe list --accept-source-agreements 2>&1 | Set-Content -Path $listOut -Encoding utf8
  Add-Manifest $listOut "winget list"
} else { Write-Warning "winget not found, skip list" }

Write-Host "=== [4/16] list-windows-shortcuts to imports/ ==="
$shortOut = Join-Path $outDir "start-menu-shortcuts-$stamp.txt"
& (Join-Path $PSScriptRoot "list-windows-shortcuts.ps1") -OutFile $shortOut
Add-Manifest $shortOut "Start Menu+Desktop lnk"

Write-Host "=== [5/16] inv-scoop-list ==="
& (Join-Path $PSScriptRoot "inv-scoop-list.ps1") 2>&1 | Write-Host
$sc = Get-ChildItem -Path $outDir -Filter "scoop-list-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($sc) { Add-Manifest $sc.FullName "scoop list" }

Write-Host "=== [6/16] inv-startapps-sample ==="
& (Join-Path $PSScriptRoot "inv-startapps-sample.ps1") 2>&1 | Write-Host
$sa = Get-ChildItem -Path $outDir -Filter "startapps-sample-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($sa) { Add-Manifest $sa.FullName "Get-StartApps" }

Write-Host "=== [7/16] inv-reliability-sample to file ==="
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

Write-Host "=== [8/16] sample event logs to file ==="
$evOut = Join-Path $outDir "application-error-sample-$stamp.txt"
$start = (Get-Date).AddHours(-24)
$ev = Get-WinEvent -FilterHashtable @{ LogName = "Application"; Level = 2, 3; StartTime = $start } -MaxEvents 30 -ErrorAction SilentlyContinue
if ($ev) { $ev | Format-Table TimeCreated, Id, ProviderName, Message -Wrap | Out-String | Set-Content -Path $evOut -Encoding utf8 }
else { "No level 2/3 application events in last 24h (or access denied)" | Set-Content -Path $evOut -Encoding utf8 }
Add-Manifest $evOut "App log errors 24h"

Write-Host "=== [9/16] inv-hardware-outline ==="
& (Join-Path $PSScriptRoot "inv-hardware-outline.ps1") 2>&1 | Write-Host
$hw = Get-ChildItem -Path $outDir -Filter "hardware-outline-*.txt" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($hw) { Add-Manifest $hw.FullName "CIM hardware outline" }

Write-Host "=== [10/16] WSL $KinoiteDistro in-distro check ==="
$wslOut = Join-Path $outDir "wsl-$KinoiteDistro-verify-$stamp.txt"
$wslBody = @()
$wslBody += "=== wsl -d $KinoiteDistro (rpm-ostree, wsl.conf) ==="
$wslBody += (wsl -d $KinoiteDistro -- bash -lc "echo '== whoami =='; whoami; echo '== /etc/wsl.conf =='; cat /etc/wsl.conf 2>&1; echo '== rpm-ostree =='; rpm-ostree status 2>&1" 2>&1)
$wslText = $wslBody -join "`n"
$wslText | Set-Content -Path $wslOut -Encoding utf8
Add-Manifest $wslOut "WSL Kinoite verify"

Write-Host "=== [11/16] Registry Uninstall (ARP) CSV ==="
$regCsv = Join-Path $outDir "registry-uninstall-$stamp.csv"
$uninstallGlobs = @(
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$arpRows = $uninstallGlobs | ForEach-Object {
  Get-ItemProperty -Path $_ -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
} | ForEach-Object {
  $hive = if ($_.PSPath -match 'HKEY_CURRENT_USER') { 'HKCU' } else { 'HKLM' }
  [PSCustomObject]@{
    DisplayName          = $_.DisplayName
    DisplayVersion       = $_.DisplayVersion
    Publisher            = $_.Publisher
    InstallDate          = $_.InstallDate
    InstallLocation      = $_.InstallLocation
    UninstallString      = $_.UninstallString
    QuietUninstallString = $_.QuietUninstallString
    PSChildName          = $_.PSChildName
    Hive                 = $hive
  }
}
$arpRows | Sort-Object DisplayName | Export-Csv -Path $regCsv -NoTypeInformation -Encoding UTF8
Add-Manifest $regCsv "registry uninstall (ARP)"

Write-Host "=== [12/16] Appx packages CSV (current user) ==="
$appxCsv = Join-Path $outDir "appx-packages-$stamp.csv"
try {
  Get-AppxPackage | Select-Object Name, Version, Publisher, PackageFullName |
    Sort-Object Name |
    Export-Csv -Path $appxCsv -NoTypeInformation -Encoding UTF8
} catch {
  "Get-AppxPackage failed: $($_.Exception.Message)" | Set-Content -Path $appxCsv -Encoding utf8
}
Add-Manifest $appxCsv "Appx packages"

Write-Host "=== [13/16] Locale + network metadata (no Wi‑Fi PSK) ==="
$locOut = Join-Path $outDir "host-locale-network-$stamp.txt"
$locLines = New-Object System.Collections.Generic.List[string]
[void]$locLines.Add("=== Get-Culture ===")
[void]$locLines.Add((Get-Culture | Format-List * | Out-String))
[void]$locLines.Add("=== Get-TimeZone ===")
[void]$locLines.Add((Get-TimeZone | Format-List * | Out-String))
[void]$locLines.Add("=== Get-WinSystemLocale ===")
[void]$locLines.Add((Get-WinSystemLocale | Format-List * | Out-String))
try {
  [void]$locLines.Add("=== Get-WinUserLanguageList (tags) ===")
  $tags = (Get-WinUserLanguageList | ForEach-Object { $_.LanguageTag }) -join ", "
  [void]$locLines.Add($tags)
} catch {
  [void]$locLines.Add("(Get-WinUserLanguageList: $($_.Exception.Message))")
}
try {
  [void]$locLines.Add("=== Get-NetConnectionProfile (no credentials) ===")
  [void]$locLines.Add((Get-NetConnectionProfile | Format-Table Name, InterfaceAlias, IPv4Connectivity, NetworkCategory -AutoSize | Out-String))
} catch {
  [void]$locLines.Add("(Get-NetConnectionProfile: $($_.Exception.Message))")
}
try {
  [void]$locLines.Add("=== netsh wlan show profiles (SSID names only; keys not exported) ===")
  [void]$locLines.Add((cmd /c "netsh wlan show profiles" 2>&1 | Out-String))
} catch {
  [void]$locLines.Add("(netsh wlan: $($_.Exception.Message))")
}
($locLines -join "`n") | Set-Content -Path $locOut -Encoding utf8
Add-Manifest $locOut "locale + network metadata"

Write-Host "=== [14/16] Run keys (HKCU + HKLM) ==="
$runOut = Join-Path $outDir "run-keys-$stamp.txt"
$rk = New-Object System.Collections.Generic.List[string]
foreach ($pair in @(
    @{ Hive = 'HKCU'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' },
    @{ Hive = 'HKLM'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' }
  )) {
  [void]$rk.Add("=== $($pair.Path) ===")
  try {
    $item = Get-Item -LiteralPath $pair.Path -ErrorAction Stop
    foreach ($name in $item.Property) {
      if ($name -eq '(default)') { continue }
      $v = (Get-ItemProperty -LiteralPath $pair.Path -Name $name).$name
      [void]$rk.Add("${name}=$v")
    }
  } catch {
    [void]$rk.Add("($($_.Exception.Message))")
  }
}
($rk -join "`n") | Set-Content -Path $runOut -Encoding utf8
Add-Manifest $runOut "Run keys"

Write-Host "=== [15/16] DISM + pnputil (optional; elevation helps) ==="
$dismOut = Join-Path $outDir "dism-features-$stamp.txt"
try {
  & dism.exe /Online /Get-Features /Format:Table 2>&1 | Set-Content -Path $dismOut -Encoding utf8
} catch {
  "DISM error: $($_.Exception.Message)" | Set-Content -Path $dismOut -Encoding utf8
}
if (-not (Test-Path -LiteralPath $dismOut)) { "" | Set-Content -Path $dismOut -Encoding utf8 }
Add-Manifest $dismOut "DISM features"

$pnpOut = Join-Path $outDir "pnputil-drivers-$stamp.txt"
try {
  & pnputil.exe /enum-drivers 2>&1 | Set-Content -Path $pnpOut -Encoding utf8
} catch {
  "pnputil error: $($_.Exception.Message)" | Set-Content -Path $pnpOut -Encoding utf8
}
if (-not (Test-Path -LiteralPath $pnpOut)) { "" | Set-Content -Path $pnpOut -Encoding utf8 }
Add-Manifest $pnpOut "pnputil drivers"

# Host tools
Write-Host "=== [16/16] Host tools hint ==="
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
Plan capture (Kinoite WSL + Win11 inventory). All paths relative to this repo: imports/
Run: $(Join-Path (Split-Path -Parent $PSCommandPath) 'run-full-plan-capture.ps1') from PowerShell 5+ with full PATH merge.
New in this run: registry-uninstall-*.csv, appx-packages-*.csv, host-locale-network-*.txt, run-keys-*.txt, dism-features-*.txt, pnputil-drivers-*.txt
"@
# wsl -l -v writes UTF-16; pipe/capture mojibakes in UTF-8 manifest without byte decode
$wslLvQuick = ""
$tmpWsl = [System.IO.Path]::GetTempFileName()
try {
  cmd /c "wsl -l -v >`"$tmpWsl`" 2>&1" | Out-Null
  if (Test-Path -LiteralPath $tmpWsl) {
    [byte[]]$wslBytes = [System.IO.File]::ReadAllBytes($tmpWsl)
    if ($wslBytes.Length -ge 2 -and $wslBytes[0] -eq 0xFF -and $wslBytes[1] -eq 0xFE) { $wslBytes = $wslBytes[2..($wslBytes.Length - 1)] }
    if ($wslBytes.Length) { $wslLvQuick = [System.Text.Encoding]::Unicode.GetString($wslBytes) } else { $wslLvQuick = "(no output)" }
  }
} catch { $wslLvQuick = "wsl -l -v: $($_.Exception.Message)" } finally { Remove-Item -LiteralPath $tmpWsl -ErrorAction SilentlyContinue }
$manBody = @($hdr, "" , ($manifest -join "`n"), "", "=== wsl -l -v (quick) ===", $wslLvQuick) -join "`n"
[System.IO.File]::WriteAllText($manPath, $manBody, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $manPath"
Get-Content -Path $manPath
Write-Host "=== Done. Newest files use stamp $stamp ==="
