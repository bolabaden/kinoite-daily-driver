#Requires -Version 5.1
<#
.SYNOPSIS
  Run `dism /Online /Get-Features` and write imports/dism-features.txt. On exit 740 / "elevated
  permissions required" while not admin, a one-off elevated helper (UAC) runs DISM and writes
  the same file with a header block (provenance + WSL/VM subset) so `imports/` matches the
  repo's host-evidence story (see scripts/README.md, docs/win11-kinoite-parity-matrix.md).
.EXAMPLE
  ./capture-dism-features.ps1
.EXAMPLE
  ./capture-dism-features.ps1 -OutputPath (Join-Path (Get-Location) 'imports\dism-features.txt')
#>
[CmdletBinding()]
param(
  [string] $OutputPath = ""
)

$ErrorActionPreference = "Stop"
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($machinePath -or $userPath) {
  $env:Path = @($env:Path, $machinePath, $userPath) -join ";" 2>$null
}

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $root "imports\dism-features.txt"
}
$outDir = Split-Path -Path $OutputPath -Parent
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
  $null = New-Item -ItemType Directory -Path $outDir -Force
}

$DismExe = Join-Path $env:WINDIR "System32\dism.exe"

function Test-IsAdmin {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-LauncherExe {
  if (Get-Command pwsh -ErrorAction SilentlyContinue) { return (Get-Command pwsh).Source }
  return (Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe")
}

# Parse DISM /Get-Features lines for a small, parity-oriented subset (Kinoite/WSL/VM work).
function Get-OptionalFeatureSubsetBlock {
  param(
    [string[]] $DismLines = [string[]]@(),
    [Parameter(Mandatory)]
    [string[]] $FeatureNames
  )
  if ($null -eq $DismLines) { $DismLines = [string[]]@() }
  if ($DismLines -is [string]) { $DismLines = (ConvertFrom-DismCommandOutput -Native $DismLines) }
  $byName = @{}
  for ($i = 0; $i -lt $DismLines.Count; $i++) {
    if ($DismLines[$i] -match "^\s*Feature Name\s*:\s*(.+?)\s*$") {
      $name = $matches[1].Trim()
      for ($j = $i + 1; $j -lt [Math]::Min($i + 5, $DismLines.Count); $j++) {
        if ($DismLines[$j] -match "^\s*State\s*:\s*(\S+)") { $byName[$name] = $matches[1].Trim(); break }
      }
    }
  }
  $sec = [System.Text.StringBuilder]::new()
  [void]$sec.AppendLine('# --- Subset: WSL / VM / containers / .NET (see full "Feature Name" list below) ---')
  foreach ($n in $FeatureNames) {
    if ($byName.ContainsKey($n)) {
      [void]$sec.AppendLine(("# {0} : {1}" -f $n, $byName[$n]))
    } else {
      [void]$sec.AppendLine(("# {0} : (not in this Get-Features listing)" -f $n))
    }
  }
  $sec.ToString()
}

# Header + subset + body — what the docs expect under `imports/` for host evidence.
function New-DismFeaturesImportDocument {
  param(
    # No [Mandatory]: PS rejects both @() and "" for [string[]]; we normalize empty to @().
    [string[]] $DismOutLines = [string[]]@(),
    [Parameter(Mandatory)]
    [int] $DismExitCode,
    [Parameter(Mandatory)]
    [ValidateSet("in-session", "UAC-elevation")]
    [string] $CaptureMode
  )
  if ($null -eq $DismOutLines) { $DismOutLines = [string[]]@() }
  elseif ($DismOutLines -is [string]) {
    $DismOutLines = ConvertFrom-DismCommandOutput -Native $DismOutLines
  }
  $utc = (Get-Date).ToUniversalTime().ToString("o")
  $local = (Get-Date).ToString("o")
  $ver = if ($PSVersionTable.PSVersion) { $PSVersionTable.PSVersion.ToString() } else { "unknown" }
  $ad = if (Test-IsAdmin) { "yes" } else { "no" }
  $keyNames = @(
    "VirtualMachinePlatform",
    "Microsoft-Windows-Subsystem-Linux",
    "HypervisorPlatform",
    "Microsoft-Hyper-V-All",
    "Containers-DisposableClientVM",
    "Containers",
    "NetFx3"
  )
  $sub = $null
  if ($DismOutLines -and $DismExitCode -eq 0) { $sub = (Get-OptionalFeatureSubsetBlock -DismLines $DismOutLines -FeatureNames $keyNames) }
  $sb = [System.Text.StringBuilder]::new()
  [void]$sb.AppendLine("# Kinoite imports: optional Windows features (DISM: /Online /Get-Features).")
  [void]$sb.AppendLine("# See: scripts/README.md, docs/win11-kinoite-parity-matrix.md, docs/app-mapping.md")
  [void]$sb.AppendLine(("# Captured-UTC: {0}" -f $utc))
  [void]$sb.AppendLine(("# Captured-local: {0}" -f $local))
  [void]$sb.AppendLine(("# Computer: {0}" -f $env:COMPUTERNAME))
  [void]$sb.AppendLine(("# PowerShell: {0}" -f $ver))
  [void]$sb.AppendLine(("# DISM: {0}" -f $DismExe))
  [void]$sb.AppendLine(("# dism exit code: {0}" -f $DismExitCode))
  [void]$sb.AppendLine(("# Admin for initial script session: {0}" -f $ad))
  [void]$sb.AppendLine(("# Capture: {0}" -f $CaptureMode))
  [void]$sb.AppendLine("#")
  if ($sub) { [void]$sb.Append($sub) } else { [void]$sb.AppendLine("# (subset not parsed; non-zero dism or empty output.)") }
  [void]$sb.AppendLine("#")
  [void]$sb.AppendLine('# ---- raw: dism /Online /Get-Features output below ----')
  [void]$sb.AppendLine("")
  $rawBody = if ($null -ne $DismOutLines -and $DismOutLines.Count -gt 0) { ($DismOutLines -join [Environment]::NewLine) } else { "" }
  [void]$sb.Append($rawBody)
  if ($rawBody -and -not $rawBody.EndsWith([Environment]::NewLine)) { [void]$sb.AppendLine("") }
  $sb.ToString()
}

function Start-ElevatedDismAndRead {
  param([Parameter(Mandatory)] [string] $LiteralPath)
  $b64Dism = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($DismExe))
  $b64Path = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($LiteralPath))
  $raw = @'
$ErrorActionPreference = "Stop"
$dism = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("B64_DISM"))
$path = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("B64_PATH"))
$dir = [System.IO.Path]::GetDirectoryName($path)
if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$out = & $dism /Online /Get-Features 2>&1
$dismExit = $LASTEXITCODE
Set-Content -LiteralPath $path -Value $out -Encoding utf8
exit $dismExit
'@
  $raw = $raw.Replace("B64_DISM", $b64Dism).Replace("B64_PATH", $b64Path)
  $child = Join-Path $env:TEMP "kinoite-dism-$(New-Guid).ps1"
  Set-Content -LiteralPath $child -Value $raw -Encoding utf8
  $exe = Get-LauncherExe
  try {
    $proc = Start-Process -FilePath $exe -ArgumentList @(
      "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $child
    ) -Verb RunAs -PassThru -Wait
  } finally {
    Remove-Item -LiteralPath $child -Force -ErrorAction SilentlyContinue
  }
  if ($null -eq $proc) {
    throw "Elevation did not return a process (UAC may have been cancelled or denied)."
  }
  if ($proc.ExitCode -ne 0) {
    if ($proc.ExitCode -eq 1223) { throw "UAC prompt was cancelled (exit code 1223)." }
    throw "Elevated DISM exited with $($proc.ExitCode). Check the partial file at: $LiteralPath"
  }
  if (-not (Test-Path -LiteralPath $LiteralPath)) { throw "Missing file after UAC: $LiteralPath" }
  return (Get-Content -LiteralPath $LiteralPath -Raw)
}

