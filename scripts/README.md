# Scripts index

WSL2 narrative and troubleshooting: **[config/wsl2/README.md](../config/wsl2/README.md)**. **Install path + topic hub:** **[README.md](../README.md#getting-started-full-install-path)** and **[#topic-docs-and-provisioning-plane](../README.md#topic-docs-and-provisioning-plane)**.

| Group | Script | Role |
|-------|--------|------|
| **Import / WSL bootstrap** | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | Podman → rootfs tar; optional `wsl --import` |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | Inside distro: Flathub, optional WSLg `profile.d`, points at apply |
| **Provision (Linux)** | [apply-atomic-provision.sh](apply-atomic-provision.sh) | Main declarative apply (`sudo` from repo root). First-arg helpers: **`install-service`**, **`provision-locale`** (root), **`kde-night-light`** (desktop user, not root), **`appimage-check`** / **`appimage-run`**, **`help`**. [provision.d](provision.d/) hooks unchanged. |
| **WSL2 / WSLg** | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | Plasma on WSLg; subcommands: `hints`, `plasma`, `launch`, `smoke`, **`verify`** (DISPLAY/WAYLAND + `plasmashell`; see [kinoite-wsl2](../docs/kinoite-wsl2.md)) |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | Start GUI from Windows; **`-Focus`** brings msrdc window forward |
| **Windows inventory** | [windows-inventory.ps1](windows-inventory.ps1) | All-in-one: **winget** export, CIM+WSL inventory, Start Menu list, `dism /Get-Features` (default: run all; use **`-Winget`**, **`-CimWsl`**, **`-StartMenu`**, or **`-Dism`** for subsets; **`-DismPassThru`**; **`-OutDir`**) |
| **CI / docs** | [check-md-links.ps1](check-md-links.ps1) | Broken relative links in `*.md` — **exit 1** if any missing |

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
