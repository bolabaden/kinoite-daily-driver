#Requires -Version 5.1
<#
  Starts Kinoite WSL2 GUI from your Windows desktop session (helps WSLg attach when IDE terminals do not).
  Usage (PowerShell):
    $env:KINOITE_WORKSPACE_ROOT = "D:\repos\Kinoite"   # optional; else repo is inferred from this script's path
    .\scripts\wsl2\Show-Kinoite-Gui.ps1
  Optional: -Distro "Kinoite-WS2" -ShutdownFirst
  WSL path for the repo: -RepoMount "/mnt/…/Kinoite" (default from KINOITE_WORKSPACE_ROOT or repo root).
#>
param(
  [string] $Distro = "Kinoite-WS2",
  [switch] $ShutdownFirst,
  [string] $RepoMount = ""
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
