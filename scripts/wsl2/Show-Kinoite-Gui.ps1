#Requires -Version 5.1
<#
  Start Kinoite WSL2 Plasma (WSLg) from Windows, or focus the WSLg (msrdc) window.
  This file does not invoke other .ps1 scripts. It uses wsl.exe to run
  scripts/wsl2/launch-kde-gui-wslg.sh in the Linux distro (documented OS boundary).

  Non-interactive env (read when parameters omitted): KINOITE_DISTRO, KINOITE_WORKSPACE_ROOT,
  KINOITE_GUI_ACTION (Launch|Focus|Menu), KINOITE_PLASMA_SUBCMD, KINOITE_WSL_BASH_INIT (e.g. KINOITE_INTERACTIVE=0).

  TUI: -Action Menu  or  -Interactive
#>
[CmdletBinding()]
param(
  [string] $Distro = $(if ($env:KINOITE_DISTRO) { $env:KINOITE_DISTRO } else { "Kinoite-WS2" }),
  [string] $RepoMount = $(if ($env:KINOITE_WSL_REPO_MOUNT) { $env:KINOITE_WSL_REPO_MOUNT } else { "" }),
  [switch] $ShutdownFirst,
  [switch] $Focus,
  [ValidateSet("Launch", "Focus", "Menu", "")]
  [string] $Action = $(if ($env:KINOITE_GUI_ACTION) { $env:KINOITE_GUI_ACTION } else { "" }),
  [switch] $Interactive,
  [string] $LaunchSubCommand = $(if ($env:KINOITE_PLASMA_SUBCMD) { $env:KINOITE_PLASMA_SUBCMD } else { "" }),
  [string] $WslBashInit = $(if ($env:KINOITE_WSL_BASH_INIT) { $env:KINOITE_WSL_BASH_INIT } else { "KINOITE_INTERACTIVE=0" })
)

$ErrorActionPreference = "Stop"

function Get-HelpText {
  @'
Kinoite Show-Kinoite-Gui.ps1 — Windows PowerShell 5.1+

  -Focus                    Foreground WSLg (msrdc) for this distro.
  -Action Launch|Focus|Menu  Launch plasmashell path (default), focus, or menu.
  -Interactive               Same as -Action Menu.
  -Distro <name>             WSL name (KINOITE_DISTRO).
  -RepoMount                 WSL path to repo root, e.g. /mnt/g/workspaces/Kinoite.
  -ShutdownFirst            Run wsl --shutdown before launch.
  -LaunchSubCommand         First arg to launch-kde-gui-wslg.sh: smoke, verify, menu, etc.
  -WslBashInit               Space-separated VAR=val for a leading export line (KINOITE_WSL_BASH_INIT).
'@
}

function Convert-WinPathToWsl {
  param([string] $Path)
  $p = $Path.TrimEnd('\')
  if ($p -notmatch '^([A-Za-z]):\\') { return $Path }
  $d = $Matches[1].ToLower()
  $r = $p.Substring(3) -replace '\\', '/'
  "/mnt/$d/$r"
}

function New-WslLaunchBash {
  param(
    [string] $LaunchShPath,
    [string] $Sub,
    [string] $WslBashInit
  )
  if ([string]::IsNullOrWhiteSpace($Sub)) { $Sub = "launch" }
  $exports = [System.Text.StringBuilder]::new()
  foreach ($t in $WslBashInit -split '\s+') {
    if ([string]::IsNullOrWhiteSpace($t)) { continue }
    if ($t -notmatch '=') { continue }
    $null = $exports.Append("export $t; ")
  }
  if ($exports.Length -eq 0) { $null = $exports.Append("export KINOITE_INTERACTIVE=0; ") }
  $esc = $LaunchShPath -replace "'", "'\''" 
  $s = $exports.ToString() + "exec '" + $esc + "' $Sub"
  return $s
}

function Move-WslgToFront {
  param([string] $D)
  Add-Type @"
using System; using System.Runtime.InteropServices;
public class KinoWslgWin2 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  public const int SW_RESTORE = 9;
}
"@
  $candidates = Get-Process -Name "msrdc" -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -and ($_.MainWindowTitle -match [regex]::Escape($D) -or $_.MainWindowTitle -match "WSL") }
  if (-not $candidates) {
    Write-Warning "No msrdc for '$D'. Try: wsl -d $D -- true"
    return $false
  }
  foreach ($p in $candidates) {
    if ($p.MainWindowHandle -eq [IntPtr]::Zero) { continue }
    [void][KinoWslgWin2]::ShowWindow($p.MainWindowHandle, [KinoWslgWin2]::SW_RESTORE)
    [void][KinoWslgWin2]::SetForegroundWindow($p.MainWindowHandle)
    Write-Host "Focused: PID=$($p.Id) $($p.MainWindowTitle)"
  }
  return $true
}

