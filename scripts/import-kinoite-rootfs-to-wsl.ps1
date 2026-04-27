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
  Optional: KINOITE_WORKSPACE_ROOT (see config/README.md — workspace + locale) for default TarPath.
#>
param(
  [string]$Image = $(if ($env:KINOITE_OCI_IMAGE) { $env:KINOITE_OCI_IMAGE } else { "quay.io/fedora-ostree-desktops/kinoite:43" }),
  [string]$TarPath = "",
  [string]$DistroName = $(if ($env:KINOITE_WSL_DISTRO) { $env:KINOITE_WSL_DISTRO } else { "Kinoite-WS2" }),
  [string]$InstallLocation = $env:KINOITE_WSL_INSTALL_DIR,
  [switch]$DoImport = ($env:KINOITE_WSL_DO_IMPORT -eq "1"),
  [switch]$Interactive
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
if ($Interactive) {
  Write-Host "=== Kinoite: import rootfs (TUI) ===" -ForegroundColor Cyan
  $i = Read-Host "OCI image [$Image]"
  if ($i) { $Image = $i }
  $t = Read-Host "Tar out path [$TarPath]"
  if ($t) { $TarPath = $t }
  $d = Read-Host "Distro name [$DistroName]"
  if ($d) { $DistroName = $d }
  $di = Read-Host "Run wsl --import after export? (y/N)"
  if ($di -match '^[yY]') {
    $DoImport = $true
    if ([string]::IsNullOrWhiteSpace($InstallLocation)) {
      $il = Read-Host "Install location (NTFS path, required)"
      $InstallLocation = $il
    } else {
      $il2 = Read-Host "Install location [$InstallLocation]"
      if ($il2) { $InstallLocation = $il2 }
    }
  }
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
