# Provisional secrets (never commit real credentials)

This repo stores **templates and docs only**. Real Wi‑Fi PSKs, VPN private keys, and API tokens live in **gitignored** paths on each machine.

## Layout

| Path | Tracked? | Purpose |
|------|----------|---------|
| `config/network/wifi.example.nmconnection` | Yes | NetworkManager keyfile **shape** without `psk=` / certificates |
| `host-local/` (repo root) | **No** (see `.gitignore`) | Your rendered `locale.env`, `*.nmconnection`, VPN imports, etc. |
| `*.secrets.env` | **No** | Optional env files for tools that must not touch git |

## Wi‑Fi (NetworkManager)

1. Copy `config/network/wifi.example.nmconnection` to `host-local/my-wifi.nmconnection` (or another name under `host-local/`).
2. Set SSID and secrets **only on the host** (never push the edited file):
   - `sudo nmcli connection import type nmconnection file /path/to/host-local/my-wifi.nmconnection` **or** copy to `/etc/NetworkManager/system-connections/` with **root:root** and mode **0600**.
   - Then: `sudo nmcli connection modify CONNECTION_NAME wifi-sec.psk 'your-provisional-psk'` (or use `nm-connection-editor`).
3. `sudo nmcli connection reload` and activate the profile.

See also [NetworkManager keyfile format](https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html).

## VPN / other

Import vendor `.ovpn` or NM profiles the same way: keep **source** files under `host-local/`, permissions **0600**, owned by root when placed under `/etc/NetworkManager/`.

## Optional hardening

- [docs/gitleaks-optional.md](../gitleaks-optional.md) — pre-commit secret scanning.
- Team workflows: SOPS + age, or ansible-vault, **outside** this tree.
