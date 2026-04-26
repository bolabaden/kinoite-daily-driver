# KDE Plasma 6 — daily driver notes (Kinoite)

- **Files:** Dolphin; **search:** KRunner (`Alt+Space`).
- **Screenshots:** Spectacle; complement with Flameshot if you need more annotation.
- **Night mode:** Night Color (replaces many third-party “blue light” apps).
- **Widgets (Plasma 6):** add only what you use — **CPU/RAM** monitors, **weather**, and **clipboard** are common; disable heavy **desktop effects** on low-power hosts.

Under **WSLg**, expect **partial** Plasma (often `plasmashell` testing); full session parity → **bare metal / VM**.

## Provisional KDE config in repo (user scope)

Versioned **Plasma / KDE** dotfiles in **`config/kde/`** are **not** applied by `rpm-ostree`. They target **`$XDG_CONFIG_HOME`** (usually `~/.config`) for the **logged-in** Plasma user — the same model as other dotfiles: run the **apply** helper once per user (or after a **fresh** home), not on every `rpm-ostree` boot.

| Topic | Location in repo |
|-------|------------------|
| Night Color + sunrise/sunset + location | [`config/kde/night-light/`](../config/kde/night-light/README.md) + [`scripts/apply-kde-night-light.sh`](../scripts/apply-kde-night-light.sh) |

Run apply scripts **as the desktop user** (not `sudo`), unless you deliberately set `KINOITE_KDE_CONFIG_HOME` to another user’s config path.

*Merged from the former `config/kde/README.md` — that file **removed**.*

## Audio and display

- **PipeWire** is default on Fedora KDE; use **Plasma** audio settings and per-app mixers, plus **EasyEffects** if you need EQ / spatialization (replaces some Windows-only “spatial” drivers).
- **Fractional scaling** on Wayland: Plasma settings → Display; verify per-monitor.
- **HDR / VRR:** depends on GPU stack and session; validate on **bare metal**; WSLg is **not** a reference for gaming display features.

## Bluetooth and PipeWire

- **Blueman** / Plasma Bluetooth applet for pairing. On **bare metal**, **`blueman`** may be listed in `config/rpm-ostree/layers.list` (often with print/VPN tiers — trim on WSL); see the [topic → provision table in docs/README](README.md#topic-docs-and-provisioning-plane).
- **PipeWire** Bluetooth codecs depend on Fedora version and hardware — test headsets/mics before relying on them for calls.

*Merged from the former `docs/audio-and-display.md` (incl. ex-`bluetooth-pipewire.md`) — that file **removed**.*

## Fonts and theming (Kinoite)

- Install fonts with **Flatpak** runtime extensions or system packages on **real** atomic hosts (`rpm-ostree install` font packages) — in WSL, fonts may inherit from **WSLg**; tune **Plasma** system settings for anti-aliasing.
- **GTK/Qt** theme alignment: use **Breeze** defaults first; third-party global themes can break on Wayland — test incrementally.

*Merged from the former `docs/fonts-and-theming.md` — that file **removed**.*

## Microsoft 365 on Linux

- **Teams:** PWA / browser / community Flatpak where available — official support shifts; verify current Microsoft guidance.
- **Office:** browser-first; **LibreOffice** for local files; **OneDrive** via browser or third-party sync clients (evaluate trust model).

*Merged from the former `docs/microsoft-365-on-linux.md` — that file **removed**.*

## Input, IME, and accessibility

- **IBus / Fcitx5:** add input methods in Plasma settings; Wayland compatibility is generally good on Plasma 6.
- **Sticky keys / slow keys:** Plasma accessibility module.
- **Gaming mice:** **Piper** + `libratbag` where supported (may need `rpm-ostree` layer on real Kinoite).

*Merged from the former `docs/input-and-ime.md` — that file **removed**.*

## Printing and scanning

- **CUPS** + **system-config-printer** or KDE printer module.
- **SANE** for scanners; **AirScan** drivers where applicable.
- Network printers: prefer **driverless IPP** when the device supports it.

*Merged from the former `docs/printing-and-scanning.md` — that file **removed**.*
