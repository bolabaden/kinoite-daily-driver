#Requires -Version 5.1
<#
.SYNOPSIS
  Run repo-local script checks: markdown file links, KotOR plan id coverage.
.DESCRIPTION
  Invokes check-md-links.ps1 (exit 1 on broken relative file targets) and
  verify-plan-frontmatter-coverage.ps1 (75 ids vs docs/plan-frontmatter-coverage.md).
  Fails on first non-zero exit. Set KOTOR_PLAN_PATH if the plan file is not at the
  default KotOR.js .cursor path.
.EXAMPLE
  PS> ./verify-repo-health.ps1
#>
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$link = Join-Path $here "check-md-links.ps1"
$plan = Join-Path $here "verify-plan-frontmatter-coverage.ps1"
Write-Host "==> $([IO.Path]::GetFileName($link))" -ForegroundColor Cyan
& $link
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "==> $([IO.Path]::GetFileName($plan))" -ForegroundColor Cyan
& $plan
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "OK: repo health checks (links + plan id coverage) passed." -ForegroundColor Green
exit 0
