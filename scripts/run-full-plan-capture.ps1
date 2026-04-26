#Requires -Version 5.1
<#
.SYNOPSIS
  One-shot Windows + WSL inventory for this repo: writes stable paths under ../imports/ and CAPTURE-MANIFEST.txt.
.DESCRIPTION
  Runs export-winget, CIM+WSL inventory, winget list, shortcuts, Scoop, StartApps, events, ARP+Appx CSV, locale/net,
  Run keys, optional DISM/pnputil, in-distro WSL verify, host-tools hint, and an embedded wsl -l -v table
  (captured via Start-Process to %WINDIR%\System32\wsl.exe, UTF-8). Bulk follows root .gitignore. Keep script source ASCII.

.PARAMETER KinoiteDistro
  WSL distro name for the in-distro check (default Kinoite-WS2) and the output file wsl-<name>-verify.txt
.PARAMETER SkipWinget
  Do not run export-winget or winget list. Faster; prior winget-export.json and winget-list.txt unchanged;
  manifest will note SkipWinget and a single SKP line for that pair.
.EXAMPLE
  PS> ./run-full-plan-capture.ps1
  Full run; overwrites all stable imports/* names and the manifest.
.EXAMPLE
  PS> ./run-full-plan-capture.ps1 -SkipWinget
  Skip the two winget steps only; refresh the rest and update the manifest.
#>
param(
  [string]$KinoiteDistro = "Kinoite-WS2",
  [switch]$SkipWinget
)
$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "imports"
# Denominator for "=== [n/...] ===" log lines; bump when adding a real capture step.
$TotalCaptureSteps = 16
$runStamp = Get-Date -Format "yyyyMMddTHHmmss"
$runIso = Get-Date -Format "o"
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

if (-not $SkipWinget) {
  Write-Host "=== [1/$TotalCaptureSteps] export-winget.ps1 ==="
  & (Join-Path $PSScriptRoot "export-winget.ps1") 2>&1 | Out-String | Write-Host
  $wgPath = Join-Path $outDir "winget-export.json"
  if (Test-Path -LiteralPath $wgPath) { Add-Manifest $wgPath "winget export" }
} else {
  Write-Host "=== [1/$TotalCaptureSteps] export-winget.ps1 (SKIPPED: -SkipWinget) ==="
  [void]$manifest.Add("SKP  winget export + list (re-run without -SkipWinget to refresh JSON/txt on disk)")
}

Write-Host "=== [2/$TotalCaptureSteps] run-windows-inventory.ps1 ==="
& (Join-Path $PSScriptRoot "run-windows-inventory.ps1") 2>&1 | Write-Host
$invPath = Join-Path $outDir "windows-inventory.txt"
if (Test-Path -LiteralPath $invPath) { Add-Manifest $invPath "CIM+WSL+podman" }

$wingetExe = $null
if (-not $SkipWinget) {
  if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetExe = (Get-Command winget).Source }
  elseif (Test-Path "$env:LocalAppData\Microsoft\WindowsApps\winget.exe") {
    $wingetExe = "$env:LocalAppData\Microsoft\WindowsApps\winget.exe"
  }
  if ($wingetExe) {
    Write-Host "=== [3/$TotalCaptureSteps] winget list (plan Windows C) ==="
    $listOut = Join-Path $outDir "winget-list.txt"
    & $wingetExe list --accept-source-agreements 2>&1 | Set-Content -Path $listOut -Encoding utf8
    Add-Manifest $listOut "winget list"
  } else { Write-Warning "winget not found, skip list" }
} else { Write-Host "=== [3/$TotalCaptureSteps] winget list (SKIPPED: -SkipWinget) ===" }

Write-Host "=== [4/$TotalCaptureSteps] list-windows-shortcuts to imports/ ==="
$shortOut = Join-Path $outDir "start-menu-shortcuts.txt"
& (Join-Path $PSScriptRoot "list-windows-shortcuts.ps1") -OutFile $shortOut
Add-Manifest $shortOut "Start Menu+Desktop lnk"

Write-Host "=== [5/$TotalCaptureSteps] inv-scoop-list ==="
& (Join-Path $PSScriptRoot "inv-scoop-list.ps1") 2>&1 | Write-Host
$scPath = Join-Path $outDir "scoop-list.txt"
if (Test-Path -LiteralPath $scPath) { Add-Manifest $scPath "scoop list" }

Write-Host "=== [6/$TotalCaptureSteps] inv-startapps-sample ==="
& (Join-Path $PSScriptRoot "inv-startapps-sample.ps1") 2>&1 | Write-Host
$saPath = Join-Path $outDir "startapps-sample.txt"
if (Test-Path -LiteralPath $saPath) { Add-Manifest $saPath "Get-StartApps" }

Write-Host "=== [7/$TotalCaptureSteps] inv-reliability-sample to file ==="
$relOut = Join-Path $outDir "reliability-events-sample.txt"
$relText = $null
try {
  $ev = Get-WinEvent -LogName "Microsoft-Windows-Diagnostics-Performance/Operational" -MaxEvents 8 -ErrorAction Stop
  if ($ev) { $relText = $ev | Format-List TimeCreated, Id, Message | Out-String } else { $relText = "(no events returned)" }
} catch {
  $relText = "(reliability log: $($_.Exception.Message))"
}
$relText | Set-Content -Path $relOut -Encoding utf8
Add-Manifest $relOut "reliability perf (sample)"

Write-Host "=== [8/$TotalCaptureSteps] sample event logs to file ==="
$evOut = Join-Path $outDir "application-error-sample.txt"
$start = (Get-Date).AddHours(-24)
$ev = Get-WinEvent -FilterHashtable @{ LogName = "Application"; Level = 2, 3; StartTime = $start } -MaxEvents 30 -ErrorAction SilentlyContinue
if ($ev) { $ev | Format-Table TimeCreated, Id, ProviderName, Message -Wrap | Out-String | Set-Content -Path $evOut -Encoding utf8 }
else { "No level 2/3 application events in last 24h (or access denied)" | Set-Content -Path $evOut -Encoding utf8 }
Add-Manifest $evOut "App log errors 24h"

Write-Host "=== [9/$TotalCaptureSteps] inv-hardware-outline ==="
& (Join-Path $PSScriptRoot "inv-hardware-outline.ps1") 2>&1 | Write-Host
$hwPath = Join-Path $outDir "hardware-outline.txt"
if (Test-Path -LiteralPath $hwPath) { Add-Manifest $hwPath "CIM hardware outline" }

Write-Host "=== [10/$TotalCaptureSteps] WSL $KinoiteDistro in-distro check ==="
$wslOut = Join-Path $outDir "wsl-$KinoiteDistro-verify.txt"
$wslBody = @()
$wslBody += "=== wsl -d $KinoiteDistro (rpm-ostree, wsl.conf) ==="
$wslBody += (wsl -d $KinoiteDistro -- bash -lc "echo '== whoami =='; whoami; echo '== /etc/wsl.conf =='; cat /etc/wsl.conf 2>&1; echo '== rpm-ostree =='; rpm-ostree status 2>&1" 2>&1)
$wslText = $wslBody -join "`n"
$wslText | Set-Content -Path $wslOut -Encoding utf8
Add-Manifest $wslOut "WSL Kinoite verify"

Write-Host "=== [11/$TotalCaptureSteps] Registry Uninstall (ARP) CSV ==="
$regCsv = Join-Path $outDir "registry-uninstall.csv"
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

Write-Host "=== [12/$TotalCaptureSteps] Appx packages CSV (current user) ==="
$appxCsv = Join-Path $outDir "appx-packages.csv"
try {
  Get-AppxPackage | Select-Object Name, Version, Publisher, PackageFullName |
    Sort-Object Name |
    Export-Csv -Path $appxCsv -NoTypeInformation -Encoding UTF8
} catch {
  "Get-AppxPackage failed: $($_.Exception.Message)" | Set-Content -Path $appxCsv -Encoding utf8
}
Add-Manifest $appxCsv "Appx packages"

Write-Host "=== [13/$TotalCaptureSteps] Locale + network metadata (no Wi-Fi PSK) ==="
$locOut = Join-Path $outDir "host-locale-network.txt"
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

Write-Host "=== [14/$TotalCaptureSteps] Run keys (HKCU + HKLM) ==="
$runOut = Join-Path $outDir "run-keys.txt"
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

Write-Host "=== [15/$TotalCaptureSteps] DISM + pnputil (optional; elevation helps) ==="
$dismOut = Join-Path $outDir "dism-features.txt"
try {
  & dism.exe /Online /Get-Features /Format:Table 2>&1 | Set-Content -Path $dismOut -Encoding utf8
} catch {
  "DISM error: $($_.Exception.Message)" | Set-Content -Path $dismOut -Encoding utf8
}
if (-not (Test-Path -LiteralPath $dismOut)) { "" | Set-Content -Path $dismOut -Encoding utf8 }
Add-Manifest $dismOut "DISM features"

$pnpOut = Join-Path $outDir "pnputil-drivers.txt"
try {
  & pnputil.exe /enum-drivers 2>&1 | Set-Content -Path $pnpOut -Encoding utf8
} catch {
  "pnputil error: $($_.Exception.Message)" | Set-Content -Path $pnpOut -Encoding utf8
}
if (-not (Test-Path -LiteralPath $pnpOut)) { "" | Set-Content -Path $pnpOut -Encoding utf8 }
Add-Manifest $pnpOut "pnputil drivers"

# Host tools
Write-Host "=== [16/$TotalCaptureSteps] Host tools hint ==="
$vbox = Get-Command VBoxManage -ErrorAction SilentlyContinue
$toolsOut = Join-Path $outDir "host-tools.txt"
$tools = @"
=== run-full-plan-capture (runId $runStamp) ===
Date: $runIso
VirtualBox: $(if ($vbox) { 'VBoxManage: ' + $vbox.Source } else { 'VBoxManage: not on PATH' })
"@
$tools | Set-Content -Path $toolsOut -Encoding utf8
Add-Manifest $toolsOut "host tools hint"

# Manifest
$manPath = Join-Path $outDir "CAPTURE-MANIFEST.txt"
$optSkip = if ($SkipWinget) { " SkipWinget: winget export + list were not run; existing winget files on disk unchanged. " } else { "" }
$hdr = @"
Plan capture (Kinoite WSL + Win11 inventory). All paths relative to this repo: imports/ (stable filenames, no -yyyyMMddTHHmmss- suffix; merge history: scripts/merge-timestamped-imports.ps1).
Run: $(Join-Path (Split-Path -Parent $PSCommandPath) 'run-full-plan-capture.ps1') from PowerShell 5+ with full PATH merge.
This run: runStamp=$runStamp$optSkip
Outputs: registry-uninstall.csv, appx-packages.csv, host-locale-network.txt, run-keys.txt, dism-features.txt, pnputil-drivers.txt, winget-export.json, and the rest in imports/.
"@
# wsl -l -v: Start-Process to System32\wsl.exe (not cmd) avoids PATH/alias; redirect matches UTF-16LE table output.
# cmd.exe often lacks `wsl` on PATH. Decode: BOM UTF-16/UTF-8, UTF-16LE ASCII (null after code units), else UTF-8.
$wslLvQuick = ""
$tmpWsl = [System.IO.Path]::GetTempFileName()
$wsl32 = Join-Path $env:WINDIR "System32\wsl.exe"
try {
  if (-not (Test-Path -LiteralPath $wsl32)) { $wslLvQuick = "(wsl.exe not found in $wsl32)" }
  else {
    $p = Start-Process -FilePath $wsl32 -ArgumentList @("-l", "-v") -NoNewWindow -Wait -PassThru -RedirectStandardOutput $tmpWsl
    if (Test-Path -LiteralPath $tmpWsl) {
      [byte[]]$b = [System.IO.File]::ReadAllBytes($tmpWsl)
      if ($b.Length -eq 0) { $wslLvQuick = "(no output; exit=$($p.ExitCode))" }
      elseif ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) {
        $wslLvQuick = [System.Text.Encoding]::Unicode.GetString($b, 2, $b.Length - 2)
      } elseif ($b.Length -ge 2 -and $b[0] -eq 0xFE -and $b[1] -eq 0xFF) {
        $wslLvQuick = [System.Text.Encoding]::BigEndianUnicode.GetString($b, 2, $b.Length - 2)
      } elseif ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) {
        $wslLvQuick = [System.Text.Encoding]::UTF8.GetString($b, 3, $b.Length - 3)
      } elseif ($b.Length -ge 4 -and $b[1] -eq 0 -and $b[3] -eq 0 -and ($b[0] -le 0x7F) -and ($b[2] -le 0x7F)) {
        $wslLvQuick = [System.Text.Encoding]::Unicode.GetString($b)
      } else { $wslLvQuick = [System.Text.Encoding]::UTF8.GetString($b) }
    } else { $wslLvQuick = "(no temp output; exit=$($p.ExitCode))" }
  }
} catch { $wslLvQuick = "wsl -l -v: $($_.Exception.Message)" } finally { Remove-Item -LiteralPath $tmpWsl -ErrorAction SilentlyContinue }
$manBody = @($hdr, "" , ($manifest -join "`n"), "", "=== wsl -l -v (quick) ===", $wslLvQuick) -join "`n"
[System.IO.File]::WriteAllText($manPath, $manBody, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $manPath"
Get-Content -Path $manPath
$doneSfx = if ($SkipWinget) { " (winget steps skipped; use run without -SkipWinget to refresh export/list)" } else { "" }
Write-Host "=== Done. Run $runStamp - outputs use stable names under $outDir (see $manPath)$doneSfx ==="
