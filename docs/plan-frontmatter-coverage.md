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
| `inv-refresh-date` / `inv-os-cim` / `inv-winget-json` | completed | `run-windows-inventory.ps1` + `export-winget.ps1` → `imports/*` (gitignored); or **`run-full-plan-capture.ps1`** (all of the above + `winget list`, Start Menu, optional logs; **`CAPTURE-MANIFEST-*.txt`** unignored) |
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
| `doc-fonts-theming` … `doc-migration-baremetal` | completed | See **Appendix A** (one row per `id`); [provisional-configuration-index.md](provisional-configuration-index.md) |
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
| `post-exec-mark-plan` | completed in plan (KotOR) | `WORKSPACE_STATUS.md` + KotOR plan **Status** (`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`) + `AGENTS.md` (full-capture pointer) |
| *Added by execution (not separate YAML ids):* | — | `scripts/run-full-plan-capture.ps1` (orchestrates all host imports), committed `imports/CAPTURE-MANIFEST-*.txt`, `docs/plan-alignment.md`, `phases-definition-of-done.md`, `windows11-daily-driver-baseline.md`, `plan-frontmatter-coverage.md` (this file) |

**Exhaustive definition:** if it appears in the plan’s **todos** table above, there is a **concrete** script, `docs/*.md`, `config/`, or **notes in `WORKSPACE_STATUS.md`** (for host-only state). If an `id` is **`cancelled`**, the replacement artifact is named.

---

## Appendix A — every `doc-*` and related `kde-` / `pre-commit` id → file

| `id` | `docs/…` or note |
|------|------------------|
| `doc-kinoite-wsl2-authoritative` | [kinoite-wsl2.md](kinoite-wsl2.md) |
| `doc-readme-main` | [README.md](../README.md) |
| `doc-strategy-phaseA-kinoite-wsl2` | [strategy-phaseA-kinoite-wsl2.md](strategy-phaseA-kinoite-wsl2.md) |
| `doc-virtualbox-kinoite` | [virtualbox-kinoite-fallback.md](virtualbox-kinoite-fallback.md) |
| `doc-fallback-classic-fedora-optional` | [fedora-dnf-fallback-optional.md](fedora-dnf-fallback-optional.md) |
| `doc-pc-inventory-snapshot` | [this-pc-inventory-template.md](this-pc-inventory-template.md) |
| `doc-kinoite-vs-silverblue` | [kinoite-vs-atomic-desktops.md](kinoite-vs-atomic-desktops.md) |
| `doc-wsl-atomic-parity` | [wsl-atomic-parity.md](wsl-atomic-parity.md) |
| `doc-app-mapping` | [app-mapping.md](app-mapping.md) |
| `doc-kde-daily-driver` | [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) |
| `doc-fonts-theming` | [fonts-and-theming.md](fonts-and-theming.md) |
| `doc-audio-display` | [audio-and-display.md](audio-and-display.md) |
| `doc-input-accessibility` | [input-and-ime.md](input-and-ime.md) |
| `doc-printing-scanning` | [printing-and-scanning.md](printing-and-scanning.md) |
| `doc-filesystems` | [filesystems-and-external.md](filesystems-and-external.md) |
| `doc-backup-sync` | [backup-and-sync.md](backup-and-sync.md) |
| `doc-appimage-fuse` | [appimage-on-atomic.md](appimage-on-atomic.md) |
| `doc-gear-lever` | [gear-lever.md](gear-lever.md) |
| `doc-podman-docker` | [podman-and-toolbox.md](podman-and-toolbox.md) |
| `doc-secrets-ssh` | [secrets-ssh-gpg.md](secrets-ssh-gpg.md) |
| `doc-3d-autodesk` | [3d-and-autodesk.md](3d-and-autodesk.md) |
| `doc-gaming` | [gaming-steam-epic.md](gaming-steam-epic.md) |
| `doc-network-vpn` | [networking.md](networking.md) |
| `doc-media-homelab` | [media-and-homelab.md](media-and-homelab.md) |
| `doc-llm-local` | [llm-and-dev-ai.md](llm-and-dev-ai.md) |
| `doc-ides` | [ides-and-terminals.md](ides-and-terminals.md) |
| `doc-m365` | [microsoft-365-on-linux.md](microsoft-365-on-linux.md) |
| `doc-optional-kde-wsl` | [optional-kde-wsl.md](optional-kde-wsl.md) |
| `doc-migration-baremetal` | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) |
| *Plan **Workspace** tree* — `keep-windows` *(no separate YAML `doc-` `id`)* | [keep-windows.md](keep-windows.md) |
| *`win-c-drive-app-snapshot-2026-04` + Win11 host mirror* | [app-mapping.md](app-mapping.md) + [windows11-daily-driver-baseline.md](windows11-daily-driver-baseline.md) + `imports/*` (see [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md)) |
| `doc-research-workflow` | [research-workflow-tavily-firecrawl.md](research-workflow-tavily-firecrawl.md) + [../research/tavily-best-practices-agents-2026-04-25.md](../research/tavily-best-practices-agents-2026-04-25.md) |
| `doc-ostree-rollback` | [atomic-updates-rollback.md](atomic-updates-rollback.md) |
| `doc-fwupd-secureboot` | [firmware-and-secure-boot.md](firmware-and-secure-boot.md) |
| `doc-flatpak-overrides` | [flatpak-overrides.md](flatpak-overrides.md) |
| `doc-power-battery` | [power-and-battery.md](power-and-battery.md) |
| `doc-virtualization-windows-vm` | [virtualization-windows-vm.md](virtualization-windows-vm.md) |
| `doc-swap-zram` | [swap-and-zram.md](swap-and-zram.md) |
| `doc-clipboard-wslg` | [wslg-clipboard-gui.md](wslg-clipboard-gui.md) |
| `doc-bluetooth-audio` | [bluetooth-pipewire.md](bluetooth-pipewire.md) |
| `kde-plasma6-widgets` | [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) (Plasma 6) |
| `pre-commit-secrets` | [gitleaks-optional.md](gitleaks-optional.md) |
| `script-virtualbox-snapshots` | [virtualbox-snapshots-workflow.md](virtualbox-snapshots-workflow.md) (pairs with VBox Kinoite doc) |