function DismTextToLineArray {
  param(
    [AllowNull()]
    [AllowEmptyString()]
    [string] $Raw
  )
  if ($null -eq $Raw -or [string]::IsNullOrEmpty($Raw)) { return [string[]]@() }
  return [string[]]@($Raw -split "\r?\n" | ForEach-Object { "$_" })
}

# & dism may return [Object[]] or a single [string] — do not use ForEach on a string (char iteration).
function ConvertFrom-DismCommandOutput {
  param($Native)
  if ($null -eq $Native) { return [string[]]@() }
  $t = if ($Native -is [string]) { $Native } else { ($Native | ForEach-Object { "$_" }) -join [Environment]::NewLine }
  if ([string]::IsNullOrEmpty($t)) { return [string[]]@() }
  return [string[]]@($t -split "\r?\n" | ForEach-Object { "$_" })
}

# --- DISM: try System32 dism; on 740, delegate to UAC helper ---
$dismCode = 0
$lines = $null
$blob = ""
$text = $null
$captureMode = "in-session"
try {
  if (-not (Test-Path -LiteralPath $DismExe)) { throw "Not found: $DismExe" }
  $lines = & $DismExe /Online /Get-Features 2>&1
  $dismCode = $LASTEXITCODE
  $arr = (ConvertFrom-DismCommandOutput -Native $lines)
  $blob = if ($arr.Count) { $arr -join [Environment]::NewLine } else { "" }
  if ($dismCode -ne 0) { throw "DISM_NONZERO" }
  $text = (New-DismFeaturesImportDocument -DismOutLines $arr -DismExitCode $dismCode -CaptureMode $captureMode)
  $text | Set-Content -LiteralPath $OutputPath -Encoding utf8
} catch {
  if ($_.Exception.Message -ne "DISM_NONZERO" -or $dismCode -eq 0) { throw $_.Exception }

  $uac = ($dismCode -eq 740) -or ($blob -match 'Error:\s*740') -or
         ($blob -match "Elevated permissions are required to run DISM")
  if (-not $uac) {
    if ($null -ne $lines) {
      $arr2 = (ConvertFrom-DismCommandOutput -Native $lines)
      $text = (New-DismFeaturesImportDocument -DismOutLines $arr2 -DismExitCode $dismCode -CaptureMode $captureMode)
      $text | Set-Content -LiteralPath $OutputPath -Encoding utf8
    }
    throw "dism.exe failed (exit $dismCode). $blob"
  }
  if (Test-IsAdmin) {
    if ($null -ne $lines) {
      $arr2 = (ConvertFrom-DismCommandOutput -Native $lines)
      $text = (New-DismFeaturesImportDocument -DismOutLines $arr2 -DismExitCode $dismCode -CaptureMode $captureMode)
      $text | Set-Content -LiteralPath $OutputPath -Encoding utf8
    }
    throw "DISM still reports 740/elevation in an **elevated** session. $blob"
  }
  Write-Verbose "Catching 740 / UAC case — re-running via elevated PowerShell…"
  $captureMode = "UAC-elevation"
  $raw = (Start-ElevatedDismAndRead -LiteralPath $OutputPath)
  $dismCode = 0
  $arr3 = DismTextToLineArray -Raw $raw
  $text = (New-DismFeaturesImportDocument -DismOutLines $arr3 -DismExitCode $dismCode -CaptureMode $captureMode)
  $text | Set-Content -LiteralPath $OutputPath -Encoding utf8
}
if ($null -eq $text) {
  if (Test-Path -LiteralPath $OutputPath) { $text = Get-Content -LiteralPath $OutputPath -Raw }
  else { $text = "" }
}
$len = 0
if (Test-Path -LiteralPath $OutputPath) { $len = (Get-Item -LiteralPath $OutputPath).Length }
Write-Host "Wrote: $OutputPath ($len bytes)" -ForegroundColor Green
return $text
