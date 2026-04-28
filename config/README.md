# Configuration in this tree

## Canonical documentation (where “truth” lives)

User-facing **source** documentation for this project is the Markdown in the **repository root** (`README.md`, `config/`, `docs/`, `scripts/`) and **[`config/wsl2/README.md`](wsl2/README.md)**. The **[`wiki`](https://github.com/bolabaden/kinoite-daily-driver/wiki)** (submodule [`wiki/`](../wiki/)) and **[`wiki-source/`](../wiki-source/)** (Jekyll) exist to publish or mirror the same content; do not treat the wiki or `_docs/` copy alone as a substitute for the main-tree docs when you need **authoritative** wording. Sync: [`scripts/Kinoite-Wiki.ps1`](../scripts/Kinoite-Wiki.ps1) (`-Action GenerateDocs` / `Sync` — see [wiki-source/README.md](../wiki-source/README.md)) and the **GitHub Wiki + Jekyll** paragraph in [README.md](../README.md).

## Declarative surface (versioned in git)

| Surface | Path / mechanism | What stays *outside* (by design) |
|--------|-------------------|----------------------------------|
| `rpm-ostree` packages | [`rpm-ostree/layers.list`](rpm-ostree/layers.list) | Bootstrap partition layout, first user creation |
| Flatpaks (Flathub) | [`flatpak/*.list`](flatpak) — **not** [`overrides.list`](flatpak/overrides.list) | OAuth, store logins, in-app state |
| Flatpak overrides (optional) | [`flatpak/overrides.list`](flatpak/overrides.list) + [OVERRIDES-README](flatpak/OVERRIDES-README.md) | Fine-grained perms (often easier in Flatseal only) |
| Boot-time `rpm-ostree` + copy | `scripts/apply-atomic-provision.sh install-service` + [`systemd/kinoite-atomic-ostree.service`](systemd/kinoite-atomic-ostree.service) | Full WSL2 `rpm-ostree` parity is not the same as bare metal; see [docs/kinoite-wsl2.md](../docs/kinoite-wsl2.md) |
| KDE Night Color (optional) | [`kde/night-color.list`](kde/night-color.list) + [`kde/README.md`](kde/README.md) | — |
| WSL2 / WSLg | Fenced content in `config/wsl2/README.md` + WSL/Windows helper scripts | Long `PATH` / interop policy choices on the **Windows** host |
| `host-local/` (repo root) | `locale.env`, `*.nmconnection` templates, optional `linux-map.*` (see [schemas](schemas/)) | **Secrets**; real PSKs, tokens — never in git |
| `scripts/provision.d/` | `NN-*.sh` hook scripts (executable) | — |
| Windows inventory *mode* | `KINOITE_INVENTORY_MODE` in [`windows-inventory.ps1`](../scripts/windows-inventory.ps1) | Raw `imports/` **evidence** (gitignored) |

List shape checks (no network): [`validate-provision-lists.sh`](../scripts/validate-provision-lists.sh) and [`.github/workflows/validate-provision-lists.yml`](../.github/workflows/validate-provision-lists.yml).

**`rpm-ostree`** — [`config/rpm-ostree/layers.list`](rpm-ostree/layers.list).

**Secrets and network (never commit real credentials)** — this repo is templates only. See also [README — optional gitleaks](../README.md#optional-gitleaks).

| Path | Tracked? | Purpose |
|------|----------|---------|
| Wi-Fi example ([see below](#wi-fi-networkmanager)) | Yes | NetworkManager keyfile **shape** without `psk=` |
| `host-local/` (repo root) | **No** | Rendered `locale.env`, `*.nmconnection`, VPN imports |
| `*.secrets.env` | **No** | Optional env for tools that must not touch git |

## Wi-Fi (NetworkManager)

**Bare metal / full Linux VM — not WSL2.**

1. Copy the example keyfile block below to `host-local/my-wifi.nmconnection` (or keep a local copy of the shape only).
2. Set SSID/PSK only on the host. Import with `nmcli connection import` or copy to `/etc/NetworkManager/system-connections/` (0600, root).
3. `sudo nmcli connection reload`.

Example keyfile (no secrets in git — set PSK only on the host):

```ini
# Example NetworkManager Wi-Fi profile — copy to host-local/ and add secrets there only.
# Replace interface-name with your wlan device (ip link) if needed.
#
# After copy:
#   sudo nmcli connection import type nmconnection file ./host-local/your-name.nmconnection
#   sudo nmcli connection modify your-name wifi-sec.psk 'provisional-password'
#   sudo nmcli connection reload
#   sudo nmcli connection up your-name

[connection]
id=kinoite-wifi-provisional
type=wifi
autoconnect=true

[wifi]
mode=infrastructure
ssid=REPLACE_ME_SSID

[wifi-security]
key-mgmt=wpa-psk
# Never put psk= in git. Set locally with nmcli or nm-connection-editor.

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto
```

See [NetworkManager keyfile format](https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html).

**VPN / other** — keep sources under `host-local/`, permissions 0600 when installed system-wide.

**Optional** — SOPS + age or team vault, outside this tree.

## Workspace root and locale (Windows / agents)

Set on the **Windows** side so scripts and agents resolve this repo without hard-coding a drive. Copy lines into User environment variables, a local `.env` (gitignored), or your shell profile.

```bash
# Primary path (Windows path to this repo)
KINOITE_WORKSPACE_ROOT=D:\repos\Kinoite

# Optional: NTFS directory for `wsl --import` when using scripts/import-kinoite-rootfs-to-wsl.ps1 -DoImport
# KINOITE_WSL_INSTALL_DIR=G:\WSL\Kinoite-WS2

# --- Linux locale (optional; copy to host-local/locale.env for apply-atomic-provision.sh provision-locale) ---
#KINOITE_TIMEZONE=America/Chicago
#KINOITE_LANG=en_US.UTF-8
#KINOITE_KEYMAP=us
#KINOITE_X11_LAYOUT=us
```

*Former `kinoite-workspace-root.env.example` — merged here.*
