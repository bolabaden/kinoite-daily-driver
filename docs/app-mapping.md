# Windows → Fedora Kinoite application mapping

This file tracks **this daily-driver** machine: expand from **`winget export`** in `imports/` (see `../scripts/export-winget.ps1`). Exports are **gitignored** — commit only **this** doc, not raw JSON.

**Latest local export (this refresh):** `imports/winget-export-20260425T171938.json` (run `export-winget.ps1` to supersede)  
**Latest full inventory (CIM / WSL / podman):** `imports/windows-inventory-20260425T171943.txt` (run `run-windows-inventory.ps1` to supersede)  
**Rule:** prefer **Flathub**; **toolbox**/**distrobox** for heavy `dnf`; **`rpm-ostree install`** only on a **true** atomic **boot** (see `systemd-rpm-ostree-wsl2-claims.md`).

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

*Source alignment:* `.cursor/.../silverblue_wsl_workspace_ec9c3c8b.plan.md` **§ Fedora Kinoite mapping** (re-run `export-winget.ps1` to diff **your** machine vs condensed rows).
