# Start Menu + Desktop shortcuts (matches KotOR.js scripts/list-windows-shortcuts.ps1 pattern)
# Default output: %TEMP%\start-menu-shortcuts-YYYYMMDD.txt — not committed.
param(
  [string]$OutFile = $null
)
$ErrorActionPreference = "SilentlyContinue"
if (-not $OutFile) {
  $OutFile = Join-Path $env:TEMP ("start-menu-shortcuts-{0:yyyyMMdd}.txt" -f (Get-Date))
}
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($root in @(
  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
  "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
  "C:\Users\Public\Desktop",
  [Environment]::GetFolderPath("Desktop")
)) {
  if (Test-Path -LiteralPath $root) {
    [void]$lines.Add("=== $root ===")
    Get-ChildItem -LiteralPath $root -Recurse -Include *.lnk,*.url -File -ErrorAction SilentlyContinue | ForEach-Object { $lines.Add($_.FullName) }
  }
}
$text = $lines -join "`n"
Set-Content -Path $OutFile -Value $text -Encoding utf8
Write-Output "Wrote $($lines.Count) lines to $OutFile"
