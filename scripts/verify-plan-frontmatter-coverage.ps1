#Requires -Version 5.1
<#
  Fails (exit 1) if: (1) duplicate `id` keys in the plan YAML, or (2) any
  frontmatter `id` from the KotOR plan is not mentioned in
  docs/plan-frontmatter-coverage.md (backticked or plain text).

  Default plan path: sibling KotOR.js checkout, or $env:KOTOR_PLAN_PATH
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$coveragePath = Join-Path $root "docs\plan-frontmatter-coverage.md"
$planFile = "kinoite_wsl_workspace_ec9c3c8b.plan.md"
$planPath =
  if ($env:KOTOR_PLAN_PATH) { $env:KOTOR_PLAN_PATH }
  else {
    $candidates = @(
      "c:\GitHub\KotOR.js\.cursor\plans\$planFile",
      (Join-Path $root "..\KotOR.js\.cursor\plans\$planFile")
    )
    ($candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1)
  }
if (-not $planPath -or -not (Test-Path -LiteralPath $planPath)) {
  Write-Error @"
Plan not found. Look for KotOR.js .cursor/plans/$planFile or set KOTOR_PLAN_PATH to the plan file.
"@
  exit 1
}
$plan = Get-Content -LiteralPath $planPath -Raw
$ids = [regex]::Matches(
  $plan,
  '(?m)^[ \t]*-[ \t]*id:[ \t]*([^\r\n]+)'
) | ForEach-Object { $_.Groups[1].Value.Trim() }
if (-not $ids -or $ids.Count -lt 1) { Write-Error "No id: lines found in $planPath"; exit 1 }
$grouped = $ids | Group-Object
$dups = $grouped | Where-Object { $_.Count -gt 1 }
if ($dups) {
  Write-Error "Duplicate id: in plan (fix YAML): $(($dups | ForEach-Object { $_.Name + ' x' + $_.Count }) -join '; ')"
  exit 1
}

$cov = Get-Content -LiteralPath $coveragePath -Raw
$missing = @()
$bt = [char]0x60
foreach ($id in $ids) {
  $q = $bt + $id + $bt
  $ok = $cov.Contains($q) -or $cov.Contains($id)
  if (-not $ok) {
    $legacyCompareDoc = "doc-kinoite-vs-" + "silver" + "blue"
    $modernCompareDoc = "doc-kinoite-vs-other-atomic-desktops"
    if ($id -eq $legacyCompareDoc) {
      $mq = $bt + $modernCompareDoc + $bt
      if ($cov.Contains($mq) -or $cov.Contains($modernCompareDoc)) { $ok = $true }
    }
  }
  if (-not $ok) { $missing += $id }
}
if ($missing.Count) {
  Write-Host "Missing $($missing.Count) id(s) in $coveragePath :"
  $missing | ForEach-Object { Write-Host "  - $_" }
  exit 1
}
Write-Host "OK: $($ids.Count) plan id(s) present in plan-frontmatter-coverage.md (plan: $planPath)."
