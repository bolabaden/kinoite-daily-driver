# imports/

Place **raw** inventory outputs here. **The committed “current” filenames** for this host (when an agent has just refreshed) live in **`../WORKSPACE_STATUS.md`**, **`../docs/app-mapping.md`**, and a small run index: **`CAPTURE-MANIFEST-<stamp>.txt`** (produced by **`../scripts/run-full-plan-capture.ps1`**; **unignored** in `.gitignore` so the index can be committed). This folder also holds timestamped `winget-export-*.json`, `windows-inventory-*.txt`, and other large `*.txt` files. **`.gitignore` excludes the usual filename patterns** so a normal `git add` will not pick up bulk exports—verify with `git status` before a push if you add new name patterns.

| File pattern | Source script | Notes |
|--------------|---------------|--------|
| `CAPTURE-MANIFEST-*.txt` | `../scripts/run-full-plan-capture.ps1` | **Committed** list of the run’s `imports/*` files and short notes |
| `winget-export-*.json` | `../scripts/export-winget.ps1` (or full-capture) | Many `not available from any source` / Steam / MSIX lines are **normal** |
| `windows-inventory-*.txt` | `../scripts/run-windows-inventory.ps1` (or full-capture) | CIM OS, `wsl -l -v`, `wsl --version`, **podman** (stderr if VM not up) |
| `registry-uninstall-*.csv` | `../scripts/run-full-plan-capture.ps1` | Add/Remove Programs (ARP) registry export; join with **`config/capture/linux-map.template.csv`** for Kinoite rows |
| `appx-packages-*.csv` | full-capture | Per-user Appx inventory |
| `host-locale-network-*.txt` | full-capture | Culture, timezone, language list, connection profiles; **Wi‑Fi PSK never exported** (only `netsh wlan show profiles` names) |
| `run-keys-*.txt` | full-capture | HKCU/HKLM `Run` values |
| `dism-features-*.txt`, `pnputil-drivers-*.txt` | full-capture | Optional; elevation improves usefulness |
| (optional) hardware / scoop / events / shortcuts | `inv-*.ps1`, `sample-event-logs.ps1`, `list-windows-shortcuts.ps1` | Full-capture writes shortcuts under `imports/` with **`-OutFile`**, not only `%TEMP%` |

**Start Menu / Desktop** shortcuts: standalone **`list-windows-shortcuts.ps1`** defaults to **`%TEMP%`**; **`run-full-plan-capture.ps1`** writes `start-menu-shortcuts-*.txt` under **`imports/`** and lists it in the manifest.

**Plan YAML sync:** if **`kinoite_wsl_workspace_ec9c3c8b.plan.md`** `todos` in KotOR change, run **`../scripts/verify-plan-frontmatter-coverage.ps1`** and refresh **`../docs/plan-frontmatter-coverage.md`** (Appendix C) as needed; inventory files here are unrelated to that check.

**Sanitization for sharing:** strip internal hostnames, e‑mails, or one‑off ARP junk before copying exports out of this machine.
