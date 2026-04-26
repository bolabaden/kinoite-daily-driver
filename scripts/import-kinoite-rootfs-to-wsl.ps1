#Requires -Version 5.1
<#
.SYNOPSIS
  Build a WSL2-importable rootfs.tar from Fedora Kinoite OCI and optionally wsl --import.

.PARAMETER Image
  Full OCI reference (default: quay.io/fedora-ostree-desktops/kinoite:43).

.PARAMETER TarPath
  Where to write the export tarball. Default: <repo>\scratch\kinoite-wsl-rootfs.tar, where
  repo is KINOITE_WORKSPACE_ROOT or the parent of the scripts\ directory.

.PARAMETER DistroName
  WSL distribution name (default: Kinoite-WS2).

.PARAMETER InstallLocation
  WSL filesystem directory on NTFS. No default. Set KINOITE_WSL_INSTALL_DIR or pass this when
  using -DoImport (required for import).

.PARAMETER DoImport
  If set, runs wsl --import after export (requires existing TarPath or successful export).

.NOTES
  Run from elevated PowerShell if InstallLocation requires it.
  Ensure podman works: podman version
  Optional: KINOITE_WORKSPACE_ROOT (see kinoite-workspace-root.env.example) for default TarPath.
#>
param(
  [string]$Image = "quay.io/fedora-ostree-desktops/kinoite:43",
  [string]$TarPath = "",
  [string]$DistroName = "Kinoite-WS2",
  [string]$InstallLocation = $env:KINOITE_WSL_INSTALL_DIR,
  [switch]$DoImport
)

$ErrorActionPreference = "Stop"

$repoRoot = if (-not [string]::IsNullOrWhiteSpace($env:KINOITE_WORKSPACE_ROOT)) {
  $env:KINOITE_WORKSPACE_ROOT.TrimEnd('\', '/')
} else {
  (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
if ([string]::IsNullOrWhiteSpace($TarPath)) {
  $TarPath = Join-Path $repoRoot "scratch\kinoite-wsl-rootfs.tar"
}

if ($DoImport) {
  if ([string]::IsNullOrWhiteSpace($InstallLocation)) {
    throw "For -DoImport, set KINOITE_WSL_INSTALL_DIR or pass -InstallLocation (NTFS path for the distro's files)."
  }
}

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
