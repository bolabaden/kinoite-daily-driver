#Requires -Version 5.1
<#
.SYNOPSIS
  Run markdown relative-link check for the repo.
.DESCRIPTION
  Invokes check-md-links.ps1 (exit 1 on broken relative file targets in *.md).
.EXAMPLE
  PS> ./verify-repo-health.ps1
#>
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$link = Join-Path $here "check-md-links.ps1"
Write-Host "==> $([IO.Path]::GetFileName($link))" -ForegroundColor Cyan
& $link
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "OK: markdown link check passed." -ForegroundColor Green
exit 0
