# Plan frontmatter `todos` → workspace artifacts (exhaustive)

**Plan:** `KotOR.js` → `.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md` (all items below were **`completed`** or **`cancelled`** in plan YAML as of the plan revision). This file is the **machine-readable** map for “is every `id` covered in `G:\workspaces\Kinoite`?”

| `id` | Plan status | This workspace (path or note) |
|------|-------------|------------------------------|
| `phaseA-kinoite-wsl2-import` | completed | `docs/kinoite-wsl2.md` + `scripts/import-kinoite-rootfs-to-wsl.ps1` + executed import recorded in `WORKSPACE_STATUS.md` |
| `phaseA-wsl-conf-systemd` | completed | `config/wsl.conf.example` + in-distro `/etc/wsl.conf` note in `kinoite-wsl2.md` |
| `phaseA-rpm-ostree-verify` | completed | `systemd-rpm-ostree-wsl2-claims.md`, `kinoite-wsl2.md` (expected not-booted error for container import) |
| `phaseA-plasma-wslg` | completed | `kinoite-wsl2.md` § Plasma/WSLg, `optional-kde-wsl.md`, `bootstrap-kde-wsl.sh` |
| `research-kinoite-rootfs-sources` | completed | `kinoite-wsl2.md` (Quay pin) + `research/*` |
| `doc-kinoite-wsl2-authoritative` | completed | `docs/kinoite-wsl2.md` |
| `inv-refresh-date` / `inv-os-cim` / `inv-winget-json` | completed | `run-windows-inventory.ps1`, `export-winget.ps1` → `imports/*` (gitignored) |
| `win-c-drive-app-snapshot-2026-04` | completed | `app-mapping.md`, `windows11-daily-driver-baseline.md`, local exports |
| `inv-scoop-list` / `inv-wsl-snapshot` / `inv-startapps-sample` / `inv-reliability-optional` / `inv-event-logs-optional` / `inv-hardware-outline` | completed | `inv-scoop-list.ps1`, `inv-*.ps1`, `sample-event-logs.ps1` |
| `path-resolve-g` / `create-tree` | completed | `G:\workspaces\Kinoite`, `kinoite-workspace-root.env.example` |
| `doc-readme-main` | completed | `README.md` |
| `doc-strategy-phaseA-kinoite-wsl2` | completed | `docs/strategy-phaseA-kinoite-wsl2.md` |
| `doc-virtualbox-kinoite` / `script-virtualbox-snapshots` | completed | `docs/virtualbox-kinoite-fallback.md`, `docs/virtualbox-snapshots-workflow.md` |
| `doc-fallback-classic-fedora-optional` | completed | `docs/fedora-dnf-fallback-optional.md` + `scripts/fedora-dnf-fallback.sh` (not Phase A) |
| `doc-pc-inventory-snapshot` | completed | `docs/this-pc-inventory-template.md` |
| `doc-kinoite-vs-silverblue` | completed | `docs/kinoite-vs-atomic-desktops.md` (title: Kinoite vs **Silverblue**) |
| `doc-wsl-atomic-parity` | completed | `docs/wsl-atomic-parity.md` |
| `doc-app-mapping` | completed | `docs/app-mapping.md` |
| `doc-kde-daily-driver` / `kde-plasma6-widgets` | completed | `docs/kde-daily-driver-recommendations.md` (Plasma 6) |
| `doc-fonts-theming` … `doc-migration-baremetal` | completed | `docs/<topic>.md` per plan ids (see `provisional-configuration-index.md`) |
| `doc-research-workflow` | completed | `docs/research-workflow-tavily-firecrawl.md` + `research/tavily-best-practices-agents-2026-04-25.md` |
| `config-wsl-conf` / `config-flatpak-lists` / `config-shell-skel` | completed | `config/wsl.conf.example`, `config/.wslconfig.example`, `config/flatpak/*.list`, `config/shell/README.md` |
| `script-*` (bootstrap, kde, appimage, distrobox, flathub, first-week) | completed | `scripts/*.sh` / `*.ps1` named in plan (see `README.md` Scripts) |
| `script-bootstrap-fedoraclassic-NOT-PHASE-A` | completed | `fedora-dnf-fallback.sh` (deprecated for Phase A) |
| `security-sanitize` | completed | `.gitignore` (imports) |
| `git-init-optional` | completed | `G:\workspaces\Kinoite` has `.git` |
| `research-pass-external` / `research-firecrawl-pass` | completed | `research/*`, `research/kinoite-wsl2-community-notes.md`, `.firecrawl/README` (credit note) |
| `handoff-user-test` | completed | `WORKSPACE_STATUS.md` + `phases-definition-of-done.md` (Phase A real-world caveats) |
| `doc-ostree-rollback` … `doc-bluetooth-audio` | completed | `atomic-updates-rollback.md` … `bluetooth-pipewire.md` |
| `pre-commit-secrets` | completed | `docs/gitleaks-optional.md` |
| `post-exec-mark-plan` | **cancelled** in plan | Superseded by `WORKSPACE_STATUS.md` (no plan edit) |
| *Added by execution (not separate YAML ids):* | — | `docs/plan-alignment.md`, `phases-definition-of-done.md`, `windows11-daily-driver-baseline.md`, `plan-frontmatter-coverage.md` (this file) |

**Exhaustive definition:** if it appears in the plan’s **todos** table above, there is a **concrete** script, `docs/*.md`, `config/`, or **notes in `WORKSPACE_STATUS.md`** (for host-only state). If an `id` is **`cancelled`**, the replacement artifact is named.
