# Windows 11 daily driver ↔ Fedora Kinoite (row-level mapping)

This table is the **category disposition contract**: each row states how the repo **automates**, what stays **host-local / manual**, and what remains **Windows-only**. Per-app rows belong in **`config/capture/linux-map.template.csv`** (and machine-specific fills under **`host-local/`**). Cross-links: [keep-windows.md](keep-windows.md), [wsl-atomic-parity.md](wsl-atomic-parity.md).

| Topic | Automated in this repo | Manual / host-local | Windows-only / blocked |
|--------|------------------------|---------------------|-------------------------|
| Base OS + KDE | ISO/install docs; atomic updates | First install, disk layout | — |
| Apps (general) | `config/flatpak/*.list`, `apply-atomic-provision.sh` | OAuth, store logins, licenses | Many anti-cheat titles, some DRM |
| Dev toolchain | Flatpak IDEs + **distrobox**/toolbox for `dnf` | CUDA/vendor SDK pin | MSVC-specific builds |
| Gaming | Steam/Heroic/Lutris/Bottles Flatpaks | Proton tweaks, kernel | EAC/other kernel AC; some launchers |
| 3D / CAD | Blender Flatpak | Commercial CAD | 3ds Max, most Autodesk Windows stacks |
| Chat / collab | Discord Flatpak; Thunderbird | Teams complexity | Full Teams parity |
| M365 | Web + KDE accounts where applicable | Tenant policies | Native Office suite |
| Network Wi‑Fi | NM templates in `config/network/` | PSK in `host-local/` only | — |
| VPN (WARP, PIA, Tailscale) | Docs + optional layers | Keys, `nmcli` import | — |
| Printing / scanning | Optional **rpm-ostree** layers (see `layers.list`) | Driver quirks per printer | Some OEM bundles |
| Audio / BT / PipeWire | Docs; EasyEffects Flatpak optional | UCM firmware | Voicemod-grade routing |
| Backup / sync | Syncthing, Deja Dup Flatpaks | Restic target secrets | OneDrive client parity |
| LLM / local AI | Podman/AppImage docs | GPU passthrough, models | Some Windows-only runtimes |
| Clipboard / ShareX | Flameshot, Spectacle, OBS | Workflow rebuild | ShareX macro/OCR 1:1 |
| Secrets | **Never** in git — `config/secrets/README.md` | SOPS/age optional | — |

**Contract:** every Windows install line item you care about gets **one CSV row** (`source_type`, `linux_plane`, `linux_artifact`, `confidence`). Category gaps here are **backlog rows** to add, not scope opt-outs.

---

## Provisional host snapshot → Fedora knobs (example)

Captured from this workspace’s **Windows 11** shell (build 26200): **Central Time** → `KINOITE_TIMEZONE=America/Chicago`; **en-US** system locale → `KINOITE_LANG=en_US.UTF-8` in `host-local/locale.env` (see `config/locale.env.example`). **Multiple input languages** (e.g. Greek, Arabic, Japanese) → match on Linux with IBus/Fcitx5 + langpacks (`docs/input-and-ime.md`); layer/langpack details live in docs and `layers.list`, not in `rpm-ostree` alone.

**Winget-style apps (sample) → Linux plane**

| Windows (winget / ARP) | Kinoite path |
|------------------------|--------------|
| 7-Zip | `org.7-Zip.7-Zip` in `config/flatpak/utils.list` |
| Firefox | `org.mozilla.firefox` in `config/flatpak/media-office.list` |
| GIMP | `org.gimp.GIMP` (already listed) |
| Notepad++ | `org.kde.kate` or VS Code Flatpak / distrobox editors |
| Podman Desktop | `io.podman_desktop.PodmanDesktop` in `dev.list` |
| Steam + library | `com.valvesoftware.Steam` + Proton (`gaming.list`) |
| TeamViewer | Vendor Linux tarball/RPM (often in **distrobox**); no canonical Flathub ID — check [teamviewer.com/linux](https://www.teamviewer.com/en/download/linux/) |
| LM Studio / local LLM | AppImage or upstream bundle + GPU stack (`scripts/appimage-fuse-atomic.sh`, `docs/llm-and-dev-ai.md`) |
| Temurin JDK | `EclipseAdoptium.Temurin.*` → SDK in **distrobox**, not necessarily Flatpak |
| Maya / Autodesk | Windows-only or licensed Linux build (`docs/3d-and-autodesk.md`) |
| ShareX | Flameshot / Spectacle / OBS (`parity` table above) |

Re-run **`imports/`** capture (`scripts/run-full-plan-capture.ps1`) when the Windows side changes; keep **Wi‑Fi PSK and VPN secrets** only under `host-local/` (`config/secrets/README.md`).
