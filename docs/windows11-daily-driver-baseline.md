# Windows 11 daily driver — how this repo maps the machine

The **executable** mirror of the host is: **`scripts/run-full-plan-capture.ps1`** → **`imports/CAPTURE-MANIFEST-<stamp>.txt`** plus gitignored bulk (`winget-export-*.json`, `registry-uninstall-*.csv`, `appx-packages-*.csv`, `host-locale-network-*.txt`, `run-keys-*.txt`, etc.). Narrative inventory and app categories live in **`docs/app-mapping.md`** and the **row-level** map template **`config/capture/linux-map.template.csv`**.

**Authoritative run index:** the latest **`imports/CAPTURE-MANIFEST-*.txt`** committed or cited in **`WORKSPACE_STATUS.md`** (highest stamp wins after bulk refreshes). Example historical run (2026-04-25): **`winget list`** on the order of hundreds of lines; **Start Menu+Desktop** shortcuts list 800+ lines; plus inventory, Scoop, StartApps, events, hardware outline, WSL verify, `host-tools-*.txt`. Rerun after **bulk** app changes.

| Evidence type | How to (re)generate | Where it lands |
|---------------|---------------------|----------------|
| **All of the below in one go** | `scripts/run-full-plan-capture.ps1` | `imports/CAPTURE-MANIFEST-<timestamp>.txt` (index) |
| Installed packages (winget) | `export-winget.ps1` (also in full capture) | `imports/winget-export-*.json` (gitignored) |
| `winget list` | full capture | `imports/winget-list-*.txt` |
| CIM + WSL + podman | `run-windows-inventory.ps1` | `imports/windows-inventory-*.txt` (gitignored) |
| Start Menu + Desktop | `list-windows-shortcuts.ps1` with `-OutFile` (full capture) | `imports/start-menu-shortcuts-*.txt` (gitignored) |
| Registry ARP / Appx / locale-net / Run / DISM / pnputil | full capture | `imports/*.csv` / `imports/*.txt` per `imports/README.md` |
| Scoop, StartApps, events | `inv-*.ps1` (also in full capture) | `imports/*` per manifest |

**Machine-specific** table rows belong in **`host-local/linux-map.csv`** (from the template) and TSV in `app-mapping.md`; **PUP/junk ARP** strings stay out of committed **prose** — evidence stays in local exports.

**Disposition** for migration: `docs/keep-windows.md` + full mapping in `app-mapping.md` + `config/capture/README.md`.
