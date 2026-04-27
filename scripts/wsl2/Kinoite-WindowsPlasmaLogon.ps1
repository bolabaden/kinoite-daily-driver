#Requires -Version 5.1
<#
  Register, remove, or run: WSL2 + Plasma (launch-kde-gui-wslg.sh) at user logon via Task Scheduler.
  Does not call other .ps1 files. -Register / -Unregister need elevated PowerShell.
  -StopExplorer: optional; DANGEROUS. Recovery: Task Manager, File, Run, explorer.
  Env: KINOITE_DISTRO, KINOITE_WORKSPACE_ROOT, KINOITE_WSL_BASH_INIT, KINOITE_STOP_EXPLORER, KINOITE_LOGON_AT_STARTUP (0|1)
#>
[CmdletBinding()]
param(
  [string] $TaskName = "KinoitePlasmaWsl",
  [string] $Distro = $(if ($env:KINOITE_DISTRO) { $env:KINOITE_DISTRO } else { "Kinoite-WS2" }),
  [string] $WorkspaceRoot = $(if ($env:KINOITE_WORKSPACE_ROOT) { $env:KINOITE_WORKSPACE_ROOT } else { "" }),
  [switch] $Register,
  [switch] $Unregister,
  [switch] $RunSession,
  [switch] $AtStartup = ($env:KINOITE_LOGON_AT_STARTUP -eq "1"),
  [switch] $StopExplorer = ($env:KINOITE_STOP_EXPLORER -eq "1"),
  [string] $WslBashInit = $(if ($env:KINOITE_WSL_BASH_INIT) { $env:KINOITE_WSL_BASH_INIT } else { "KINOITE_INTERACTIVE=0" }),
  [string] $LaunchSub = "launch",
  [switch] $WhatIf
)

$ErrorActionPreference = "Stop"
$ThisFile = if ($PSCommandPath) { (Resolve-Path $PSCommandPath).Path } else { (Resolve-Path $MyInvocation.Path).Path }

function Convert-WinPathToWsl {
  param([string] $Path)
  $p = $Path.TrimEnd('\')
  if ($p -notmatch '^([A-Za-z]):\\') { return $Path }
  $d = $Matches[1].ToLower()
  $r = $p.Substring(3) -replace '\\', '/'
  "/mnt/$d/$r"
}
function Test-IsAdmin {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
}
function New-BashLine {
  param([string] $LaunchSh, [string] $Sub, [string] $Init)
  if ([string]::IsNullOrWhiteSpace($Sub)) { $Sub = "launch" }
  $b = [System.Text.StringBuilder]::new()
  foreach ($t in $Init -split '\s+') { if ($t -match '=') { $null = $b.Append("export $t; ") } }
  if ($b.Length -eq 0) { $null = $b.Append("export KINOITE_INTERACTIVE=0; ") }
  $e = $LaunchSh -replace "'", "'\''"
  $null = $b.Append("exec '" + $e + "' " + $Sub)
  $b.ToString()
}

if ($RunSession) {
  if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName
  } else { $WorkspaceRoot = $WorkspaceRoot.TrimEnd('\', '/') }
  $wslPath = Convert-WinPathToWsl -Path $WorkspaceRoot
  $launch = "$wslPath/scripts/wsl2/launch-kde-gui-wslg.sh"
  if (-not (Test-Path (Join-Path $WorkspaceRoot "scripts\wsl2\launch-kde-gui-wslg.sh"))) {
    Write-Error "Repo not found at $WorkspaceRoot (need scripts/wsl2/launch-kde-gui-wslg.sh)"
    exit 1
  }
  $lc = New-BashLine -LaunchSh $launch -Sub $LaunchSub -Init $WslBashInit
  if ($WhatIf) { Write-Host "wsl -d $Distro -- bash -lc $lc"; exit 0 }
  Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", "-lc", $lc) -WindowStyle Normal
  if ($StopExplorer) {
    if (-not (Test-IsAdmin)) { Write-Error "StopExplorer requires an elevated session."; exit 1 }
    Start-Sleep -Seconds 3
    Get-Process -Name "explorer" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Warning "explorer.exe was stopped. Task Manager, Run, explorer  — to restore the shell."
  }
  exit 0
}

if ($Register) {
  if (-not (Test-IsAdmin)) { Write-Error "Elevation required. Run: Start-Process powershell -Verb RunAs -Args '-File … -Register'"; exit 1 }
  if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName }
  $ws = $WorkspaceRoot
  $arg = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ThisFile`" -RunSession -Distro `"$Distro`" -WorkspaceRoot `"$ws`" -WslBashInit `"$WslBashInit`" -LaunchSub `"$LaunchSub`""
  if ($StopExplorer) { $arg = $arg + " -StopExplorer" }
  $act = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arg
  if ($AtStartup) {
    $trig = New-ScheduledTaskTrigger -AtStartup
  } else {
    $trig = New-ScheduledTaskTrigger -AtLogOn
  }
  $set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
  $prin = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
  try { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue } catch { }
  Register-ScheduledTask -TaskName $TaskName -Action $act -Trigger $trig -Settings $set -Principal $prin | Out-Null
  Get-ScheduledTask -TaskName $TaskName
  Write-Host "Registered: \ $TaskName (at $(if($AtStartup){'startup'}else{'logon'}))."
  exit 0
}

if ($Unregister) {
  if (-not (Test-IsAdmin)) { Write-Error "Elevation may be required to remove the task."; exit 1 }
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
  Write-Host "Unregistered: $TaskName"
  exit 0
}

@'
Kinoite-WindowsPlasmaLogon.ps1  (PowerShell 5.1+)

  -Register         Create a scheduled task (at logon, or -AtStartup). Requires admin.
  -Unregister       Remove: \ $TaskName. Requires admin (or the owning user, depending on policy).
  -RunSession       One-shot: start WSL + launch-kde-gui-wslg.sh (this is the task’s action).
  -StopExplorer     With -RunSession, stop explorer after launch (DANGEROUS; needs admin to kill all Explorer).
  -AtStartup        -Register: trigger at startup (default is AtLogOn; env KINOITE_LOGON_AT_STARTUP=1 sets default).

'@ | Write-Host
