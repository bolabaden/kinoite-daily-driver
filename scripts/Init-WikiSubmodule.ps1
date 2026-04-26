# Waits for the GitHub wiki git remote, then runs: git submodule add <wiki.git> wiki
param(
  [string]$RepoRoot = "",
  [int]$PollSeconds = 15,
  [int]$MaxAttempts = 40,
  [string]$WikiUrl = "https://github.com/bolabaden/kinoite-daily-driver.wiki.git"
)

$ErrorActionPreference = "Stop"
$Root = if ($RepoRoot) { $RepoRoot } else { Split-Path $PSScriptRoot -Parent }
Set-Location $Root

if (Test-Path (Join-Path $Root "wiki\.git")) {
  Write-Host "wiki/ already exists. Run: git submodule update --init wiki"
  exit 0
}

Write-Host "Ensure the wiki exists: open https://github.com/bolabaden/kinoite-daily-driver/wiki and create the first page, then Save."
Write-Host "Polling $WikiUrl ..."

for ($i = 0; $i -lt $MaxAttempts; $i++) {
  git ls-remote $WikiUrl 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Wiki remote is reachable."
    git submodule add $WikiUrl wiki
    git submodule update --init wiki
    Write-Host "Done. Next: .\scripts\Sync-WikiSubmodule.ps1"
    exit 0
  }
  Start-Sleep -Seconds $PollSeconds
}

Write-Error "Wiki remote still unavailable after $($MaxAttempts * $PollSeconds)s. Create the first wiki page on GitHub, then re-run this script."
