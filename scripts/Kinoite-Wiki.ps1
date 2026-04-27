#Requires -Version 5.1
<#
  One entry: GitHub wiki submodule (Init), Jekyll _docs (GenerateDocs), robocopy + commit (Sync).
  Does not call other .ps1 files in this repo. Env: KINOITE_WIKI_ACTION, KINOITE_WIKI_URL, KINOITE_WIKI_PUSH
#>
[CmdletBinding()]
param(
  [ValidateSet("Init", "Sync", "GenerateDocs", "Menu", "")]
  [string] $Action = $(if ($env:KINOITE_WIKI_ACTION) { $env:KINOITE_WIKI_ACTION } else { "" }),
  [string] $RepoRoot = "",
  [switch] $Push = ($env:KINOITE_WIKI_PUSH -eq "1"),
  [string] $CommitMessage = "docs(wiki): sync Jekyll site and mirrored markdown",
  [string] $WikiUrl = "https://github.com/bolabaden/kinoite-daily-driver.wiki.git",
  [int] $PollSeconds = 15,
  [int] $MaxAttempts = 40,
  [switch] $Interactive
)

$ErrorActionPreference = "Stop"
$Root = if ($RepoRoot) { $RepoRoot } else { Split-Path $PSScriptRoot -Parent }
$WikiSrc = Join-Path $Root "wiki-source"
$WikiDir = Join-Path $Root "wiki"
$destDir = Join-Path $WikiSrc "_docs"

$banner = @"
<div class="sync-banner" markdown="0">
  <strong>Mirrored page.</strong> Generated from the main repo. Relative links may target repository paths -
  use the <a href="https://github.com/bolabaden/kinoite-daily-driver">GitHub tree</a> for navigation.
</div>

"@

function Write-WikiDocPage {
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

function Invoke-GenerateDocs {
  $null = New-Item -ItemType Directory -Force -Path $destDir
  Write-WikiDocPage (Join-Path $Root "README.md") "readme" "README - workspace hub"
  Write-WikiDocPage (Join-Path $Root "docs\kinoite-wsl2.md") "kinoite-wsl2" "Fedora Kinoite in WSL2"
  Write-WikiDocPage (Join-Path $Root "docs\windows-migration.md") "windows-migration" "Windows host to Kinoite"
  Write-WikiDocPage (Join-Path $Root "config\README.md") "configuration" "Configuration (config/)"
  Write-WikiDocPage (Join-Path $Root "config\wsl2\README.md") "wsl2-config" "WSL2 / WSLg notes"
  Write-WikiDocPage (Join-Path $Root "scripts\README.md") "scripts" "Scripts index"
  Write-Host "Synced markdown into $destDir"
}

function Invoke-Init {
  Set-Location $Root
  if (Test-Path (Join-Path $Root "wiki\.git")) {
    Write-Host "wiki/ already exists. Run: git submodule update --init wiki"
    return
  }
  Write-Host "Ensure the wiki exists: open https://github.com/bolabaden/kinoite-daily-driver/wiki and create the first page, then Save."
  Write-Host "Polling $WikiUrl ..."
  for ($i = 0; $i -lt $MaxAttempts; $i++) {
    git ls-remote $WikiUrl 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Set-Location $Root
      Write-Host "Wiki remote is reachable."
      git submodule add $WikiUrl wiki
      git submodule update --init wiki
      Write-Host "Done. Next: Kinoite-Wiki.ps1 -Action Sync"
      return
    }
    Start-Sleep -Seconds $PollSeconds
  }
  Write-Error "Wiki remote still unavailable after $($MaxAttempts * $PollSeconds)s. Create the first wiki page on GitHub, then re-run."
}

function Invoke-Sync {
  if (-not (Test-Path $WikiSrc)) { Write-Error "Missing wiki-source/."; return }
  Set-Location $Root
  Invoke-GenerateDocs
  if (-not (Test-Path (Join-Path $WikiDir ".git"))) {
    Write-Host @"

Wiki submodule is not initialized yet.

1. Open https://github.com/bolabaden/kinoite-daily-driver/wiki and create the first wiki page, then Save.
2. From repo root: git submodule update --init --recursive wiki
   If wiki/ is missing: git submodule add $WikiUrl wiki
3. Re-run: Kinoite-Wiki.ps1 -Action Sync

"@
    exit 1
  }
  $xd = @("/XD", ".git", "_site", "vendor", "bundle", ".sass-cache", ".jekyll-cache", "node_modules")
  $rc = @($WikiSrc, $WikiDir, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np") + $xd
  $code = Start-Process -FilePath "robocopy.exe" -ArgumentList $rc -Wait -PassThru
  if ($code.ExitCode -gt 7) { Write-Error "robocopy failed: $($code.ExitCode)" }
  Push-Location $WikiDir
  try {
    git add -A
    $st = git status --porcelain
    if (-not $st) { Write-Host "Wiki submodule: nothing to commit."; return }
    git commit -m $CommitMessage
    if ($Push) {
      $branch = git rev-parse --abbrev-ref HEAD
      git push -u origin $branch
    } else {
      Write-Host "Committed in wiki/. Run: git -C wiki push  (parent: git add wiki && commit submodule bump)"
    }
  } finally { Pop-Location }
}

if ([string]::IsNullOrWhiteSpace($Action) -and $env:CI) {
  @'
Set KINOITE_WIKI_ACTION=Init|Sync|GenerateDocs, or pass -Action. In CI, non-interactive only.
'@ | Write-Host
  exit 1
}
if ($Interactive -or $Action -eq "Menu" -or [string]::IsNullOrWhiteSpace($Action)) {
  Write-Host "=== Kinoite wiki ===" -ForegroundColor Cyan
  Write-Host "1) Init submodule  2) Generate _docs only  3) Full Sync  0) exit"
  $c = Read-Host "Choice (default 3)"
  if ([string]::IsNullOrWhiteSpace($c)) { $c = "3" }
  switch -Regex ($c) {
    '^\s*1\s*$' { $Action = "Init" }
    '^\s*2\s*$' { $Action = "GenerateDocs" }
    '^\s*3\s*$' { $Action = "Sync" }
    '^\s*0\s*$' { exit 0 }
    default { $Action = "Sync" }
  }
}
if ($Action -eq "Init") { Set-Location $Root; Invoke-Init; exit 0 }
if ($Action -eq "GenerateDocs") { Set-Location $Root; Invoke-GenerateDocs; exit 0 }
if ($Action -eq "Sync") { Set-Location $Root; Invoke-Sync; exit 0 }
@'
Kinoite-Wiki.ps1  (PowerShell 5.1+)

  -Action Init         Wait for wiki remote, git submodule add wiki
  -Action GenerateDocs  Regenerate wiki-source/_docs from parent repo
  -Action Sync          GenerateDocs + robocopy to wiki/ + git commit (optional -Push)
  -Interactive / Menu   Text menu
  KINOITE_WIKI_ACTION, KINOITE_WIKI_PUSH=1
'@ | Write-Host
exit 1
