#Requires -Version 5.1
<#
.SYNOPSIS
  Merge timestamped import files into stable names and delete the stamped sources.

.DESCRIPTION
  For each file under imports\ whose name matches *-yyyyMMddTHHmmss.ext, concatenates
  the contents into imports\<name>.<ext> with ==== BEGIN/END ==== guards, then removes
  the timestamped files. Re-run if new *-Stamp* files accumulate; safe when there are none.

.EXAMPLE
  PS> ./merge-timestamped-imports.ps1
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$imports = Join-Path $root "imports"
$rx = '^(?''base''.+?)-(\d{8}T\d{6})(?''ext''\.\w+)$'

$groups = [ordered]@{}
Get-ChildItem -LiteralPath $imports -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne ".gitkeep" } | ForEach-Object {
    $m = [regex]::Match($_.Name, $rx)
    if (-not $m.Success) { return }
    $key = $m.Groups["base"].Value + $m.Groups["ext"].Value
    if (-not $groups.Contains($key)) { $groups[$key] = [System.Collections.Generic.List[object]]::new() }
    $groups[$key].Add([pscustomobject]@{
        Stamp    = $m.Groups[2].Value
        File     = $_.FullName
        Name     = $_.Name
      })
  }

foreach ($k in $groups.Keys) {
  $g = $groups[$k] | Sort-Object Stamp
  $outPath = Join-Path $imports $k
  $outSb = [System.Text.StringBuilder]::new()
  for ($i = 0; $i -lt $g.Count; $i++) {
    $item = $g[$i]
    [void]$outSb.AppendLine("==== BEGIN: $($item.Name) (stamp $($item.Stamp), part $($i + 1) of $($g.Count)) ====")
    $raw = [System.IO.File]::ReadAllText($item.File, [System.Text.Encoding]::UTF8)
    [void]$outSb.Append($raw)
    if (-not $raw.EndsWith("`n")) { [void]$outSb.AppendLine() }
    [void]$outSb.AppendLine("==== END: $($item.Name) ====")
    if ($i -lt $g.Count - 1) { [void]$outSb.AppendLine() }
  }
  [System.IO.File]::WriteAllText($outPath, $outSb.ToString(), [System.Text.UTF8Encoding]::new($false))
  foreach ($item in $g) { Remove-Item -LiteralPath $item.File -Force -ErrorAction Stop }
  Write-Host ("Merged to {0} ({1} part(s))" -f $k, $g.Count)
}

if ($groups.Count -lt 1) {
  Write-Host "No *-yyyyMMddTHHmmss* files in imports/ to merge."
} else {
  Write-Host "Done. Canonical files are under $imports (no -yyyyMMddTHHmmss- in the name)."
}
