# imports/

Place **sanitized** outputs here:

- `winget-export.json` from `..\scripts\export-winget.ps1` (remove emails, internal hostnames if any).
- Optional: redacted `wsl-dump.txt`, hardware CIM excerpts.

**Do not commit** unsanitized JSON if it contains paths or account identifiers you consider private. `.gitignore` ignores common export names.
