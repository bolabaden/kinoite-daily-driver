#Requires -Version 5.1
<#
  WSLg draws the Linux GUI in an msrdc (Remote Desktop) window. It may be minimized or behind other apps.
  This script finds a window whose title contains "Kinoite-WS2" (change -Match if your distro name differs) and brings it forward.

  Usage:
    .\scripts\wsl2\Focus-Kinoite-WslgWindow.ps1
    .\scripts\wsl2\Focus-Kinoite-WslgWindow.ps1 -DistroPattern "Kinoite"
#>
param(
  [string] $DistroPattern = "Kinoite-WS2"
)

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
  Where-Object { $_.MainWindowTitle -and ($_.MainWindowTitle -match [regex]::Escape($DistroPattern) -or $_.MainWindowTitle -match "WSL") }

if (-not $candidates) {
  Write-Warning "No msrdc window matched '$DistroPattern'. Is the distro running? Try: wsl -d $DistroPattern -- true"
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
