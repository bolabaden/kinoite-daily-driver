# Windows 11 daily driver — how this repo maps the machine

The **Cursor plan** in KotOR (`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`, section **“Windows C: software inventory (this host, 2026-04-25)”** and **“Fedora Kinoite mapping”**) is the **narrative** inventory: app categories, honest parity gaps, and named apps (**ShareX, Steam, Discord, Cloudflare WARP**, plus VPN/DCC/launchers, etc.).

**This** workspace is the **executable** mirror of that spec.

**Authoritative run index:** `imports/CAPTURE-MANIFEST-20260425T172206.txt` (from `scripts/run-full-plan-capture.ps1`, 2026-04-25). That one script produced `winget-export-*.json`, `winget-list-*.txt`, `windows-inventory-*.txt`, `start-menu-shortcuts-*.txt` in `imports/`, Scoop, StartApps, event samples, hardware outline, `wsl-Kinoite-WS2-verify-*.txt`, and `host-tools-*.txt`. Rerun it after **bulk** app changes.

| Evidence type | How to (re)generate | Where it lands |
|---------------|---------------------|----------------|
| **All of the below in one go** | `scripts/run-full-plan-capture.ps1` | `imports/CAPTURE-MANIFEST-<timestamp>.txt` (index) |
| Installed packages (winget) | `export-winget.ps1` (also in full capture) | `imports/winget-export-*.json` (gitignored) |
| `winget list` (plan “Windows C”) | full capture | `imports/winget-list-*.txt` |
| CIM + WSL + podman | `run-windows-inventory.ps1` | `imports/windows-inventory-*.txt` (gitignored) |
| Start Menu + Desktop | `list-windows-shortcuts.ps1` with `-OutFile` (full capture) | `imports/start-menu-shortcuts-*.txt` (gitignored) — may also exist under `%TEMP%` from a manual run |
| Scoop, StartApps, events | `inv-*.ps1` (also in full capture) | `imports/*` per manifest |

**Machine-specific** table rows are in `app-mapping.md` TSV + `imports/`; **PUP/junk ARP** strings stay out of committed **prose** per plan — evidence is in local `winget` output files.

**Parity** for migration: `docs/keep-windows.md` + the full TSV in `app-mapping.md`.
