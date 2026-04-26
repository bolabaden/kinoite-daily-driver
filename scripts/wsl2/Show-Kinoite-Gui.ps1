#Requires -Version 5.1
<#
  Starts Kinoite WSL2 GUI from your Windows desktop session (helps WSLg attach when IDE terminals do not).
  Usage (PowerShell):
    cd G:\workspaces\Kinoite
    .\scripts\wsl2\Show-Kinoite-Gui.ps1
  Optional: -Distro "Kinoite-WS2" -ShutdownFirst
#>
param(
  [string] $Distro = "Kinoite-WS2",
  [switch] $ShutdownFirst,
  [string] $RepoMount = "/mnt/g/workspaces/Kinoite"
)

$ErrorActionPreference = "Stop"
if ($ShutdownFirst) {
  wsl.exe --shutdown
  Start-Sleep -Seconds 2
}

$launch = "$RepoMount/scripts/wsl2/launch-kde-gui-wslg.sh"
Start-Process -FilePath "wsl.exe" -ArgumentList @("-d", $Distro, "--", "bash", $launch) -WindowStyle Normal
Write-Host "Launched: wsl -d $Distro -- bash $launch"
Write-Host "Check the taskbar for Konsole / Dolphin / Plasma. Logs in distro: /tmp/kinoite-wsl2-gui/"
