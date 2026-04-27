#Requires -Version 5.1
<#
  Installs the Windows host WSL2 template from config/wsl2/README.md (### `windows.wslconfig` `ini` fence)
  to %UserProfile%\.wslconfig — the same source of truth as the manual copy path in that README.

  Default: write only if .wslconfig is missing.
  -Force: backup existing to .wslconfig.bak.YYYYMMDD-HHMMSS then replace.
  -WhatIf: show what would be written; no changes.

  Does not call other .ps1 scripts. Set KINOITE_WORKSPACE_ROOT to the repo root, or run with this file under <repo>\scripts\wsl2\.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string] $RepoRoot = $(if ($env:KINOITE_WORKSPACE_ROOT) { $env:KINOITE_WORKSPACE_ROOT.TrimEnd('\', '/') } else { "" }),
  [string] $Destination = $(Join-Path $env:USERPROFILE ".wslconfig"),
  [switch] $Force
)

$ErrorActionPreference = "Stop"
$Here = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $RepoRoot = (Split-Path -Parent (Split-Path -Parent $Here))
}
$Readme = Join-Path $RepoRoot "config\wsl2\README.md"
if (-not (Test-Path -LiteralPath $Readme)) {
  Write-Error "Missing $Readme (set KINOITE_WORKSPACE_ROOT to your clone root)."
}

function Get-WindowsWslConfigIni {
  param([string]$Path)
  $lines = Get-Content -LiteralPath $Path -Encoding UTF8
  $seenHeading = $false
  $inFence = $false
  $buf = [System.Collections.Generic.List[string]]::new()
  foreach ($line in $lines) {
    if ($line -match '^### `windows\.wslconfig`') { $seenHeading = $true; continue }
    if (-not $seenHeading) { continue }
    if (-not $inFence) {
      if ($line -eq '```ini') { $inFence = $true }
      continue
    }
    if ($line -eq '```') { break }
    [void]$buf.Add($line)
  }
  if ($buf.Count -eq 0) {
    throw ('Install-WslHostConfig: parse error - no ini fenced block after the ### windows.wslconfig heading in: ' + $Path)
  }
  return ($buf -join "`n") + "`n"
}

try {
  $ini = Get-WindowsWslConfigIni -Path $Readme
} catch {
  throw "Install-WslHostConfig: failed to read template from $Readme : $_"
}
$dest = $Destination
$exists = Test-Path -LiteralPath $dest

if ($exists -and -not $Force) {
  if ($WhatIfPreference) {
    Write-Host "Path: $dest`n---" -ForegroundColor Cyan
    $ini
    Write-Warning "What if: would not write (file already exists). Use -Force to backup and replace, or remove the file first."
    exit 0
  }
  Write-Warning "Skipping: $dest already exists. Use -Force to backup and replace, or remove the file first."
  exit 0
}

if ($exists -and $Force) {
  $bak = "$dest.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  if ($WhatIfPreference) {
    Write-Host "What if: Would copy $dest to $bak" -ForegroundColor Cyan
  } else {
    if (-not $PSCmdlet.ShouldProcess($dest, "Backup to $bak")) { exit 0 }
    Copy-Item -LiteralPath $dest -Destination $bak
    Write-Verbose "Backup: $bak"
  }
}

if ($WhatIfPreference) {
  Write-Host "Path: $dest`n---" -ForegroundColor Cyan
  $ini
}
if (-not $PSCmdlet.ShouldProcess($dest, "Write WSL2 host config from $Readme")) { exit 0 }
if ($WhatIfPreference) { exit 0 }
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($dest, $ini, $utf8)
Write-Host "Wrote: $dest" -ForegroundColor Green
Write-Host "Run: wsl --shutdown   (then reopen your distro) for changes to apply."
exit 0
