# Fedora Kinoite (WSL2) — workspace

**Phase A:** Kinoite / OSTree userland in **WSL2** with **systemd**, **`rpm-ostree`**, **Flatpak (Flathub)**, and **KDE Plasma** under **WSLg** — not classic Fedora (dnf) as a substitute.

**Workspace root:** `G:\workspaces\Kinoite`  
**Optional env (Windows):** `KINOITE_WORKSPACE_ROOT=G:\workspaces\Kinoite` (see [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example) for a one-line template).

## Quick links

| Doc | Purpose |
|-----|---------|
| **[docs/README.md](docs/README.md)** | **Index for all `docs/`** — topic → provisioning table, A–Z topic list, plan/KotOR pointers; use this when the tree feels large |
| [GETTING_STARTED.md](GETTING_STARTED.md) | **Step-by-step** path for any install; **[atomic provisioning](GETTING_STARTED.md#step-3--edit-the-declarative-lists)** (lists + apply) |
| [scripts/README.md](scripts/README.md) | **Single catalog** of `*.ps1` / `*.sh` (import, apply, Windows capture, WSL helpers) |
| [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) | **Authoritative** Phase A: import, WSL, Plasma, [strategy: why WSL2 first](docs/kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only), [Kinoite vs other Atomic editions](docs/kinoite-wsl2.md#kinoite-and-other-atomic-desktops), rollback; **## Spec and the KotOR.js repository** |
| [config/wsl.conf.example](config/wsl.conf.example) | Copy into WSL as `/etc/wsl.conf` after import |
| [docs/win11-kinoite-parity-matrix.md](docs/win11-kinoite-parity-matrix.md) | **Win11 ↔ Kinoite** (evidence + `imports/` *and* category table in **one** page) |
| [docs/provisional-configuration-index.md](docs/provisional-configuration-index.md) | **KotOR plan ↔ this repo in one file:** [coverage matrix](docs/provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) + [Plan-stipulated file tree](docs/provisional-configuration-index.md#plan-stipulated-file-tree) |
| [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) | All **75** `todos` `id` → files (Appendix **C**); re-run [scripts/verify-plan-frontmatter-coverage.ps1](scripts/verify-plan-frontmatter-coverage.ps1) after plan YAML changes, or [scripts/verify-repo-health.ps1](scripts/verify-repo-health.ps1) to also validate markdown file links in one run |
| [docs/app-mapping.md](docs/app-mapping.md) | Windows → Kinoite app parity (from `winget export`) |
| [kinoite-wsl2 — WSLg runtime bar](docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg) | **Machine “done”:** default user + WSLg + `plasmashell` |
| [kinoite-wsl2 — systemd / rpm-ostree](docs/kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) | **systemd vs `rpm-ostree`** in WSL2 |
*Topic doc → `rpm-ostree` / Flatpak / `host-local`:* **[docs/README.md#topic-docs-and-provisioning-plane](docs/README.md#topic-docs-and-provisioning-plane)**. *Former “Win11 baseline only” narrative:* merged into [win11-kinoite-parity-matrix](docs/win11-kinoite-parity-matrix.md).

## Scripts (order of operations)

1. **Windows (PowerShell, elevated if needed):** [scripts/import-kinoite-rootfs-to-wsl.ps1](scripts/import-kinoite-rootfs-to-wsl.ps1) — `podman pull` → `podman create` → `podman export` → `wsl --import`.
2. **Inside WSL distro:** [scripts/bootstrap-kinoite-wsl2.sh](scripts/bootstrap-kinoite-wsl2.sh) — first `rpm-ostree` / Flathub hints, then [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh) to apply **declarative** [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list) + [config/flatpak](config/flatpak/) (edit lists first; see [GETTING_STARTED](GETTING_STARTED.md#step-3--edit-the-declarative-lists)). Optional: [scripts/install-atomic-provision-service.sh](scripts/install-atomic-provision-service.sh) to enable [config/systemd/kinoite-atomic-ostree.service](config/systemd/kinoite-atomic-ostree.service) (rpm-ostree **layers** on boot; reboot after layering).
3. **Inventory (Windows):** [scripts/run-full-plan-capture.ps1](scripts/run-full-plan-capture.ps1) runs the winget + inventory + optional exports in order and writes **`imports/CAPTURE-MANIFEST.txt`**. **`-SkipWinget`** reruns the rest without re-doing `winget export` + `winget list` (see [scripts README — The imports directory](scripts/README.md#the-imports-directory)). After a KotOR plan `todos` change, [scripts/verify-plan-frontmatter-coverage.ps1](scripts/verify-plan-frontmatter-coverage.ps1) checks that every `id` appears in [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md), or use [scripts/verify-repo-health.ps1](scripts/verify-repo-health.ps1) to run the same `id` check and a markdown file-link scan. Or run individually: [scripts/export-winget.ps1](scripts/export-winget.ps1), [scripts/run-windows-inventory.ps1](scripts/run-windows-inventory.ps1) → `imports/` (sanitize before git push). **Shortcuts:** [scripts/list-windows-shortcuts.ps1](scripts/list-windows-shortcuts.ps1) (the full-capture script writes under `imports/` with `-OutFile`, not only `%TEMP%`).

## Status

- [WORKSPACE_STATUS.md](WORKSPACE_STATUS.md) — live execution checklist.  
- [docs/README.md](docs/README.md) — **doc hub** (one page: index + topic → provisioning + A–Z topic links).  
- [.vscode/tasks.json](.vscode/tasks.json) — *Run Task*: **Kinoite: verify repo health (links + plan ids)** → [verify-repo-health.ps1](scripts/verify-repo-health.ps1); **Kinoite: check markdown links (only)** → [check-md-links.ps1](scripts/check-md-links.ps1) (no KotOR plan needed).  
- **CI (GitHub):** on push/PR, [.github/workflows/markdown-link-check.yml](.github/workflows/markdown-link-check.yml) runs [check-md-links.ps1](scripts/check-md-links.ps1) (full [verify-repo-health](scripts/verify-repo-health.ps1) remains local — needs KotOR plan). Re-run from the **Actions** tab via *Run workflow* (same file enables `workflow_dispatch`). [.github/dependabot.yml](.github/dependabot.yml) (weekly) proposes updates to **github-actions** (e.g. `actions/checkout`).  
- [docs/provisional-configuration-index.md](docs/provisional-configuration-index.md) — **plan → repo** phase mapping (A/B/C + daily-driver docs).  
- [provisional-configuration: phases A/B/C “done”](docs/provisional-configuration-index.md#phases-definition-of-done) — repository vs on-machine criteria.  
- [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) — every plan YAML `todos` `id` → file; **Appendix A** = each `doc-*` row; **Appendix B** = `config-*` / `script-*` / `inv-*` / import paths; **Appendix C** = ordered list of all **75** `id`s. After plan edits, run [scripts/verify-plan-frontmatter-coverage.ps1](scripts/verify-plan-frontmatter-coverage.ps1) (or [verify-repo-health.ps1](scripts/verify-repo-health.ps1) to also check markdown links) and refresh **C** if `todos` change.  
- [docs/provisional-configuration-index.md#plan-stipulated-file-tree](docs/provisional-configuration-index.md#plan-stipulated-file-tree) — the plan’s **Workspace path** file list (in the same doc as the phase / matrix).
- **Exhaustive (repo):** all **completed** frontmatter items in the KotOR plan are mapped here; **Win11** “current” = `CAPTURE-MANIFEST.txt` plus the stable paths it lists, or the files named in [WORKSPACE_STATUS](WORKSPACE_STATUS.md) and [app-mapping](docs/app-mapping.md). Re-run **`run-full-plan-capture.ps1`** (or the individual inventory scripts) after bulk app changes. **Phase B/C installs** (VBox / bare metal) remain **on machine** (see [phases: definition of done](docs/provisional-configuration-index.md#phases-definition-of-done)).

The spec file `kinoite_wsl_workspace_ec9c3c8b.plan.md` in **KotOR.js** now **references this workspace** in its **## Status** section; the **execution log** is still this repo, not a duplicate inside KotOR.

## Legal

Proprietary game assets and Windows-only installers are **your** responsibility; this tree is **documentation + scripts** only.
