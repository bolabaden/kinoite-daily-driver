# Sync wiki-source/ into the wiki/ submodule, refresh mirrored docs, optionally commit and push.
param(
  [string]$RepoRoot = "",
  [switch]$Push,
  [string]$CommitMessage = "docs(wiki): sync Jekyll site and mirrored markdown"
)

$ErrorActionPreference = "Stop"
$Root = if ($RepoRoot) { $RepoRoot } else { Split-Path $PSScriptRoot -Parent }
$WikiSrc = Join-Path $Root "wiki-source"
$WikiDir = Join-Path $Root "wiki"

if (-not (Test-Path $WikiSrc)) {
  Write-Error "Missing wiki-source/. Clone the full repository."
}

& (Join-Path $WikiSrc "sync-docs-from-parent.ps1") -RepoRoot $Root

if (-not (Test-Path (Join-Path $WikiDir ".git"))) {
  Write-Host @"

Wiki submodule is not initialized yet.

1. Open https://github.com/bolabaden/kinoite-daily-driver/wiki and create the first wiki page (any title), then Save.
2. From repo root run:
     git submodule update --init --recursive wiki
   If wiki/ does not exist yet:
     git submodule add https://github.com/bolabaden/kinoite-daily-driver.wiki.git wiki
3. Re-run this script.

"@
  exit 1
}

# Exclude directory names in the source tree only (wiki-source has no .git).
$xd = @("/XD", ".git", "_site", "vendor", "bundle", ".sass-cache", ".jekyll-cache", "node_modules")
$args = @($WikiSrc, $WikiDir, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np") + $xd
$code = Start-Process -FilePath robocopy.exe -ArgumentList $args -Wait -PassThru
if ($code.ExitCode -gt 7) {
  Write-Error "robocopy failed with exit $($code.ExitCode)"
}

Push-Location $WikiDir
try {
  git add -A
  $st = git status --porcelain
  if (-not $st) {
    Write-Host "Wiki submodule: nothing to commit."
    exit 0
  }
  git commit -m $CommitMessage
  if ($Push) {
    $branch = git rev-parse --abbrev-ref HEAD
    git push -u origin $branch
  } else {
    Write-Host "Committed inside wiki/. Run: git -C wiki push   (then in parent: git add wiki && git commit -m `"chore: bump wiki submodule`")"
  }
} finally {
  Pop-Location
}
