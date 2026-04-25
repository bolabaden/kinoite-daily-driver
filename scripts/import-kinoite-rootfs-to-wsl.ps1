#Requires -Version 5.1
<#
.SYNOPSIS
  Build a WSL2-importable rootfs.tar from Fedora Kinoite OCI and optionally wsl --import.

.PARAMETER Image
  Full OCI reference (default: quay.io/fedora-ostree-desktops/kinoite:43).

.PARAMETER TarPath
  Where to write the export tarball (default: G:\workspaces\Kinoite\scratch\kinoite-wsl-rootfs.tar).

.PARAMETER DistroName
  WSL distribution name (default: Kinoite-WS2).

.PARAMETER InstallLocation
  WSL filesystem directory on NTFS (default: G:\WSL\Kinoite-WS2).

.PARAMETER DoImport
  If set, runs wsl --import after export (requires existing TarPath or successful export).

.NOTES
  Run from elevated PowerShell if InstallLocation requires it.
  Ensure podman works: podman version
#>
param(
  [string]$Image = "quay.io/fedora-ostree-desktops/kinoite:43",
  [string]$TarPath = "G:\workspaces\Kinoite\scratch\kinoite-wsl-rootfs.tar",
  [string]$DistroName = "Kinoite-WS2",
  [string]$InstallLocation = "G:\WSL\Kinoite-WS2",
  [switch]$DoImport
)

$ErrorActionPreference = "Stop"
$containerName = "kinoite-wsl-export-temp"

Write-Host "==> podman pull $Image"
podman pull $Image

$scratch = Split-Path -Parent $TarPath
if (-not (Test-Path $scratch)) { New-Item -ItemType Directory -Path $scratch -Force | Out-Null }

podman rm -f $containerName 2>$null
Write-Host "==> podman create $containerName"
podman create --name $containerName $Image | Out-Null

Write-Host "==> podman export -> $TarPath"
if (Test-Path $TarPath) { Remove-Item -Force $TarPath }
podman export $containerName -o $TarPath

Write-Host "==> podman rm $containerName"
podman rm $containerName | Out-Null

Write-Host "Export complete: $TarPath"
if (-not (Test-Path $TarPath)) { throw "Export failed: missing $TarPath" }

if ($DoImport) {
  if (-not (Test-Path $InstallLocation)) { New-Item -ItemType Directory -Path $InstallLocation -Force | Out-Null }
  Write-Host "==> wsl --import $DistroName $InstallLocation $TarPath --version 2"
  wsl --import $DistroName $InstallLocation $TarPath --version 2
  Write-Host "Done. Next: copy wsl.conf into distro etc, then wsl --shutdown"
}
