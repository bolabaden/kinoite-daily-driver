# Scripts index

WSL2 narrative and troubleshooting: **[config/wsl2/README.md](../config/wsl2/README.md)**. Doc hub: **[docs/README.md](../docs/README.md)**, **[GETTING_STARTED.md](../GETTING_STARTED.md)**, **[README.md](../README.md#where-to-start)**.

| Group | Script | Role |
|-------|--------|------|
| **Import / WSL bootstrap** | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | Podman → rootfs tar; optional `wsl --import` |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | Inside distro: Flathub, optional WSLg `profile.d`, points at apply |
| **Provision (Linux)** | [apply-atomic-provision.sh](apply-atomic-provision.sh) | Main declarative apply (`config/`, [provision.d](provision.d/)) |
| | [install-atomic-provision-service.sh](install-atomic-provision-service.sh) | Optional systemd: rpm-ostree layers at boot |
| | [provision-locale.sh](provision-locale.sh) | Timezone/keymap from `host-local/locale.env` |
| | [apply-kde-night-light.sh](apply-kde-night-light.sh) | KDE Night Light + schedule (`kwriteconfig6`) |
| | [verify-kde-wsl2-runtime.sh](verify-kde-wsl2-runtime.sh) | WSLg + `plasmashell` bar ([kinoite-wsl2](../docs/kinoite-wsl2.md)) |
| **Tooling** | [appimage-fuse-atomic.sh](appimage-fuse-atomic.sh) | AppImage / FUSE on atomic |
| | [flatpak-maintain.sh](flatpak-maintain.sh) | Repair/update user Flatpaks |
| **WSL2 / WSLg** | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | Plasma on WSLg; subcommands: `hints`, `plasma`, `launch`, `smoke` |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | Start GUI from Windows; **`-Focus`** brings msrdc window forward |
| **Windows inventory** | [export-winget.ps1](export-winget.ps1), [run-windows-inventory.ps1](run-windows-inventory.ps1), [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) | Outputs under `imports/` (gitignored) |
| | [capture-dism-features.ps1](capture-dism-features.ps1) | `dism /Online /Get-Features` → `imports/dism-features.txt` **(comment header, WSL/VM subset, raw list)**; UAC helper on **740** |
| **CI / docs** | [check-md-links.ps1](check-md-links.ps1) ([verify-repo-health.ps1](verify-repo-health.ps1) = same) | Broken relative links in `*.md` — **exit 1** if any missing |

**Default user after `wsl --import`:** run as **root** once: `useradd -m -s /bin/bash -G wheel YOURNAME` → `passwd YOURNAME` → set `[user] default=YOURNAME` in `/etc/wsl.conf` → `wsl --shutdown`. See [docs/kinoite-wsl2.md](../docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg).

**Classic dnf Fedora in WSL** is **not** Phase A — no helper script; see [kinoite-wsl2 — optional classic Fedora](../docs/kinoite-wsl2.md#optional-classic-fedora-in-wsl).

## The imports directory

Raw Windows inventory under **[`../imports/`](../imports/)**. Run **export-winget.ps1**, **run-windows-inventory.ps1**, and **list-windows-shortcuts.ps1**; optional **capture-dism-features.ps1** (DISM may request UAC / 740 on non-admin). You can commit a short **[`../imports/CAPTURE-MANIFEST.txt`](../imports/CAPTURE-MANIFEST.txt)** to track which files you refreshed. **[`.gitkeep`](../imports/.gitkeep)** keeps the folder in git.

| Pattern | Source |
|---------|--------|
| `winget-export.json` | export-winget.ps1 |
| `windows-inventory.txt` | run-windows-inventory.ps1 |
| `start-menu-shortcuts.txt` | list-windows-shortcuts.ps1 `-OutFile` |
| `dism-features.txt` | [capture-dism-features.ps1](capture-dism-features.ps1) (elevates if **740** / not admin) |

## Post-provision hooks

Executable **`provision.d/*.sh`** run after Flatpak + `rpm-ostree` in [apply-atomic-provision.sh](apply-atomic-provision.sh), sorted. Name `NN-name.sh`; idempotent; skip all: `KINOITE_SKIP_PROVISION_HOOKS=1`. WSL vs bare metal: `grep -qi microsoft /proc/version` inside a hook if needed.
