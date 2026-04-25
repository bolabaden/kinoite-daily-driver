# Fedora Kinoite (WSL2) — workspace

**Phase A:** Kinoite / OSTree userland in **WSL2** with **systemd**, **`rpm-ostree`**, **Flatpak (Flathub)**, and **KDE Plasma** under **WSLg** — not classic Fedora (dnf) as a substitute.

**Workspace root:** `G:\workspaces\Kinoite`  
**Optional env (Windows):** `KINOITE_WORKSPACE_ROOT=G:\workspaces\Kinoite`

## Quick links

| Doc | Purpose |
|-----|---------|
| [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) | **Authoritative** import, `wsl.conf`, first boot, `rpm-ostree`, Plasma, rollback, known WSL fragility |
| [docs/strategy-phaseA-kinoite-wsl2.md](docs/strategy-phaseA-kinoite-wsl2.md) | Why Phase A is Kinoite-in-WSL2 only |
| [docs/app-mapping.md](docs/app-mapping.md) | Windows → Kinoite app parity (expand from your `winget export`) |
| [config/wsl.conf.example](config/wsl.conf.example) | Copy into WSL as `/etc/wsl.conf` after import |

## Scripts (order of operations)

1. **Windows (PowerShell, elevated if needed):** [scripts/import-kinoite-rootfs-to-wsl.ps1](scripts/import-kinoite-rootfs-to-wsl.ps1) — `podman pull` → `podman create` → `podman export` → `wsl --import`.
2. **Inside WSL distro:** [scripts/bootstrap-kinoite-wsl2.sh](scripts/bootstrap-kinoite-wsl2.sh) — Flathub, first `rpm-ostree` checks, user hints.
3. **Inventory (Windows):** [scripts/export-winget.ps1](scripts/export-winget.ps1), [scripts/run-windows-inventory.ps1](scripts/run-windows-inventory.ps1) → `imports/` (sanitize before git push).

## Status

See [WORKSPACE_STATUS.md](WORKSPACE_STATUS.md) for execution checklist (plan frontmatter is **not** edited from here).

## Legal

Proprietary game assets and Windows-only installers are **your** responsibility; this tree is **documentation + scripts** only.
