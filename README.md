# Fedora Kinoite (WSL2) — workspace

**Phase A:** Kinoite / OSTree userland in **WSL2** with **systemd**, **`rpm-ostree`**, **Flatpak (Flathub)**, and **KDE Plasma** under **WSLg** — not classic Fedora (dnf) as a substitute.

**Workspace root:** `G:\workspaces\Kinoite`  
**Optional env (Windows):** `KINOITE_WORKSPACE_ROOT=G:\workspaces\Kinoite` (see [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example) for a one-line template).

## Quick links

| Doc | Purpose |
|-----|---------|
| [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) | **Authoritative** import, `wsl.conf`, first boot, Plasma, rollback |
| [docs/systemd-rpm-ostree-wsl2-claims.md](docs/systemd-rpm-ostree-wsl2-claims.md) | **systemd vs `rpm-ostree`** — what WSL2 can and cannot guarantee |
| [docs/strategy-phaseA-kinoite-wsl2.md](docs/strategy-phaseA-kinoite-wsl2.md) | Why Phase A is Kinoite-in-WSL2 only |
| [docs/app-mapping.md](docs/app-mapping.md) | Windows → Kinoite app parity (expand from your `winget export`) |
| [docs/windows11-daily-driver-baseline.md](docs/windows11-daily-driver-baseline.md) | How this repo mirrors the plan’s **this host** inventory (scripts + `imports/`) |
| [config/wsl.conf.example](config/wsl.conf.example) | Copy into WSL as `/etc/wsl.conf` after import |
| [PROVISION](PROVISION) (repo root) | **Executable** path: `config/rpm-ostree/layers.list` + `config/flatpak/*.list` → `scripts/apply-atomic-provision.sh` and optional boot-time `kinoite-atomic-ostree.service` |

## Scripts (order of operations)

1. **Windows (PowerShell, elevated if needed):** [scripts/import-kinoite-rootfs-to-wsl.ps1](scripts/import-kinoite-rootfs-to-wsl.ps1) — `podman pull` → `podman create` → `podman export` → `wsl --import`.
2. **Inside WSL distro:** [scripts/bootstrap-kinoite-wsl2.sh](scripts/bootstrap-kinoite-wsl2.sh) — first `rpm-ostree` / Flathub hints, then [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh) to apply **declarative** [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list) + [config/flatpak](config/flatpak/) (edit lists first; see [PROVISION](PROVISION)). Optional: [scripts/install-atomic-provision-service.sh](scripts/install-atomic-provision-service.sh) to enable [config/systemd/kinoite-atomic-ostree.service](config/systemd/kinoite-atomic-ostree.service) (rpm-ostree **layers** on boot; reboot after layering).
3. **Inventory (Windows):** [scripts/run-full-plan-capture.ps1](scripts/run-full-plan-capture.ps1) runs the winget + inventory + optional exports in order and writes **`imports/CAPTURE-MANIFEST-<stamp>.txt`**. Or run individually: [scripts/export-winget.ps1](scripts/export-winget.ps1), [scripts/run-windows-inventory.ps1](scripts/run-windows-inventory.ps1) → `imports/` (sanitize before git push). **Shortcuts:** [scripts/list-windows-shortcuts.ps1](scripts/list-windows-shortcuts.ps1) (the full-capture script writes under `imports/` with `-OutFile`, not only `%TEMP%`).

## Status

- [WORKSPACE_STATUS.md](WORKSPACE_STATUS.md) — live execution checklist.  
- [docs/provisional-configuration-index.md](docs/provisional-configuration-index.md) — **plan → repo** phase mapping (A/B/C + daily-driver docs).  
- [docs/phases-definition-of-done.md](docs/phases-definition-of-done.md) — repository vs on-machine “phase complete” criteria.  
- [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) — every plan YAML `todos` `id` → file; **Appendix A** = each `doc-*` row; **Appendix B** = `config-*` / `script-*` / `inv-*` / import paths.  
- [docs/plan-stipulated-file-tree.md](docs/plan-stipulated-file-tree.md) — matches the plan’s **Workspace path** file list + env.
- **Exhaustive (repo):** all **completed** frontmatter items in the KotOR plan are mapped here; **Win11** “current” = latest `CAPTURE-MANIFEST-*.txt` plus the files it lists, or the latest `imports/winget-export-*.json` and `windows-inventory-*.txt` named in [WORKSPACE_STATUS](WORKSPACE_STATUS.md) and [app-mapping](docs/app-mapping.md). Re-run **`run-full-plan-capture.ps1`** (or the individual inventory scripts) after bulk app changes. **Phase B/C installs** (VBox / bare metal) remain **on machine** (see [phases-definition-of-done](docs/phases-definition-of-done.md)).

The spec file `silverblue_wsl_workspace_ec9c3c8b.plan.md` in **KotOR.js** now **references this workspace** in its **## Status** section; the **execution log** is still this repo, not a duplicate inside KotOR.

## Legal

Proprietary game assets and Windows-only installers are **your** responsibility; this tree is **documentation + scripts** only.
