---
title: Configuration (config/)
---
<div class="sync-banner" markdown="0">
  <strong>Mirrored page.</strong> Generated from the main repo. Relative links may target repository paths -
  use the <a href="https://github.com/bolabaden/kinoite-daily-driver">GitHub tree</a> for navigation.
</div>
# Configuration in this tree

**Flatpaks** — a single file lists Flathub app IDs: [`config/flatpak/kinoite.list`](flatpak/kinoite.list). The apply script also accepts any `*.list` in that folder; we keep one canonical list. [`scripts/apply-atomic-provision.sh`](../scripts/apply-atomic-provision.sh) runs `flatpak install` for each non-comment line, then `flatpak repair` and `update`. Tweak per-app permissions with `com.github.tchx84.Flatseal` (in the list) and Flathub for updates. Avoid untrusted “app store” front-ends for the main workflow.

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

