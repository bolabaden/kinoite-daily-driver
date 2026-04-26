# Fedora Kinoite (WSL2) — workspace

**Phase A:** Kinoite / OSTree userland in **WSL2** with **systemd**, **`rpm-ostree`**, **Flatpak (Flathub)**, and **KDE Plasma** under **WSLg** — not classic Fedora (dnf) as a substitute.

**Workspace root:** your clone path on Windows. Set **`KINOITE_WORKSPACE_ROOT`** to that path so scripts and tools resolve the repo without hard-coding a drive (see [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example)). Example: `KINOITE_WORKSPACE_ROOT=D:\repos\Kinoite`.

**Agents / automation:** start at [GETTING_STARTED.md](GETTING_STARTED.md) (edit `config/rpm-ostree/layers.list` + `config/flatpak/*.list`, then `apply-atomic-provision.sh`). Do not commit raw `imports/` exports (see `.gitignore`).

## Where to start

| Step | Pointer |
|------|---------|
| Read the funnel | [GETTING_STARTED.md](GETTING_STARTED.md) |
| WSL2 / import / Plasma | [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md), [config/wsl2/README.md](config/wsl2/README.md) |
| Declarative packages | [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list), [config/flatpak/](config/flatpak/) |
| Apply on the distro | [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh) |
| Windows → Linux app notes | [docs/app-mapping.md](docs/app-mapping.md), [docs/win11-kinoite-parity-matrix.md](docs/win11-kinoite-parity-matrix.md) |
| Optional Windows inventory | [scripts/README.md — imports](scripts/README.md#the-imports-directory) |
| VM / bare metal phases | [docs/migration-baremetal-checklist.md](docs/migration-baremetal-checklist.md) |
| Doc index | [docs/README.md](docs/README.md) |

**Repo checks:** [scripts/check-md-links.ps1](scripts/check-md-links.ps1) (alias [verify-repo-health.ps1](scripts/verify-repo-health.ps1); *Run Task* in [.vscode/tasks.json](.vscode/tasks.json)). **CI:** [.github/workflows/markdown-link-check.yml](.github/workflows/markdown-link-check.yml).

## Quick links

| Doc | Purpose |
|-----|---------|
| **[docs/README.md](docs/README.md)** | **Index for all `docs/`** — topic → provisioning table and A–Z topic list |
| [GETTING_STARTED.md](GETTING_STARTED.md) | **Step-by-step** path for any install; **[atomic provisioning](GETTING_STARTED.md#step-3--edit-the-declarative-lists)** (lists + apply) |
| [scripts/README.md](scripts/README.md) | **Script catalog** (import, apply, Windows inventory, WSL helpers) |
| [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) | **Authoritative** Phase A: import, WSL, Plasma, rollback |
| [config/wsl2/distro.wsl.conf.example](config/wsl2/distro.wsl.conf.example) | Guest `/etc/wsl.conf` after import |
| [docs/win11-kinoite-parity-matrix.md](docs/win11-kinoite-parity-matrix.md) | **Win11 ↔ Kinoite** (evidence + `imports/` + category table) |
| [docs/app-mapping.md](docs/app-mapping.md) | Windows → Kinoite app parity (from `winget export`) |

*Topic doc → `rpm-ostree` / Flatpak / `host-local`:* **[docs/README.md#topic-docs-and-provisioning-plane](docs/README.md#topic-docs-and-provisioning-plane)**.

## Scripts (order of operations)

1. **Windows (PowerShell, elevated if needed):** [scripts/import-kinoite-rootfs-to-wsl.ps1](scripts/import-kinoite-rootfs-to-wsl.ps1) — `podman pull` → `podman create` → `podman export`; optional **`-DoImport`** when **`KINOITE_WSL_INSTALL_DIR`** (or **`-InstallLocation`**) is set (defaults for tarball: **`KINOITE_WORKSPACE_ROOT`** + `scratch\` — see script header).
2. **Inside WSL distro:** [scripts/bootstrap-kinoite-wsl2.sh](scripts/bootstrap-kinoite-wsl2.sh) — Flathub hint + optional profile.d (`KINOITE_INSTALL_WSLG_PROFILE=1`), then [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh). Optional: [scripts/install-atomic-provision-service.sh](scripts/install-atomic-provision-service.sh).
3. **Inventory (Windows, optional):** [scripts/export-winget.ps1](scripts/export-winget.ps1), [scripts/run-windows-inventory.ps1](scripts/run-windows-inventory.ps1), [scripts/list-windows-shortcuts.ps1](scripts/list-windows-shortcuts.ps1) → `imports/` (mostly gitignored).

## Legal

Proprietary game assets and Windows-only installers are **your** responsibility; this tree is **documentation + scripts** only.
