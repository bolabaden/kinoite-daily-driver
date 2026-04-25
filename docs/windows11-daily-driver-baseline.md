# Windows 11 daily driver — how this repo maps the machine

The **Cursor plan** in KotOR (`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`, section **“Windows C: software inventory (this host, 2026-04-25)”** and **“Fedora Kinoite mapping”**) is the **narrative** inventory: app categories, honest parity gaps, and named apps (**ShareX, Steam, Discord, Cloudflare WARP**, plus VPN/DCC/launchers, etc.).

**This** workspace is the **executable** mirror of that spec.

**Latest run on this host (2026-04-25, ISO-like stamps):** `imports/winget-export-20260425T171938.json`, `imports/windows-inventory-20260425T171943.txt` (gitignored). Supersede by re-running `export-winget.ps1` and `run-windows-inventory.ps1` after large install/uninstall batches.

| Evidence type | How to (re)generate | Where it lands |
|---------------|---------------------|----------------|
| Installed packages (winget) | `scripts/export-winget.ps1` | `imports/winget-export-*.json` (gitignored) |
| CIM + WSL + podman | `scripts/run-windows-inventory.ps1` | `imports/windows-inventory-*.txt` (gitignored) |
| Start Menu + Desktop | `scripts/list-windows-shortcuts.ps1` | default `%TEMP%\start-menu-shortcuts-*.txt` (local only) |
| Scoop, StartApps, events (optional) | `inv-scoop-list.ps1`, `inv-startapps-sample.ps1`, `inv-reliability-sample.ps1`, `sample-event-logs.ps1` | per-script output paths |

**Machine-specific rows** are **not** listed in committed markdown: use the **TSV** in `app-mapping.md` and your **local** `imports/` for diffs. **PUP/junk ARP** names are not copied into git; **audit the host** per plan and `docs/keep-windows.md`.

**Parity** for migration: `docs/keep-windows.md` + the full TSV in `app-mapping.md`.
