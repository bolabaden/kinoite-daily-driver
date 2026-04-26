# Documentation index (start here if the repo feels large)

**Three entry points** cover most of what you need:

1. **[GETTING_STARTED.md](../GETTING_STARTED.md)** — one path: edit lists → apply → restart; atomic Kinoite provisioning.
2. **[kinoite-wsl2.md](kinoite-wsl2.md)** — import, `wsl.conf`, Plasma, rolling back; WSL2 narrative in one place.
3. **This file** — maps **topic docs** to `rpm-ostree` / Flatpak / `host-local`, and points at **Windows inventory** docs without opening dozens of paths at random.

**Reminders:** [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md). **Script inventory (PowerShell, bash, WSL helpers):** [scripts/README.md](../scripts/README.md).

| Need | Open |
|------|------|
| Windows → Linux app parity, categories | [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md) (evidence + disposition in one file) |
| VM, bare metal, snapshots, backup | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) |
| systemd vs `rpm-ostree` in WSL2 | [kinoite-wsl2 — honesty](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) |
| Markdown link sanity | [check-md-links.ps1](../scripts/check-md-links.ps1) or [verify-repo-health.ps1](../scripts/verify-repo-health.ps1) |
| Per-topic guides (audio, print, games, …) | **Daily driver topic guides** below — pick one file |

---

## Topic docs and provisioning plane

Maps **`docs/*.md` topics** to how this repo applies them on **Fedora Kinoite**: **`rpm-ostree`** (`config/rpm-ostree/layers.list`), **Flatpak** (`config/flatpak/*.list`), **distrobox/toolbox**, **NetworkManager / `host-local/`**, **fwupd**, **KDE config scripts**, or **manual / Windows**. **No SSID/password in git** — use `host-local/` per [`config/secrets/README.md`](../config/secrets/README.md).

