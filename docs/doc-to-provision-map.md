# Topic docs → provisioning plane

Maps **`docs/*.md` topics** to how this repo applies them on **Fedora Kinoite**: **`rpm-ostree`** (`config/rpm-ostree/layers.list`), **Flatpak** (`config/flatpak/*.list`), **distrobox/toolbox**, **NetworkManager / `host-local/`**, **fwupd**, **KDE config scripts**, or **manual / Windows**. **No SSID/password in git** — use `host-local/` per [`config/secrets/README.md`](../config/secrets/README.md).

| Doc topic | Declarative in repo | Manual / host-local | Windows-only / VM |
|-----------|---------------------|---------------------|-------------------|
| [app-mapping.md](app-mapping.md) | Flatpak lists + layers comments | Long tail Flathub search | Named Windows apps |
| [atomic-updates-rollback.md](atomic-updates-rollback.md) | — | `rpm-ostree` habits | — |
| [audio-and-display.md](audio-and-display.md) | EasyEffects Flatpak optional (`utils.list`) | PipeWire tuning, UCM | Some DSP |
| [backup-and-sync.md](backup-and-sync.md) | Syncthing, Deja Dup in `media-office.list` | Restic/Borg targets, secrets | OneDrive client |
| [bluetooth-pipewire.md](bluetooth-pipewire.md) | BlueZ in base; **`blueman`** in bare-metal `layers.list` (comment block with print/VPN tier for WSL) | PipeWire BT profiles | — |
| [3d-and-autodesk.md](3d-and-autodesk.md) | Blender Flatpak | Maya Linux if licensed | 3ds Max, many plugins |
| AppImage / FUSE ([`scripts/appimage-fuse-atomic.sh`](../scripts/appimage-fuse-atomic.sh)) | `fuse3` in `layers.list` (bare-metal tier); `check` / `run` subcommands | distrobox; `--appimage-extract-and-run` | — |
| [fedora-dnf-fallback-optional.md](fedora-dnf-fallback-optional.md) | **distrobox** default layer | toolbox same idea | — |
| [filesystems-and-external.md](filesystems-and-external.md) | — | `/etc/fstab`, udisks | NTFS policies |
| [firmware-and-secure-boot.md](firmware-and-secure-boot.md) | — | `fwupd`, BIOS | — |
| [flatpak-overrides.md](flatpak-overrides.md) | — | `flatpak override` per app | — |
| [fonts-and-theming.md](fonts-and-theming.md) | Font layers in `layers.list` (commented) | KDE settings | — |
| [gaming-steam-epic.md](gaming-steam-epic.md) | `gaming.list` | Proton, MangoHud | Anti-cheat |
| Flatpak maintenance ([`config/flatpak/README`](../config/flatpak/README)) | `apply-atomic-provision.sh` (repair+update) | [`scripts/flatpak-maintain.sh`](../scripts/flatpak-maintain.sh) | — |
| [ides-and-terminals.md](ides-and-terminals.md) | `dev.list` | SDKs in distrobox | MSVC |
| [input-and-ime.md](input-and-ime.md) | **`piper`**, **`libratbag-ratbagd`**, **`solaar`** in bare-metal `layers.list`; IBus/Fcitx5 lines still optional there | Fcitx5/IBus enablement per layout | — |
| [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) | `config/kde/`, night-light script | Plasma settings | — |
| [kinoite-vs-atomic-desktops.md](kinoite-vs-atomic-desktops.md) | — | `rpm-ostree rebase` if switching | — |
| [kinoite-wsl2.md](kinoite-wsl2.md) | Same lists; WSL caveats | `config/wsl2/README.md` | — |
| [llm-and-dev-ai.md](llm-and-dev-ai.md) | — | Podman, AppImages, GPU | Some vendor stacks |
| [media-and-homelab.md](media-and-homelab.md) | Jellyfin/etc. via Podman docs | Quadlets | — |
| [microsoft-365-on-linux.md](microsoft-365-on-linux.md) | — | Browser, PWA, KDE accounts | Native Office |
| [migration-baremetal-checklist.md](migration-baremetal-checklist.md) | Apply lists post-install | Disk, firmware | — |
| [networking.md](networking.md) | **`nm-connection-editor`**, **`NetworkManager-openvpn`**, optional `# NetworkManager-openconnect`, **`tailscale`** in bare-metal `layers.list`; `config/network/*.example` | `host-local/` NM profiles (SSID/PSK **never** in git) | — |
| Plasma in WSL ([`scripts/bootstrap-kde-wsl.sh`](../scripts/bootstrap-kde-wsl.sh)) | — | [`scripts/wsl2/launch-kde-gui-wslg.sh`](../scripts/wsl2/launch-kde-gui-wslg.sh), [`config/wsl2/README.md`](../config/wsl2/README.md) | — |
| [podman-and-toolbox.md](podman-and-toolbox.md) | Podman Desktop in `dev.list` | rootless setup | — |
| [power-and-battery.md](power-and-battery.md) | `tlp` layers (commented) | tuned, auto-cpufreq | OEM tools |
| [printing-and-scanning.md](printing-and-scanning.md) | **`cups`**, **`cups-filters`**, **`system-config-printer`**, **`sane-backends`**, **`simple-scan`** in bare-metal `layers.list` (trim on WSL) | PPD quirks, proprietary drivers | — |
| [secrets-ssh-gpg.md](secrets-ssh-gpg.md) | — | `~/.ssh`, GnuPG, gitignored | — |
| [swap-and-zram.md](swap-and-zram.md) | — | `zram-generator`, partitions | WSL: `.wslconfig` |
| [virtualization-windows-vm.md](virtualization-windows-vm.md) | `libvirt`, `virt-manager` (commented) | VM disk images | Hyper-V |
| [wsl-atomic-parity.md](wsl-atomic-parity.md) | — | Expectation setting | — |
| WSLg clipboard / GUI env | — | [config/wsl2/README.md](../config/wsl2/README.md), `profile.d-00-kinoite-wslg-env.sh.example` | — |

**Forgotten?** Reconcile this table with [`win11-kinoite-parity-matrix.md`](win11-kinoite-parity-matrix.md) and your latest `imports/` capture; add **host-local** Flatpak ID lists for one-off apps not worth committing.
