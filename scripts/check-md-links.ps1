#Requires -Version 5.1
# Scans repo *.md for relative file links; reports targets that do not exist.
# Excludes: .git, .history, .cursor, .firecrawl (editor / scratch trees).
# -Interactive: choose scan root. Env: KINOITE_MD_LINK_ROOT
param(
  [string]$Root = $(if ($env:KINOITE_MD_LINK_ROOT) { $env:KINOITE_MD_LINK_ROOT } else { (Split-Path -Parent $PSScriptRoot) }),
  [switch]$Interactive
)
if ($Interactive) {
  $def = (Split-Path -Parent $PSScriptRoot)
  Write-Host "Default scan root: $def"
  $r = Read-Host "Path to scan (Enter for default)"
  if ($r) { $Root = $r }
  if (-not (Test-Path -LiteralPath $Root)) { throw "Not found: $Root" }
}
$skipSegment = { param($p)
  if ($p -match '(\\|/)wiki(\\|/)' -or $p -match '(\\|/)wiki-source(\\|/)') { return $true }
  $parts = $p -split [regex]::Escape([IO.Path]::DirectorySeparatorChar)
  $parts -contains ".git" -or $parts -contains ".history" -or $parts -contains ".cursor" -or $parts -contains ".firecrawl"
}
$missing = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -Path $Root -Recurse -File -Filter "*.md" | ForEach-Object {
  $f = $_
  if (& $skipSegment $f.FullName) { return }
  $dir = $f.DirectoryName
  foreach ($line in [System.IO.File]::ReadAllLines($f.FullName)) {
    [regex]::Matches($line, '\[[^\]]*\]\(([^)]+)\)') | ForEach-Object {
      $u = $_.Groups[1].Value.Trim()
      if ($u -match '^(https?|mailto|vscode|file|ftp):') { return }
      if ($u.StartsWith("#")) { return }
      $pathOnly = ($u -split "#", 2)[0] -split "\?", 2 | Select-Object -First 1
      if ([string]::IsNullOrWhiteSpace($pathOnly)) { return }
      if ($pathOnly -match "^(https?|mailto|vscode|file|ftp):") { return }
      $cand = [IO.Path]::GetFullPath([IO.Path]::Combine($dir, $pathOnly))
      if (-not (Test-Path -LiteralPath $cand)) {
        [void]$missing.Add("$( $f.FullName ) -> $pathOnly`n  expected: $cand")
      }
    }
  }
}
$missing | Sort-Object -Unique
if ($missing.Count -gt 0) { exit 1 }
Write-Host "OK: no missing relative file link targets in *.md (scanned from $Root)." -ForegroundColor Green
exit 0
