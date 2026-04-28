#Requires -Version 5.1
<#
  All-in-one Kinoite orchestrator (this repo's only script intended to *dispatch* to other
  entrypoints). Use `.\<script>.ps1` directly for a single job; use this to browse or chain steps.

  Windows PowerShell 5.1+ only. WSL steps use wsl.exe (separate process).

  Env: KINOITE_AIO_RUN=Comma,Separated,Steps  (same names as -Run)
#>
[CmdletBinding()]
param(
  [string] $Run = $(if ($env:KINOITE_AIO_RUN) { $env:KINOITE_AIO_RUN } else { "" }),
  [string] $Distro = $(if ($env:KINOITE_DISTRO) { $env:KINOITE_DISTRO } else { "Kinoite-WS2" }),
  [string] $RepoRoot = $(if ($env:KINOITE_WORKSPACE_ROOT) { $env:KINOITE_WORKSPACE_ROOT.TrimEnd('\', '/') } else { "" })
)

$ErrorActionPreference = "Stop"
$Here = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = (Split-Path -Parent $Here) }
function Get-WslPath {
  param([string]$Win)
  $p = $Win.TrimEnd('\')
  if ($p -notmatch '^([A-Za-z]):\\') { return $Win }
  $d = $Matches[1].ToLower()
  $r = $p.Substring(3) -replace '\\', '/'
  "/mnt/$d/$r"
}
$WslRoot = Get-WslPath -Win $RepoRoot
function Get-StepList {
  @(
    @{ Id = "Import"       ; T = "Windows: import rootfs (podman to tar, optional wsl --import)"; Admin = $false }
    @{ Id = "WslConfig"    ; T = "Windows: install %UserProfile%\.wslconfig from config/wsl2/README template"; Admin = $false }
    @{ Id = "ShowGui"      ; T = "Windows: start Plasma in WSL (Show-Kinoite-Gui -Action Launch)"; Admin = $false }
    @{ Id = "FocusGui"     ; T = "Windows: focus WSLg (Show-Kinoite-Gui -Action Focus)"; Admin = $false }
    @{ Id = "LogonReg"     ; T = "Windows: register logon task (Kinoite-WindowsPlasmaLogon -Register, admin)"; Admin = $true }
    @{ Id = "LogonRun"     ; T = "Windows: run one-shot logon action (Kinoite-WindowsPlasmaLogon -RunSession)"; Admin = $false }
    @{ Id = "WikiMenu"     ; T = "Windows: wiki menu (Kinoite-Wiki.ps1: Init, GenerateDocs, Sync)"; Admin = $false }
    @{ Id = "WikiSync"     ; T = "Windows: wiki _docs + robocopy + commit (Kinoite-Wiki -Action Sync)"; Admin = $false }
    @{ Id = "Inv"          ; T = "Windows: host inventory (winget, CIM, start menu, DISM, ...)"; Admin = $false }
    @{ Id = "MdLinks"      ; T = "Windows: verify markdown links (check-md-links.ps1)"; Admin = $false }
    @{ Id = "Safe"         ; T = "Windows: bundle: MdLinks, WikiGen, full inventory (DISM may UAC)"; Admin = $false }
    @{ Id = "MapImports"   ; T = "Generate host-local flatpak lists from imports/ + native-first mapping (Python)"; Admin = $false }
    @{ Id = "Bootstrap"    ; T = "WSL: bootstrap: Flathub, optional WSLg profile, inside distro"; Admin = $false }
    @{ Id = "Apply"        ; T = "WSL: apply-atomic-provision (sudo) inside distro"; Admin = $false }
    @{ Id = "MigrateAppConfigs" ; T = "WSL: migrate-app-config.sh (qBit/Firefox/Thunderbird/VS Code/Syncthing from Windows paths)"; Admin = $false }
  )
}
function Test-IsAdmin { ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator) }

function Invoke-Step {
  param([string]$Name)
  $env:KINOITE_WORKSPACE_ROOT = $RepoRoot
  $env:KINOITE_DISTRO = $Distro
  $imp = Join-Path $Here "import-kinoite-rootfs-to-wsl.ps1"
  $sh  = Join-Path $Here "wsl2\Show-Kinoite-Gui.ps1"
  $log = Join-Path $Here "wsl2\Kinoite-WindowsPlasmaLogon.ps1"
  $wki = Join-Path $Here "Kinoite-Wiki.ps1"
  $wiv = Join-Path $Here "windows-inventory.ps1"
  $md  = Join-Path $Here "check-md-links.ps1"
  $wslHostCfg = Join-Path $Here "wsl2\Install-WslHostConfig.ps1"
  Write-Host "=== AIO: $Name ===" -ForegroundColor Cyan
  switch ($Name) {
  "Import"   { & $imp; break }
  "WslConfig" { & $wslHostCfg -RepoRoot $RepoRoot; break }
  "ShowGui"  { & $sh -Distro $Distro -Action Launch; break }
  "FocusGui" { & $sh -Distro $Distro -Action Focus; break }
  "LogonReg" { if (-not (Test-IsAdmin)) { Write-Error "Run elevated for LogonReg."; break }; & $log -Register -Distro $Distro -WorkspaceRoot $RepoRoot; break }
  "LogonRun" { & $log -RunSession -Distro $Distro -WorkspaceRoot $RepoRoot; break }
  "WikiMenu" { & $wki; break }
  "WikiSync" { & $wki -Action Sync; break }
  "WikiInit" { & $wki -Action Init; break }
  "WikiGen"  { & $wki -Action GenerateDocs; break }
  "Inv"      { & $wiv; break }
  "MdLinks"  { & $md; break }
  "Bootstrap" {
    $c = "set -e; cd '" + $WslRoot + "' && bash ./scripts/bootstrap-kinoite-wsl2.sh run"
    wsl.exe -d $Distro -e bash -lc $c
    break
  }
  "Apply" {
    Write-Warning "Apply: sudo in WSL; you may be prompted for your Linux password."
    $c = "set -e; cd '" + $WslRoot + "' && sudo ./scripts/apply-atomic-provision.sh"
    wsl.exe -d $Distro -e bash -lc $c
    break
  }
  "Safe" {
    Write-Host "Safe bundle: MdLinks, WikiGen, Inv (all inventory; DISM may UAC)"
    & $md
    & $wki -Action GenerateDocs
    $env:KINOITE_INVENTORY_MODE = "all"
    & $wiv
    $env:KINOITE_INVENTORY_MODE = $null
    break
  }
  "MapImports" {
    $sync = Join-Path $Here "sync-imports-to-provision.ps1"
    & $sync -RepoRoot $RepoRoot
    break
  }
  "MigrateAppConfigs" {
    Write-Host "MigrateAppConfigs: chmod + migrate-app-config.sh inside distro $Distro"
    $c = "set -e; cd '" + $WslRoot + "' && chmod +x scripts/migrate-app-config.sh 2>/dev/null; bash ./scripts/migrate-app-config.sh run"
    wsl.exe -d $Distro -e bash -lc $c
    break
  }
  default { Write-Error "Unknown step: $Name" }
  }
}
function Show-Banner {
  @'

  Kinoite AIO - one menu for Windows-side automation and WSL dispatch.
  Per-step scripts are unchanged; this file only calls them in order.
  See scripts/COVERAGE.md
'@ | Write-Host
}

$steps = @((Get-StepList))
$map = @{
  import = "Import" ; rootfs = "Import"
  wslconfig = "WslConfig" ; wslhost = "WslConfig" ; hostwsl = "WslConfig" ; dotwslconfig = "WslConfig"
  showgui = "ShowGui" ; launch = "ShowGui" ; plasma = "ShowGui" ; gui = "ShowGui"
  focus = "FocusGui" ; focusgui = "FocusGui"
  logonreg = "LogonReg" ; logonregister = "LogonReg" ; plasmalogon = "LogonReg"
  logonrun = "LogonRun"
  wikimenu = "WikiMenu" ; wiki = "WikiMenu"
  wikisync = "WikiSync" ; sync = "WikiSync"
  wikiinit = "WikiInit" ; initiwiki = "WikiInit"
  wikigen  = "WikiGen"  ; gendocs = "WikiGen" ; generatedocs = "WikiGen"
  inv = "Inv" ; inventory = "Inv" ; host = "Inv"
  safe = "Safe" ; devcheck = "Safe"
  md = "MdLinks" ; links = "MdLinks" ; mdlinks = "MdLinks"
  bootstrap = "Bootstrap" ; boot = "Bootstrap"
  apply = "Apply" ; provision = "Apply"
  mapimports = "MapImports" ; syncprovision = "MapImports"
  migrateappconfigs = "MigrateAppConfigs" ; migrateconfigs = "MigrateAppConfigs" ; appconfigs = "MigrateAppConfigs"
}
function Resolve-Name {
  param($Token)
  $k = $Token.ToLowerInvariant().Trim()
  if ($map.ContainsKey($k)) { return $map[$k] }
  foreach ($s in $steps) { if ($s.Id -ieq $k) { return $s.Id } }
  $null
}
if ($Run) {
  Show-Banner
  foreach ($p in ($Run -split ',|%3B' | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    $rid = Resolve-Name $p
    if (-not $rid) { Write-Error "Unknown AIO run token: $p"; exit 2 }
    Invoke-Step -Name $rid
  }
  exit 0
}
Show-Banner
Write-Host "Distro: $Distro  |  Repo (Windows): $RepoRoot" -ForegroundColor DarkGray
Write-Host ""
$i = 0
foreach ($s in $steps) { $i++; Write-Host "  $i) $($s.Id) - $($s.T)" }
Write-Host "  0) Exit`n  R) run multiple (comma list, e.g. MdLinks,Inv)  H) help"
$choice = Read-Host "Choice (empty = wiki menu [7])"
$choice = $choice.Trim()
if ([string]::IsNullOrWhiteSpace($choice)) { Invoke-Step -Name "WikiMenu"; exit 0 }
if ($choice -eq "0" -or $choice -ieq "q") { exit 0 }
if ($choice -ieq "h" -or $choice -ieq "help") {
  Write-Host @"

Run non-interactive:
  .\Kinoite-AIO.ps1 -Run MdLinks,Inv,WikiGen
  `$env:KINOITE_AIO_RUN='Bootstrap,Apply'   # WSL: order matters; Apply needs sudo

Steps: Import, WslConfig, ShowGui, FocusGui, LogonReg, LogonRun, WikiMenu, WikiSync, Inv, MdLinks, Safe, MapImports, Bootstrap, Apply, MigrateAppConfigs
  WikiInit / WikiGen: use -Run wikiinit  or  wikigen
Aliases: wslconfig, wslhost, safe, devcheck, mdlinks, inv, wikisync, plasma, import, apply, …
"@
  exit 0
}
if ($choice -ieq "r" -or $choice -ieq "run") {
  $l = Read-Host "Comma-separated steps"
  $self = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
  & $self -Run $l -Distro $Distro -RepoRoot $RepoRoot
  exit $LASTEXITCODE
}
if ($choice -match '^\d+$') {
  $n = [int]$choice
  if ($n -ge 1 -and $n -le $steps.Count) { Invoke-Step -Name $steps[$n - 1].Id; exit 0 }
}
$rn = Resolve-Name $choice
if ($rn) { Invoke-Step -Name $rn; exit 0 }
Write-Warning "Unrecognized: $choice - try 1-$($steps.Count) or -Run"
exit 1
