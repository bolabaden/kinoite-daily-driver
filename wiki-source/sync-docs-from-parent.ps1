# Regenerates _docs/*.md from the parent Kinoite repository with Jekyll front matter.
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$destDir = Join-Path $PSScriptRoot "_docs"
$null = New-Item -ItemType Directory -Force -Path $destDir

$banner = @"
<div class="sync-banner" markdown="0">
  <strong>Mirrored page.</strong> Generated from the main repo. Relative links may target repository paths -
  use the <a href="https://github.com/bolabaden/kinoite-daily-driver">GitHub tree</a> for navigation.
</div>

"@

function Write-DocPage {
  param(
    [string]$SourcePath,
    [string]$Slug,
    [string]$Title
  )
  if (-not (Test-Path -LiteralPath $SourcePath)) {
    Write-Warning "Skip missing: $SourcePath"
    return
  }
  $body = Get-Content -LiteralPath $SourcePath -Raw -Encoding UTF8
  $fm = @"
---
title: $Title
---

"@
  $out = Join-Path $destDir "$Slug.md"
  Set-Content -LiteralPath $out -Value ($fm + $banner + $body) -Encoding UTF8
}

Write-DocPage (Join-Path $RepoRoot "README.md") "readme" "README - workspace hub"
Write-DocPage (Join-Path $RepoRoot "docs\kinoite-wsl2.md") "kinoite-wsl2" "Fedora Kinoite in WSL2"
Write-DocPage (Join-Path $RepoRoot "docs\windows-migration.md") "windows-migration" "Windows host to Kinoite"
Write-DocPage (Join-Path $RepoRoot "config\README.md") "configuration" "Configuration (config/)"
Write-DocPage (Join-Path $RepoRoot "config\wsl2\README.md") "wsl2-config" "WSL2 / WSLg notes"
Write-DocPage (Join-Path $RepoRoot "scripts\README.md") "scripts" "Scripts index"

Write-Host "Synced markdown into $destDir"