if ($Focus) { $Action = "Focus" }
if ($Interactive) { $Action = "Menu" }
if ($Action -eq "Menu") {
  Get-HelpText
  if ([string]::IsNullOrWhiteSpace($RepoMount)) {
    $wr = $env:KINOITE_WORKSPACE_ROOT
    if ([string]::IsNullOrWhiteSpace($wr)) { $wr = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName }
    else { $wr = $wr.TrimEnd('\', '/') }
    $RepoMount = Convert-WinPathToWsl -Path $wr
  }
  $lp = "$RepoMount/scripts/wsl2/launch-kde-gui-wslg.sh"
  Write-Host "=== Kinoite: Plasma (menu) ===" -ForegroundColor Cyan
  Write-Host "1) Launch Plasma  2) Focus WSLg  3) Shutdown WSL + launch  4) Help  0) Exit"
  $c = Read-Host "Choice (default 1)"
  if ([string]::IsNullOrWhiteSpace($c)) { $c = "1" }
  switch -Regex ($c) {
    '^\s*1\s*$' {
      $cmd = New-WslLaunchBash -LaunchShPath $lp -Sub "launch" -WslBashInit $WslBashInit
      if ($ShutdownFirst) { wsl.exe @("--shutdown"); Start-Sleep -Seconds 2 }
      Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", "-lc", $cmd) -WindowStyle Normal
      Write-Host "Started: wsl -d $Distro -- bash -lc … launch"
      exit 0
    }
    '^\s*2\s*$' { if (Move-WslgToFront -D $Distro) { } else { exit 1 }; exit 0 }
    '^\s*3\s*$' {
      $cmd = New-WslLaunchBash -LaunchShPath $lp -Sub "launch" -WslBashInit $WslBashInit
      wsl.exe @("--shutdown"); Start-Sleep -Seconds 2
      Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", "-lc", $cmd) -WindowStyle Normal
      exit 0
    }
    '^\s*4\s*$' { Get-HelpText; exit 0 }
    '^\s*0\s*$' { exit 0 }
    default { Write-Warning "Invalid choice."; exit 1 }
  }
}
if ($Action -eq "Focus") {
  if (-not (Move-WslgToFront -D $Distro)) { exit 1 }
  exit 0
}

# Launch
if ([string]::IsNullOrWhiteSpace($RepoMount)) {
  $wr = $env:KINOITE_WORKSPACE_ROOT
  if ([string]::IsNullOrWhiteSpace($wr)) { $wr = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName }
  else { $wr = $wr.TrimEnd('\', '/') }
  $RepoMount = Convert-WinPathToWsl -Path $wr
}
$launch = "$RepoMount/scripts/wsl2/launch-kde-gui-wslg.sh"
$sub = if ($LaunchSubCommand) { $LaunchSubCommand } else { "launch" }
$bashLc = New-WslLaunchBash -LaunchShPath $launch -Sub $sub -WslBashInit $WslBashInit
if ($ShutdownFirst) { wsl.exe @("--shutdown"); Start-Sleep -Seconds 2 }
Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", "-lc", $bashLc) -WindowStyle Normal
Write-Host "Launched: wsl -d $Distro (exec launch script, subcommand=$sub)"
Write-Host "Logs: /tmp/kinoite-wsl2-gui/  (in distro)"
