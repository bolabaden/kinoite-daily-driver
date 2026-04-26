# Lists markdown files under docs/ with at most -MaxLines non-empty-ish lines (rough stub detector).
param(
    [int] $MaxLines = 35,
    [string] $DocsRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) "docs")
)

Get-ChildItem -LiteralPath $DocsRoot -Filter "*.md" -Recurse -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        $lineCount = (Get-Content -LiteralPath $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
        if ($lineCount -le $MaxLines) {
            [PSCustomObject]@{
                Lines = $lineCount
                Path  = $_.FullName.Substring((Resolve-Path $DocsRoot).Path.Length + 1)
            }
        }
    } |
    Sort-Object Lines, Path
