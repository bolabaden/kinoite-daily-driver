# Migration docs ↔ declarative config (traceability)

This file answers: **where** a Windows-oriented note in [docs/windows-migration.md](../docs/windows-migration.md) is backed by **versioned, apply-script-driven** data vs **KDE/Plasma defaults**, **host-local** data, or **docs-only** (no git-stored “desired state”).

**Installation plane (Kinoite):** `sudo ./scripts/apply-atomic-provision.sh` (from a clone) reads `config/flatpak/*.list` and `config/rpm-ostree/layers.list` (or `/etc/kinoite-provision/…` after `install-service`). There is **no** Windows-side “declarative install” for Linux Flatpaks—only **[`scripts/windows-inventory.ps1`](../scripts/windows-inventory.ps1)** to capture **evidence** into `imports/`.

For the full “what is declarative” mental model, see [README.md — Declarative surface](README.md#declarative-surface-versioned-in-git).

---

## ShareX (and the screenshot/annotation stack)

| Role | In-repo alternative | How it is “declared” / installed |
|------|---------------------|----------------------------------|
| Region / annotate screenshots (closest to ShareX capture) | **Flameshot** | `org.flameshot.Flameshot` in [`flatpak/kinoite.list`](flatpak/kinoite.list) → `apply-atomic-provision.sh` |
| Heavier annotation / sequences | **Ksnip** | `org.ksnip.ksnip` in `kinoite.list` |
| **Spectacle** (KDE) | Shipped with **Plasma** on the **Kinoite** image | **Not** a separate line in `kinoite.list` (desktop default) |
| Recording / streaming | **OBS** | `com.obsproject.Studio` in `kinoite.list` |
| Simple Wayland screencast to file (often paired with **ffmpeg** in docs) | **Kooha** | `io.github.seadve.Kooha` in `kinoite.list` |
| Tweak Flatpak permissions | **Flatseal** | `com.github.tchx84.Flatseal` in `kinoite.list` |

**Not achievable from a list:** ShareX’s macro/OCR pipeline, custom uploaders, and exact hotkey **workflows**—those are [manual / Plasma shortcuts / scripts](README.md) per [windows-migration — ShareX row](../docs/windows-migration.md#named-quick-ref-from-plan).

---

## TSV / quick-ref rows → this repo (high-signal)

| Windows / topic (from migration doc) | Declarative in git | Notes |
|----------------------------------------|-------------------|--------|
| Steam, Heroic, Lutris, Bottles | `com.valvesoftware.Steam`, `com.heroicgameslauncher.hgl`, `net.lutris.Lutris`, `com.usebottles.bottles` | `kinoite.list` |
| Discord | `com.discordapp.Discord` | Optional alt **Vencord** UI: `dev.vencord.Vesktop`—**not** in default list; add to `kinoite.list` or `host-local` if desired |
| GIMP, Blender, OBS | `org.gimp.GIMP`, `org.blender.Blender`, `com.obsproject.Studio` | `kinoite.list` |
| 7-Zip, WinDirStat, media | p7zip/`7zip` RPM, `org.kde.filelight`, VLC/Celluloid | [layers.list](rpm-ostree/layers.list) + `kinoite.list` |
| qBittorrent, FileZilla-class | `org.qbittorrent.qBittorrent` | (No FileZilla ID in list—use `org.filezillaproject.Filezilla` from Flathub if needed) |
| Syncthing, Deja Dup | `me.kozec.syncthingtk`, `org.gnome.DejaDup` | `kinoite.list` |
| LocalSend | `org.localsend.localsend_app` | `kinoite.list` |
| **Tailscale** | `tailscale` | [`layers.list`](rpm-ostree/layers.list) (RPM) |
| **WARP** (Cloudflare) | — | **Docs + vendor** only; not in `layers.list` in this repo—[windows-migration](../docs/windows-migration.md) points at upstream packages; add a layer in **your** fork or use toolbox |
| **PIA** / **OpenVPN** (NM) | `NetworkManager-openvpn` | `layers.list` (generic VPN **client** stack; secrets in `host-local/`) |
| Razer / Logitech stack | `openrazer` not in list; `piper`, `solaar` | `layers.list` |
| EasyEffects (Voicemod-class) | `com.github.wwmm.easyeffects` | `kinoite.list` |
| Podman / Slack / VS Code / Remmina | Flatpak lines in `kinoite.list` | |
| “Proton-GE” / Protontricks | — | **Not** in default `kinoite.list`—add Flathub tools (e.g. `com.github.Matoking.protontricks`) or install via **Steam** / docs |

---

## What “full parity” can and cannot mean

- **Config parity:** Every **major** migration *tooling* row either appears above, in [`kinoite.list`](flatpak/kinoite.list) / [`layers.list`](rpm-ostree/layers.list), is explicitly a **Plasma/ISO default**, or is listed here as **remaining** (below).
- **Product parity with Windows** is **not** a goal for the whole TSV: many rows are **Windows-only**, **license-locked**, or require a **VM** (called out in [windows-migration](../docs/windows-migration.md)).

---

## Remaining gaps (intentional or backlog)

1. **WARP** — document path exists; no `rpm-ostree` line in *this* repo’s `layers.list` (policy/size/host choice).
2. **Vesktop**, **Kdenlive** alt stacks, **FileZilla** — add Flathub IDs to `kinoite.list` if you want them in the default bundle.
3. **Proton-GE / Protontricks** — install path is Steam/FlatHub docs, not pinned in the default list.
4. **`windows-inventory` → `kinoite.list`** — no automatic **merge** from `imports/winget-export.json` into `kinoite.list` (would be a separate tool; by design human-in-the-loop).
5. **Per-user `host-local/linux-map.csv`** — not generated by scripts; schema only in [schemas/linux-map-row.schema.json](schemas/linux-map-row.schema.json).

When you add a Flatpak ID to `kinoite.list`, re-run `apply-atomic-provision.sh` and mention it in a PR so this file stays easy to diff.
