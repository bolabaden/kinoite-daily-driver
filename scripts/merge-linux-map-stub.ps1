#Requires -Version 5.1
<#
  Stub: merge Windows inventory exports into a linux-map CSV using config/capture/linux-map.template.csv.
  Column semantics: ../docs/app-mapping.md#linux-map-template-row-level-map

  Usage (future): copy template to host-local/linux-map.csv, fill linux_plane / linux_artifact,
  then run a merger that joins imports/registry-uninstall.csv + winget-export.json on keys.

  This stub only validates paths and prints the contract — no destructive writes.
#>
param(
  [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)
$ErrorActionPreference = "Stop"
$template = Join-Path $RepoRoot "config\capture\linux-map.template.csv"
$imports = Join-Path $RepoRoot "imports"

if (-not (Test-Path -LiteralPath $template)) {
  Write-Error "Missing template: $template"
}
Write-Host "Template OK: $template"
Write-Host "Imports dir: $imports (bulk files gitignored)"
Write-Host @"

Next steps:
1. Run scripts/run-full-plan-capture.ps1
2. Copy config/capture/linux-map.template.csv to host-local/linux-map.csv (gitignored)
3. Add one row per Windows source row with linux_plane + linux_artifact
4. Optional: implement Import-Csv / ConvertFrom-Json join here and Export-Csv to host-local/linux-map.merged.csv
"@
