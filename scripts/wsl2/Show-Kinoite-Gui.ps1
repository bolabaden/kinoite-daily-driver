#Requires -Version 5.1
<#
  Starts Kinoite WSL2 GUI from your Windows desktop session (helps WSLg attach when IDE terminals do not),
  or focuses an existing WSLg (msrdc) window.
  Usage (PowerShell):
    $env:KINOITE_WORKSPACE_ROOT = "D:\repos\Kinoite"   # optional; else repo is inferred from this script's path
    .\scripts\wsl2\Show-Kinoite-Gui.ps1
    .\scripts\wsl2\Show-Kinoite-Gui.ps1 -Focus
  Optional: -Distro "Kinoite-WS2" -ShutdownFirst
  WSL path for the repo: -RepoMount "/mnt/…/Kinoite" (default from KINOITE_WORKSPACE_ROOT or repo root).
#>
param(
  [string] $Distro = "Kinoite-WS2",
  [switch] $ShutdownFirst,
  [string] $RepoMount = "",
  [switch] $Focus
)

$ErrorActionPreference = "Stop"

function Convert-WindowsPathToWslPath {
  param([Parameter(Mandatory)] [string] $Path)
  $trim = $Path.TrimEnd('\')
  if ($trim -notmatch '^([A-Za-z]):\\') {
    return $Path
  }
  $drive = $Matches[1].ToLower()
  $rest = $trim.Substring(3) -replace '\\', '/'
  "/mnt/$drive/$rest"
}

if ($Focus) {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WslgWindow {
  [DllImport("user32.dll")]
  public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")]
  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  public const int SW_RESTORE = 9;
}
"@
  $candidates = Get-Process -Name "msrdc" -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -and ($_.MainWindowTitle -match [regex]::Escape($Distro) -or $_.MainWindowTitle -match "WSL") }

  if (-not $candidates) {
    Write-Warning "No msrdc window matched '$Distro'. Is the distro running? Try: wsl -d $Distro -- true"
    Write-Host "All msrdc windows:"
    Get-Process -Name "msrdc" -ErrorAction SilentlyContinue | ForEach-Object { "  PID=$($_.Id) Title=$($_.MainWindowTitle)" }
    exit 1
  }

  foreach ($p in $candidates) {
    if ($p.MainWindowHandle -eq [IntPtr]::Zero) { continue }
    [void][WslgWindow]::ShowWindow($p.MainWindowHandle, [WslgWindow]::SW_RESTORE)
    [void][WslgWindow]::SetForegroundWindow($p.MainWindowHandle)
    Write-Host "Focused: PID=$($p.Id) $($p.MainWindowTitle)"
  }
  exit 0
}

if ([string]::IsNullOrWhiteSpace($RepoMount)) {
  $winRoot = $env:KINOITE_WORKSPACE_ROOT
  if ([string]::IsNullOrWhiteSpace($winRoot)) {
    $winRoot = (Get-Item (Join-Path $PSScriptRoot "..\..")).FullName
  } else {
    $winRoot = $winRoot.TrimEnd('\', '/')
  }
  $RepoMount = Convert-WindowsPathToWslPath -Path $winRoot
}

$launch = "$RepoMount/scripts/wsl2/launch-kde-gui-wslg.sh"
if ($ShutdownFirst) {
  wsl.exe --shutdown
  Start-Sleep -Seconds 2
}

Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", $launch) -WindowStyle Normal
Write-Host "Launched: wsl -d $Distro -- bash $launch"
Write-Host "Check the taskbar for Konsole / Dolphin / Plasma. Logs in distro: /tmp/kinoite-wsl2-gui/"
