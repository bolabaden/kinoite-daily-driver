# Fedora Kinoite (WSL2) — workspace

**Phase A:** Kinoite / OSTree userland in **WSL2** with **systemd**, **`rpm-ostree`**, **Flatpak (Flathub)**, and **KDE Plasma** under **WSLg** — not classic Fedora (dnf) as a substitute.

**Workspace root:** your clone path on Windows. Set **`KINOITE_WORKSPACE_ROOT`** to that path so scripts and tools resolve the repo without hard-coding a drive (see [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example)). Example: `KINOITE_WORKSPACE_ROOT=D:\repos\Kinoite`.

## Quick links

| Doc | Purpose |
|-----|---------|
| **[docs/README.md](docs/README.md)** | **Index for all `docs/`** — topic → provisioning table and A–Z topic list |
| [GETTING_STARTED.md](GETTING_STARTED.md) | **Step-by-step** path for any install; **[atomic provisioning](GETTING_STARTED.md#step-3--edit-the-declarative-lists)** (lists + apply) |
| [scripts/README.md](scripts/README.md) | **Single catalog** of `*.ps1` / `*.sh` (import, apply, Windows inventory, WSL helpers) |
| [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) | **Authoritative** Phase A: import, WSL, Plasma, [strategy: why WSL2 first](docs/kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only), [Kinoite vs other Atomic editions](docs/kinoite-wsl2.md#kinoite-and-other-atomic-desktops), rollback |
| [config/wsl.conf.example](config/wsl.conf.example) | Copy into WSL as `/etc/wsl.conf` after import |
| [docs/win11-kinoite-parity-matrix.md](docs/win11-kinoite-parity-matrix.md) | **Win11 ↔ Kinoite** (evidence + `imports/` + category table) |
| [docs/app-mapping.md](docs/app-mapping.md) | Windows → Kinoite app parity (from `winget export`) |
| [kinoite-wsl2 — WSLg runtime bar](docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg) | **Machine “done”:** default user + WSLg + `plasmashell` |
| [kinoite-wsl2 — systemd / rpm-ostree](docs/kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) | **systemd vs `rpm-ostree`** in WSL2 |

*Topic doc → `rpm-ostree` / Flatpak / `host-local`:* **[docs/README.md#topic-docs-and-provisioning-plane](docs/README.md#topic-docs-and-provisioning-plane)**.

## Scripts (order of operations)

1. **Windows (PowerShell, elevated if needed):** [scripts/import-kinoite-rootfs-to-wsl.ps1](scripts/import-kinoite-rootfs-to-wsl.ps1) — `podman pull` → `podman create` → `podman export`; optional **`-DoImport`** when **`KINOITE_WSL_INSTALL_DIR`** (or **`-InstallLocation`**) points at the target NTFS folder (defaults for tarball use **`KINOITE_WORKSPACE_ROOT`** and repo `scratch\` — see script header).
2. **Inside WSL distro:** [scripts/bootstrap-kinoite-wsl2.sh](scripts/bootstrap-kinoite-wsl2.sh) — first `rpm-ostree` / Flathub hints, then [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh) to apply **declarative** [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list) + [config/flatpak](config/flatpak/) (edit lists first; see [GETTING_STARTED](GETTING_STARTED.md#step-3--edit-the-declarative-lists)). Optional: [scripts/install-atomic-provision-service.sh](scripts/install-atomic-provision-service.sh) to enable [config/systemd/kinoite-atomic-ostree.service](config/systemd/kinoite-atomic-ostree.service) (rpm-ostree **layers** on boot; reboot after layering).
3. **Inventory (Windows, optional):** [scripts/export-winget.ps1](scripts/export-winget.ps1), [scripts/run-windows-inventory.ps1](scripts/run-windows-inventory.ps1), and [scripts/list-windows-shortcuts.ps1](scripts/list-windows-shortcuts.ps1) (see [scripts README — The imports directory](scripts/README.md#the-imports-directory)). Outputs land under `imports/` (mostly gitignored; sanitize before `git push`).

## Status

- [WORKSPACE_STATUS.md](WORKSPACE_STATUS.md) — suggested order and pointers.  
- [docs/README.md](docs/README.md) — **doc hub** (index + topic → provisioning + A–Z topic links).  
- [.vscode/tasks.json](.vscode/tasks.json) — *Run Task*: **Kinoite: check markdown links** → [check-md-links.ps1](scripts/check-md-links.ps1) (same as [verify-repo-health.ps1](scripts/verify-repo-health.ps1)).  
- **CI (GitHub):** on push/PR, [.github/workflows/markdown-link-check.yml](.github/workflows/markdown-link-check.yml) runs [check-md-links.ps1](scripts/check-md-links.ps1). Re-run from the **Actions** tab via *Run workflow* (`workflow_dispatch`). [.github/dependabot.yml](.github/dependabot.yml) (weekly) proposes updates to **github-actions** (e.g. `actions/checkout`).

## Legal

Proprietary game assets and Windows-only installers are **your** responsibility; this tree is **documentation + scripts** only.