| Doc topic | Declarative in repo | Manual / host-local | Windows-only / VM |
|-----------|---------------------|---------------------|-------------------|
| [app-mapping.md](app-mapping.md) | Flatpak lists + layers comments | Long tail Flathub search | Named Windows apps |
| *Atomic updates / rollback* | — | [migration § OSTree](migration-baremetal-checklist.md#atomic-updates-and-rollback) | — |
| [Audio / display / Bluetooth (KDE daily driver)](kde-daily-driver-recommendations.md#audio-and-display) | EasyEffects Flatpak optional (`utils.list`) | PipeWire tuning, UCM | Some DSP |
| [Backup and sync (migration checklist)](migration-baremetal-checklist.md#backup-and-sync) | Syncthing, Deja Dup in `media-office.list` | Restic/Borg targets, secrets | OneDrive client |
| [Bluetooth / PipeWire (KDE daily driver)](kde-daily-driver-recommendations.md#bluetooth-and-pipewire) | BlueZ in base; **`blueman`** in bare-metal `layers.list` (comment block with print/VPN tier for WSL) | PipeWire BT profiles | — |
| [3D / Autodesk (app-mapping)](app-mapping.md#3d-and-autodesk-dcc) | Blender Flatpak | Maya Linux if licensed | 3ds Max, many plugins |
| AppImage / FUSE ([`scripts/appimage-fuse-atomic.sh`](../scripts/appimage-fuse-atomic.sh)) | `fuse3` in `layers.list` (bare-metal tier); `check` / `run` subcommands | distrobox; `--appimage-extract-and-run` | — |
| *dnf in toolbox; optional classic Fedora in WSL (not Phase A)* | **distrobox** in `layers.list` | [Podman / toolbox (ides-and-terminals)](ides-and-terminals.md#podman-toolbox-and-docker-compatibility) same idea; [kinoite-wsl2 § optional classic dnf in WSL](kinoite-wsl2.md#optional-classic-fedora-in-wsl) | — |
| [Filesystems (migration checklist)](migration-baremetal-checklist.md#filesystems-and-external-drives) | — | `/etc/fstab`, udisks | NTFS policies |
| *Firmware / Secure Boot* | — | [migration § firmware](migration-baremetal-checklist.md#firmware-and-secure-boot) | — |
| [Flatpak overrides](../GETTING_STARTED.md#flatpak-overrides-optional-per-app) | — | `flatpak override` / Flatseal per app | — |
| [Fonts & theming (kde-daily-driver)](kde-daily-driver-recommendations.md#fonts-and-theming-kinoite) | Font layers in `layers.list` (commented) | KDE settings | — |
| [Gaming / Steam / Proton (app-mapping)](app-mapping.md#steam-proton-heroic-and-anti-cheat) | `gaming.list` | Proton, MangoHud | Anti-cheat |
| Flatpak maintenance ([`config/flatpak/README`](../config/flatpak/README)) | `apply-atomic-provision.sh` (repair+update) | [`scripts/flatpak-maintain.sh`](../scripts/flatpak-maintain.sh) | — |
| [ides-and-terminals.md](ides-and-terminals.md) | `dev.list` | SDKs in distrobox | MSVC |
| [Input / IME / accessibility (KDE daily driver)](kde-daily-driver-recommendations.md#input-ime-and-accessibility) | **`piper`**, **`libratbag-ratbagd`**, **`solaar`** in bare-metal `layers.list`; IBus/Fcitx5 lines still optional there | Fcitx5/IBus enablement per layout | — |
| [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md#provisional-kde-config-in-repo-user-scope) | `config/kde/`, [night-light](../config/kde/night-light/README.md) + [apply script](../scripts/apply-kde-night-light.sh) | Plasma settings | — |
| *Kinoite vs GNOME/Sway atomic* | — | [kinoite-wsl2 § other Atomic](kinoite-wsl2.md#kinoite-and-other-atomic-desktops) | `rpm-ostree rebase` if switching |
| [kinoite-wsl2.md](kinoite-wsl2.md) | Same lists; WSL caveats | `config/wsl2/README.md` | — |
| [LLM + media / homelab](llm-and-dev-ai.md) | Jellyfin, Plex, Arr, etc.: see § [Media and homelab](llm-and-dev-ai.md#media-and-homelab-jellyfin-plex-and-arr) | Podman, AppImages, GPU; quadlets | Some vendor stacks |
| [M365 (kde-daily-driver)](kde-daily-driver-recommendations.md#microsoft-365-on-linux) | — | Browser, PWA, KDE accounts | Native Office |
| [migration-baremetal-checklist.md](migration-baremetal-checklist.md) | Apply lists post-install; [Windows 11 as QEMU/KVM guest](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm) | Disk, firmware | — |
| [networking.md](networking.md) | **`nm-connection-editor`**, **`NetworkManager-openvpn`**, optional `# NetworkManager-openconnect`, **`tailscale`** in bare-metal `layers.list`; `config/network/*.example` | `host-local/` NM profiles (SSID/PSK **never** in git) | — |
| Plasma in WSL ([`scripts/bootstrap-kde-wsl.sh`](../scripts/bootstrap-kde-wsl.sh)) | — | [`scripts/wsl2/launch-kde-gui-wslg.sh`](../scripts/wsl2/launch-kde-gui-wslg.sh), [`config/wsl2/README.md`](../config/wsl2/README.md) | — |
| [Podman & toolbox (ides-and-terminals)](ides-and-terminals.md#podman-toolbox-and-docker-compatibility) | Podman Desktop in `dev.list` | rootless setup | — |
| *Power and battery* | `tlp` in `layers.list` (commented) | [migration § power](migration-baremetal-checklist.md#power-and-battery); tuned, auto-cpufreq | OEM tools |
| [Printing and scanning (KDE daily driver)](kde-daily-driver-recommendations.md#printing-and-scanning) | **`cups`**, **`cups-filters`**, **`system-config-printer`**, **`sane-backends`**, **`simple-scan`** in bare-metal `layers.list` (trim on WSL) | PPD quirks, proprietary drivers | — |
| [Secrets / SSH / GPG (networking doc)](networking.md#secrets-ssh-and-gpg) | — | `~/.ssh`, GnuPG, gitignored | — |
| *Swap / zram* | — | [migration § swap](migration-baremetal-checklist.md#swap-and-zram); `zram-generator`, partitions | WSL: `.wslconfig` |
| *WSL vs bare metal (expectations)* | — | [kinoite-wsl2 § parity](kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity) | — |
| WSLg clipboard / GUI env | — | [config/wsl2/README.md](../config/wsl2/README.md), `profile.d-00-kinoite-wslg-env.sh.example` | — |

**Forgotten?** Reconcile with [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md) and your latest `imports/` capture; add **host-local** Flatpak ID lists for one-off apps not worth committing.

---

## Daily driver topic guides (A–Z by filename)

Strategy and platform: [kinoite-wsl2.md](kinoite-wsl2.md) (includes [systemd / rpm-ostree](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty), [Phase A](kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only), [other Atomic](kinoite-wsl2.md#kinoite-and-other-atomic-desktops), [WSL vs bare metal](kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity))

Apps and workflow: [app-mapping.md](app-mapping.md) (incl. [when to keep Windows or a VM](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads)) · [migration — OSTree / rollback](migration-baremetal-checklist.md#atomic-updates-and-rollback)

Hardware and desktop: [Audio / display (KDE daily driver)](kde-daily-driver-recommendations.md#audio-and-display) (incl. [Bluetooth / PipeWire](kde-daily-driver-recommendations.md#bluetooth-and-pipewire)) · [input / IME / accessibility (KDE daily driver)](kde-daily-driver-recommendations.md#input-ime-and-accessibility) · [Fonts & theming (KDE daily driver)](kde-daily-driver-recommendations.md#fonts-and-theming-kinoite) · [power](migration-baremetal-checklist.md#power-and-battery) · [firmware](migration-baremetal-checklist.md#firmware-and-secure-boot) · [swap](migration-baremetal-checklist.md#swap-and-zram) · [Printing and scanning (KDE daily driver)](kde-daily-driver-recommendations.md#printing-and-scanning) · [filesystems and external drives](migration-baremetal-checklist.md#filesystems-and-external-drives)

Network and security: [networking.md](networking.md) (incl. [SSH / GPG / secrets](networking.md#secrets-ssh-and-gpg)) · [GETTING_STARTED — gitleaks optional](../GETTING_STARTED.md#optional-gitleaks)

Dev, games, media, office: [ides — terminals, Podman, toolbox, distrobox](ides-and-terminals.md) · [Gaming / Steam / Proton (app-mapping)](app-mapping.md#steam-proton-heroic-and-anti-cheat) · [3D / Autodesk (app-mapping)](app-mapping.md#3d-and-autodesk-dcc) · [LLM + media / homelab](llm-and-dev-ai.md#media-and-homelab-jellyfin-plex-and-arr) · [Microsoft 365 (KDE daily driver)](kde-daily-driver-recommendations.md#microsoft-365-on-linux) · [Flatpak overrides (GETTING_STARTED)](../GETTING_STARTED.md#flatpak-overrides-optional-per-app) · [kinoite-wsl2 — optional dnf in WSL](kinoite-wsl2.md#optional-classic-fedora-in-wsl)

Plasma: [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) · [kinoite-wsl2 — WSLg runtime bar](kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg)

Phases, VMs, migration: [migration-baremetal-checklist](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) (Kinoite guest VM, ISO, [VirtualBox snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox); former `virtualbox-kinoite-fallback.md` merged) · [Windows guest VM (QEMU/KVM)](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm) · [backup and sync](migration-baremetal-checklist.md#backup-and-sync) · [This PC template](win11-kinoite-parity-matrix.md#this-pc-quick-template)

Meta: [Superseded doc fragments](#archived--superseded-notes)

## External research (keep it boring)

Prefer **primary sources** for install commands and expectations: [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/), [Fedora Docs](https://docs.fedoraproject.org/), [Flathub](https://flathub.org/), [Microsoft WSL](https://learn.microsoft.com/en-us/windows/wsl/). If you use an automated search or crawl tool, keep raw digests **outside** this git tree (personal notes or a scratch directory that is **gitignored**).

## Archived / superseded notes

The repo does **not** use a separate `docs/archive/` tree. Prefer folding short stubs into parent guides (this index or [migration-baremetal-checklist](migration-baremetal-checklist.md)) instead of adding new top-level files.

---

## Redirects (merged docs)

- **Topic docs and provisioning (this file):** [Topic docs and provisioning plane](#topic-docs-and-provisioning-plane) — *former* `doc-to-provision-map.md` **deleted**
- **Win11 host evidence:** [win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts) — *former* `windows11-daily-driver-baseline.md` **deleted**
