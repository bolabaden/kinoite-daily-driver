#Requires -Version 5.1
# Back-compat entry point: "repo health" = relative markdown file link check only.
# See: check-md-links.ps1, .github/workflows/markdown-link-check.yml
$check = Join-Path $PSScriptRoot "check-md-links.ps1"
& $check @args
exit $LASTEXITCODE
