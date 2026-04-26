# Windows → Fedora Kinoite application mapping

This file tracks **this daily-driver** machine: expand from **`winget export`** in `imports/` (see `../scripts/export-winget.ps1`). Exports are **gitignored** — commit only **this** doc, not raw JSON.

**Inventory (optional):** run [`../scripts/export-winget.ps1`](../scripts/export-winget.ps1) and [`../scripts/run-windows-inventory.ps1`](../scripts/run-windows-inventory.ps1) from the repo on Windows; outputs go under `imports/` (mostly gitignored — see [scripts README — The imports directory](../scripts/README.md#the-imports-directory)). Optionally [`../scripts/list-windows-shortcuts.ps1`](../scripts/list-windows-shortcuts.ps1) **`-OutFile ..\imports\start-menu-shortcuts.txt`**. Update optional local `imports/CAPTURE-MANIFEST.txt` if you keep an index. Re-run after **bulk** app changes.

**This host (latest in `imports/`; sizes drift with re-runs):** see local `imports/CAPTURE-MANIFEST.txt` for any index you maintain; older capture files may still exist on disk from prior runs.  
**Rule:** prefer **Flathub**; **toolbox**/**distrobox** for heavy `dnf`; **`rpm-ostree install`** only on a **true** atomic **boot** (see [kinoite-wsl2 — honesty](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty)).

## When to keep Windows (or a VM) for these workloads

Honest **“no Kinoite parity / keep Win32 or a VM”** list for a **power-user Windows 11** host (DCC, games, creative, Razer/Vendor stacks). The **TSV and quick ref below** are the per-app view; this section is the **principle** list. See also **[kinoite-wsl2.md](kinoite-wsl2.md)** and **[win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md)**. *(Merged from the former `docs/keep-windows.md` — that file **removed**.)*

### Always / usually Windows-only (for this class of machine)

- **Autodesk 3ds Max** (e.g. 2026) + many Max-only plugins, **USD/Arnold/Substance** stacks where licenses are **Windows-locked** — use **Kinoite** for **Blender**/**Maya for Linux** where licensed; else **this OS** or a **dedicated Windows VM** with **GPU** passthrough.
- **Kernel-level or invasive anti-cheat** multiplayer (varies by title) — Proton/Steam on Linux is **not** a promise; keep **retail Windows** for those games.
- **Windows-only DAW/DSP in Voicemod-grade** routing (deep virtual cables and vendor ASIO stacks) — approximate with **PipeWire**/**EasyEffects**/**Carla** on Kinoite, not bit-identical.
- **ShareX-grade** automation: OCR pipelines, custom uploaders, region workflows — **no single** Linux app; rebuild with **Plasma** shortcuts, **Flameshot**, **Spectacle**, **Ksnip**, **OBS**, **FFmpeg** scripts.
- **OEM lighting / RGB** (e.g. some Razer/Logitech **proprietary** services) — **openrazer**+**Polychromatic**, **Piper**+**Solaar** cover **a subset**; exotic firmware features may need **Windows**.
- **Apple** desktop: **iTunes** library management, **iCloud** shell integration, **iCloud for Outlook** — on Linux: **web**, **Akonadi**/**DAV**, not the same **Explorer**-integrated experience.
- **Microsoft-first** or **MSIX-locked** apps (**Clipchamp, Phone Link, some Copilot/Edge assist**) — use **KDE**/**Chromium**/**web**; **1:1** to Windows UWP/Edge-only features: **no**.
- **VS Build / MSVC**-centric pipelines — **use Linux toolchains in toolbox**; **not** a substitute for every **.NET WPF/Win** workflow.
- **Bluesky Frame Rate Converter** and similar **vendor-specific Windows drivers** — on Linux, **MangoHud**/**KWin**/**Mesa** tuning; **N/A** same FRC.
- **DTS Headphone:X**-style **vendor spatial** — Linux **HRTF**/**EasyEffects**; different branding and licensing.
- **Bogus / PUP / joke ARP entries** — **remove in Windows**; do **not** try to “migrate” a junk installer to Linux. See plan note: **ephemeral/unknown** ARP line → **audit host**.

### Edge cases: Windows VM on Linux (optional)

- **3ds** only, **DCC** that is **licensed to Windows** — a **KVM/VirtualBox** or **QEMU** Windows guest on the **Kinoite** host (when on **bare metal** with GPU) can be **tighter** than dual-boot context-switching. See [migration-baremetal — Windows 11 guest VM](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm), [Kinoite guest VM / ISO (Phase B or C)](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c).
- **KOTOR modding** with legacy **.exe** tools: **Wine/VM** or the **KotOR.js** stack for cross-platform work.

### When you can *drop* Windows (longer arc)

- **All** you need is in **Flathub + Firefox + dev containers + Steam/Proton**-friendly titles, **no** AC-blocked games, **no** Max/Win-only CAD, **no** iTunes lock-in — then **Kinoite bare metal** (or a **clean** WSL/VM **lab**) is enough; keep this list as a **guilt-free** checklist, not a moral imperative.

Update this section after **big** **winget** changes (see `exports` + [This PC quick template](win11-kinoite-parity-matrix.md#this-pc-quick-template)).

## 3D and Autodesk (DCC)

- **Blender** — practical native Linux path for general 3D via **Flatpak** (`org.blender.Blender` in the [TSV](#tsv-plan-master-table--import-into-a-spreadsheet) below).
- **Autodesk Maya** — **Linux** build exists; licensing and GPU requirements are **release-specific**; validate against your subscription.
- **3ds Max** — **Windows-only**; use a [Windows 11 guest VM on Linux](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm) or the [keep-Windows/VM](#when-to-keep-windows-or-a-vm-for-these-workloads) principles above.

*Merged from the former `docs/3d-and-autodesk.md` — that file **removed**.*

## Steam, Proton, Heroic, and anti-cheat

- **Steam** Flatpak + **Proton**; add **Proton-GE** Flatpak compatibility tool when needed.
- **Heroic** for Epic/GOG; **Lutris** for scripted installs.
- **Easy Anti-Cheat / kernel-level anti-cheat** may block Linux — check **ProtonDB** and game-specific news.
- **RPM Fusion** codecs may be needed for cutscene playback on some titles (real Kinoite host).

*Merged from the former `docs/gaming-steam-epic.md` — that file **removed**.*

## Named quick ref (from plan)

| You asked | Kinoite-first | Almost identical? |
|------------|---------------|-------------------|
| **ShareX** | `org.flameshot.Flameshot`, **Spectacle**, **OBS**, `org.ksnip.ksnip`, Kooha+ffmpeg | **No** — rebuild shortcuts/workflows (OCR, uploaders). |
| **Steam** | `com.valvesoftware.Steam` + Proton-GE add-on, Bottles, Lutris | Often **yes** in-game; **EAC/kernel AC** may block Linux. |
| **Discord** | `com.discordapp.Discord` or `dev.vencord.Vesktop` | **~** — Rich Presence / screen-share test per GPU. |
| **Cloudflare WARP** | vendor repo → `cloudflare-warp` + `warp-cli` (atomic: reboot after layer) | **~** — one primary tunnel; avoid stacked VPN debug. |

## TSV (plan master table — import into a spreadsheet)

Columns: `windows` → `kinoite_first` → `parity` (tab-separated).

```tsv
windows	kinoite_first	parity
ShareX	Flameshot Flatpak, Spectacle KDE, Kooha+FFmpeg, Obs	No 1:1 macro/OCR
Steam+library	com.valvesoftware.Steam, Proton, Bottles, Lutris	Gameplay often same; anti-cheat may block
Epic/EA/GOG/Amazon	Heroic, Lutris, Bottles, native GOG sometimes	Login UX differs
Discord	com.discordapp.Discord or Vesktop	~
Cloudflare WARP	Official repo + warp-cli	~; one of WARP/PIA/Tail for MTU debug
Tailscale	tailscale, KDE tray	High
PIA OpenVPN	PIA Linux or NM WireGuard	High
GIMP Blender OBS	org.gimp.GIMP org.blender.Blender com.obsproject.Studio	High
3ds Max 2026	No native	VM/Win or Blender
Maya 2027 stack	Autodesk Maya for Linux if licensed; plugins per matrix	Close vs 3ds; license/GPU
Cursor VS Code Windsurf	Official Linux, VSCodium, Flathub Code	~; AI tied to vendor
7-Zip WinMerge HxD N++	p7zip Ark, Meld/KDiff3, Okteta, Kate	~
WinDirStat PotPlayer K-Lite	Filelight, MPV/Celluloid/VLC, FFmpeg stack	Codec pack not 1:1
Jellyfin Plex arr Prowlarr	Podman quadlets or Flathub Jellyfin, arr upstream	High
qBittorrent FileZilla	Flathub	High
mitmproxy HTTP gcloud	Toolbox, Caido/Zap alts	~
Docker Podman Desktop	Podman rootless, Podman Desktop	~
Node Go Python NET Rust	JDKxN	toolbox mise asdf, minimize ostree layer
Razer Logitech Voicemod	openrazer, Piper+Solaar, EasyEffects	~ not same app
SoundSwitch f.lux SuperF4 Lasso	Plasma audio Night Color, xkill, chrt/ionice	Lasso has no Linux clone
Cheat Engine	GameConqueror scanmem	~
TeamViewer RustDesk	Rustdesk Flatpak, teamviewer rpm (TOS)	Pick one
mstsc	KRDC Remmina xfreerdp	~
LocalSend	org.localsend.localsend_app	High
EventGhost	Plasma khotkeys systemd user units keyd	~
SSHFS WinFsp	sshfs Dolphin sftp	High
XPipe Linux	ssh tooling Dolphin Konsole	~
VapSynth K-Lite pipeline	FFmpeg chain in box	Aegisub as needed
Malwarebytes DefenderUI	ClamAV firewalld	Not 1:1 EDR
RuneLite SWTOR GOG	Lutris Proton ProtonDB	EAC fail keep Windows
iCloud iTunes Teams	Mostly web, KDE online accounts, Teams PWA/Flatpak	No desktop iTunes parity
Bun yq Kaitai Prowlarr	bun in box, Prowlarr in Podman	High for servers
LM Studio AnythingLLM Ollama	Podman/AppImage, vendor Linux builds	~ GPU
Kotor Tool legacy	Wine/VM, KotOR.js for modern dev	Align with this repo
Bluesky FRC	Bluesky Windows driver not on Linux; MangoHud MESA	Not same
Jellyfin Plex Stremio	Flathub and/or Podman	Same upstream
Copilot Claude Codex	Web, AppImage, VS+Continue	~
Chrome Edge Firefox Opera GX	Chrome Firefox Vivaldi/Chromium	Edge sync and some extensions N/A
AMD Link DVR DTS	Plasma MESA OBS VAAPI EasyEffects	DTS spatial N/A; approx with plugins
KDE Kinoite default	Dolphin Spectacle Ark Filelight	Replaces part of Explorer+ShareX stack
OpenOffice	LibreOffice	~
NSIS WiX GitHub Desktop build flows	toolbox makensis same git flows	Build parity not same GUI
Jade Empire GOG	Heroic Lutris Proton	~
Prowlarr MSIX	same in Podman	High
Windows SDK VS Build toolbx dnf install dotnet gcc	Not MSVC
Ephemeral ARP entry	Unverified: remove if PUP	N/A
Clipchamp Phone Link Edge Game Assist	Kdenlive OBS KDE Connect	~
PhysX redist	Proton bundles	N/A
```

*Source alignment:* re-run **`export-winget.ps1`** to diff **your** machine vs condensed TSV rows.

## Linux-map (row-level map)

For per-row Windows → Kinoite disposition beyond the TSV, keep a CSV under **`host-local/`** (gitignored) with columns such as:

| Column | Meaning |
|--------|---------|
| `source_type` | `winget`, `registry_uninstall`, `appx`, `shortcut`, `manual`, … |
| `source_key` | Optional stable id (winget id, registry `PSChildName`, etc.) |
| `source_name` | Human-readable name from export |
| `source_version` | Version string if known |
| `publisher` | Publisher when known |
| `linux_plane` | `rpm-ostree`, `flatpak`, `distrobox`, `toolbox`, `podman`, `appimage`, `manual`, `windows_only` |
| `linux_artifact` | Package name, Flatpak ref, container image, or doc pointer |
| `confidence` | `high` / `med` / `low` |
| `notes` | Edge cases, licensing, metal-only, WSL caveat |

**Inputs** can come from [`imports/`](../scripts/README.md#the-imports-directory) (`winget-export.json`, inventory text, etc.). Merge into repo lists only after redacting machine-specific secrets.

*Merged from the former `config/capture/README.md` — that file **removed**.*