**See also (plan file names):** [plan-stipulated-file-tree.md](plan-stipulated-file-tree.md) (verbatim **Workspace path** tree).

---

## Appendix B — `config-*`, `script-*`, and `inv-*` / `phaseA-*` (exact paths)

| Plan `id` | Artifact |
|-----------|----------|
| `config-wsl-conf` | [../config/wsl.conf.example](../config/wsl.conf.example) |
| *Host* `%UserProfile%\.wslconfig` | [../config/.wslconfig.example](../config/.wslconfig.example) |
| `config-flatpak-lists` | [../config/flatpak/desktop-core.list](../config/flatpak/desktop-core.list), [../config/flatpak/dev.list](../config/flatpak/dev.list), [../config/flatpak/gaming.list](../config/flatpak/gaming.list) |
| `config-shell-skel` | [../config/shell/README.md](../config/shell/README.md) |
| `path-resolve-g` / `create-tree` | [../kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) (repo path convention) |
| `script-bootstrap-kinoite-wsl2` | [../scripts/bootstrap-kinoite-wsl2.sh](../scripts/bootstrap-kinoite-wsl2.sh) |
| `script-bootstrap-fedoraclassic-NOT-PHASE-A` | [../scripts/fedora-dnf-fallback.sh](../scripts/fedora-dnf-fallback.sh) |
| `script-bootstrap-kde` | [../scripts/bootstrap-kde-wsl.sh](../scripts/bootstrap-kde-wsl.sh) |
| `script-appimage-deps` | [../scripts/appimage-fuse-atomic.sh](../scripts/appimage-fuse-atomic.sh) |
| `script-distrobox-dev` | [../scripts/distrobox-optional.sh](../scripts/distrobox-optional.sh) |
| `script-flathub-verify` | [../scripts/verify-flathub.sh](../scripts/verify-flathub.sh) |
| `script-kinoite-first-week` | [../scripts/kinoite-first-week.sh](../scripts/kinoite-first-week.sh) |
| `script-virtualbox-snapshots` | [virtualbox-snapshots-workflow.md](virtualbox-snapshots-workflow.md) (doc; with [virtualbox-kinoite-fallback.md](virtualbox-kinoite-fallback.md)) |
| `phaseA-kinoite-wsl2-import` + import pipeline | [../scripts/import-kinoite-rootfs-to-wsl.ps1](../scripts/import-kinoite-rootfs-to-wsl.ps1) |
| `inv-refresh-date` + `inv-os-cim` + CIM (merge Machine/User PATH) | [../scripts/run-windows-inventory.ps1](../scripts/run-windows-inventory.ps1) |
| **Full re-capture (all inv-* in one run + manifest)** | [../scripts/run-full-plan-capture.ps1](../scripts/run-full-plan-capture.ps1) |
| `inv-winget-json` + `export-winget` | [../scripts/export-winget.ps1](../scripts/export-winget.ps1) |
| `inv-scoop-list` | [../scripts/inv-scoop-list.ps1](../scripts/inv-scoop-list.ps1) |
| `inv-wsl-snapshot` (embedded) | `wsl -l -v` in `run-windows-inventory.ps1` output |
| `inv-startapps-sample` | [../scripts/inv-startapps-sample.ps1](../scripts/inv-startapps-sample.ps1) |
| `inv-reliability-optional` | [../scripts/inv-reliability-sample.ps1](../scripts/inv-reliability-sample.ps1) |
| `inv-event-logs-optional` | [../scripts/sample-event-logs.ps1](../scripts/sample-event-logs.ps1) |
| `inv-hardware-outline` | [../scripts/inv-hardware-outline.ps1](../scripts/inv-hardware-outline.ps1) |
| *(Start Menu — plan §, KotOR `list-windows` parity)* | [../scripts/list-windows-shortcuts.ps1](../scripts/list-windows-shortcuts.ps1) |
| `security-sanitize` | [../.gitignore](../.gitignore) (`imports/` patterns) |
| `git-init-optional` | `G:\workspaces\Kinoite\.git` (repository) |
