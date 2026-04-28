# Scripts index

**All-in-one menu / chain:** [Kinoite-AIO.ps1](Kinoite-AIO.ps1) (Windows PowerShell) and [kinoite-aio.sh](kinoite-aio.sh) (WSL / Git Bash / native Linux) — same ideas: `-Run Step1,Step2`, env `KINOITE_AIO_RUN`, aliases per [COVERAGE.md](COVERAGE.md).

**`uv` entry (repo root, [pyproject.toml](../pyproject.toml)):** `uv run kinoite-bootstrap-init` — thin wrapper that calls `Kinoite-AIO.ps1` on Windows or `kinoite-aio.sh` elsewhere; extra args pass through. Isolated install: `uvx --refresh --from git+https://github.com/bolabaden/kinoite-daily-driver kinoite-bootstrap-init` — you **must** set `KINOITE_WORKSPACE_ROOT` to a full clone of this repository (so `scripts/` and the AIO scripts exist).

**Doc → automation table:** [COVERAGE.md](COVERAGE.md) (env names, TUI, CI).

WSL2 narrative and troubleshooting: **[config/wsl2/README.md](../config/wsl2/README.md)**. **Install path + topic hub:** **[README.md](../README.md#getting-started-full-install-path)** and **[#topic-docs-and-provisioning-plane](../README.md#topic-docs-and-provisioning-plane)**.

| Group | Script | Role |
|-------|--------|------|
| **Import / WSL bootstrap** | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | Podman → rootfs tar; optional `wsl --import`. **`-Interactive`**; env: `KINOITE_OCI_IMAGE`, `KINOITE_WSL_DO_IMPORT`, `KINOITE_WSL_INSTALL_DIR` |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | Inside distro: Flathub, optional WSLg `profile.d`, points at apply. `menu` / `KINOITE_TUI_CHOICE` / `KINOITE_INTERACTIVE` |
| **Map imports → lists (Windows or Linux)** | [sync_imports_to_provision.py](sync_imports_to_provision.py) | Native-first Flathub list from `imports/winget-export.json` → `host-local/flatpak/kinoite.generated.list`. [sync-imports-to-provision.ps1](sync-imports-to-provision.ps1) wrapper. AIO: **MapImports**. |
| **App config migration (Linux user)** | [migrate-app-config.sh](migrate-app-config.sh) | qBittorrent Flatpak: copy `BT_backup` from Windows paths under WSL. Invoked from [provision.d/40-kinoite-app-config.sh](provision.d/40-kinoite-app-config.sh) after apply. |
| **Provision (Linux)** | [apply-atomic-provision.sh](apply-atomic-provision.sh) | Main declarative apply; merges `host-local/flatpak/*.list`; helpers + **`menu`**. `KINOITE_INTERACTIVE=1` → menu. [provision.d](provision.d/) hooks. |
| **WSL2 / WSLg** | [wsl2/Install-WslHostConfig.ps1](wsl2/Install-WslHostConfig.ps1) | Windows host: writes `%UserProfile%\.wslconfig` from [config/wsl2/README.md](../config/wsl2/README.md) fenced `ini` (default if missing; **`-Force`** + backup). AIO: **`WslConfig`** / **`wslconfig`** |
| | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | Plasma: WSLg, **VcXsrv** (`WSLG_GUI_BACKEND=vcxsrv`), `install-check`, `sddm-note`, TUI `menu` |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | `wsl.exe` + launch script only. **`-Focus`**, **`-Action` Menu\|Focus\|Launch**, `KINOITE_WSL_BASH_INIT` |
| | [wsl2/Kinoite-WindowsPlasmaLogon.ps1](wsl2/Kinoite-WindowsPlasmaLogon.ps1) | Task Scheduler: **`-Register`**, **`-RunSession`**, **`-StopExplorer`** (optional, dangerous) |
| **Windows inventory** | [windows-inventory.ps1](windows-inventory.ps1) | **`-Interactive`** or **`KINOITE_INVENTORY_MODE`**; subsets **`-Winget`**, **`-CimWsl`**, **`-StartMenu`**, **`-Dism`**. UAC: child PS for DISM. |
| **CI / docs** | [check-md-links.ps1](check-md-links.ps1) | Broken relative links. **`-Interactive`**, `KINOITE_MD_LINK_ROOT` (PowerShell 5.1+ in GitHub Actions) |
| | [validate-provision-lists.sh](validate-provision-lists.sh) | `layers.list` + `kinoite.list` line shape (no network; [workflow](../.github/workflows/validate-provision-lists.yml)) |
| **Wiki / Jekyll** | [Kinoite-Wiki.ps1](Kinoite-Wiki.ps1) | **`-Action` Init, GenerateDocs, Sync**; **`-Push`**; no chained `.ps1` |

**Default user after `wsl --import`:** run as **root** once: `useradd -m -s /bin/bash -G wheel YOURNAME` → `passwd YOURNAME` → set `[user] default=YOURNAME` in `/etc/wsl.conf` → `wsl --shutdown`. See [docs/kinoite-wsl2.md](../docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg).

**Classic dnf Fedora in WSL** is **not** Phase A — no helper script; see [kinoite-wsl2 — optional classic Fedora](../docs/kinoite-wsl2.md#optional-classic-fedora-in-wsl).

## The imports directory

Raw Windows inventory under **[`../imports/`](../imports/)**. Run **[windows-inventory.ps1](windows-inventory.ps1)** (with no sub-switches it does winget, CIM+WSL+podman, Start Menu+Desktop, and **DISM**; DISM may request **UAC** on **740** for non-admins). You can commit a short **[`../imports/CAPTURE-MANIFEST.txt`](../imports/CAPTURE-MANIFEST.txt)** to track which files you refreshed (that file also keeps `imports/` in git).

| Pattern | Source |
|---------|--------|
| `winget-export.json` | [windows-inventory.ps1](windows-inventory.ps1) `-Winget` or default all |
| `windows-inventory.txt` | [windows-inventory.ps1](windows-inventory.ps1) `-CimWsl` or all |
| `start-menu-shortcuts.txt` | [windows-inventory.ps1](windows-inventory.ps1) `-StartMenu` (optional **`-StartMenuOutFile`**) |
| `dism-features.txt` | [windows-inventory.ps1](windows-inventory.ps1) **`-Dism`** (WSL/VM/NetFX subset in header, **740** UAC, optional **`-DismPassThru`**) |

## Post-provision hooks

Executable **`provision.d/*.sh`** run after Flatpak + `rpm-ostree` in [apply-atomic-provision.sh](apply-atomic-provision.sh), sorted. Name `NN-name.sh`; idempotent; skip all: `KINOITE_SKIP_PROVISION_HOOKS=1`. WSL vs bare metal: `grep -qi microsoft /proc/version` inside a hook if needed.
