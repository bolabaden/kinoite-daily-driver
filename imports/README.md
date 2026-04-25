# imports/

Place **raw** inventory outputs here. **The committed “current” filenames** for this host (when an agent has just refreshed) live in **`../WORKSPACE_STATUS.md`** and **`../docs/app-mapping.md`**; this folder holds timestamped `winget-export-*.json` and `windows-inventory-*.txt` files. **`.gitignore` excludes the usual filename patterns** so a normal `git add` will not pick them up—verify with `git status` before a push if you add new name patterns.

| File pattern | Source script | Notes |
|--------------|---------------|--------|
| `winget-export-*.json` | `../scripts/export-winget.ps1` | Many `not available from any source` / Steam / MSIX lines are **normal** |
| `windows-inventory-*.txt` | `../scripts/run-windows-inventory.ps1` | CIM OS, `wsl -l -v`, `wsl --version`, **podman** (stderr if VM not up) |
| (optional) hardware / scoop / events | `inv-*.ps1`, `sample-event-logs.ps1` | as documented in `../docs/this-pc-inventory-template.md` |

**Start Menu / Desktop** shortcuts are **not** stored here by default: `../scripts/list-windows-shortcuts.ps1` writes **`%TEMP%\start-menu-shortcuts-YYYYMMDD.txt`** to avoid multi‑MB files in the tree.

**Sanitization for sharing:** strip internal hostnames, e‑mails, or one‑off ARP junk before copying exports out of this machine.
