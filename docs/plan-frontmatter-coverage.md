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
| `provision-atomic-declarative` | completed | `config/rpm-ostree/layers.list`, [../scripts/apply-atomic-provision.sh](../scripts/apply-atomic-provision.sh), [../scripts/install-atomic-provision-service.sh](../scripts/install-atomic-provision-service.sh), [../config/systemd/kinoite-atomic-ostree.service](../config/systemd/kinoite-atomic-ostree.service), [../PROVISION](../PROVISION) |
| *Pre-provision-atomic execution extras (subsumed by id above when present):* | — | (historical) same paths as `provision-atomic-declarative` + `docs/plan-alignment.md` |
| *Added by execution (other):* | — | `scripts/run-full-plan-capture.ps1`, committed `imports/CAPTURE-MANIFEST-*.txt`, `docs/plan-alignment.md`, `windows11-daily-driver-baseline.md`, `plan-frontmatter-coverage.md` (this file) |

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
| `provision-atomic-declarative` | [../config/rpm-ostree/layers.list](../config/rpm-ostree/layers.list), [../scripts/apply-atomic-provision.sh](../scripts/apply-atomic-provision.sh), [../config/systemd/kinoite-atomic-ostree.service](../config/systemd/kinoite-atomic-ostree.service), [../scripts/install-atomic-provision-service.sh](../scripts/install-atomic-provision-service.sh), [../PROVISION](../PROVISION) |
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

---

## Appendix C — Canonical plan `todos` `id` list (75)

**Source of truth (YAML order):** KotOR.js `.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md` frontmatter. This appendix is a **1:1 checklist**; mapping to files is in the **main table** and **Appendix A** / **B** above, plus [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) for on-host execution. **Regenerate** this list (or run [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1)) when the plan’s `todos` change.

1. `phaseA-kinoite-wsl2-import`  
2. `phaseA-wsl-conf-systemd`  
3. `phaseA-rpm-ostree-verify`  
4. `phaseA-plasma-wslg`  
5. `research-kinoite-rootfs-sources`  
6. `doc-kinoite-wsl2-authoritative`  
7. `inv-refresh-date`  
8. `inv-os-cim`  
9. `inv-winget-json`  
10. `win-c-drive-app-snapshot-2026-04`  
11. `inv-scoop-list`  
12. `inv-wsl-snapshot`  
13. `inv-startapps-sample`  
14. `inv-reliability-optional`  
15. `inv-event-logs-optional`  
16. `path-resolve-g`  
17. `create-tree`  
18. `doc-readme-main`  
19. `doc-strategy-phaseA-kinoite-wsl2`  
20. `doc-virtualbox-kinoite`  
21. `doc-fallback-classic-fedora-optional`  
22. `doc-pc-inventory-snapshot`  
23. `doc-kinoite-vs-silverblue`  
24. `doc-wsl-atomic-parity`  
25. `doc-app-mapping`  
26. `doc-kde-daily-driver`  
27. `doc-fonts-theming`  
28. `doc-audio-display`  
29. `doc-input-accessibility`  
30. `doc-printing-scanning`  
31. `doc-filesystems`  
32. `doc-backup-sync`  
33. `doc-appimage-fuse`  
34. `doc-gear-lever`  
35. `doc-podman-docker`  
36. `doc-secrets-ssh`  
37. `doc-3d-autodesk`  
38. `doc-gaming`  
39. `doc-network-vpn`  
40. `doc-media-homelab`  
41. `doc-llm-local`  
42. `doc-ides`  
43. `doc-m365`  
44. `doc-optional-kde-wsl`  
45. `doc-migration-baremetal`  
46. `doc-research-workflow`  
47. `config-wsl-conf`  
48. `config-flatpak-lists`  
49. `config-shell-skel`  
50. `script-bootstrap-kinoite-wsl2`  
51. `script-bootstrap-fedoraclassic-NOT-PHASE-A`  
52. `script-bootstrap-kde`  
53. `script-appimage-deps`  
54. `script-distrobox-dev`  
55. `script-flathub-verify`  
56. `script-kinoite-first-week`  
57. `script-virtualbox-snapshots`  
58. `security-sanitize`  
59. `git-init-optional`  
60. `research-pass-external`  
61. `research-firecrawl-pass`  
62. `handoff-user-test`  
63. `inv-hardware-outline`  
64. `doc-ostree-rollback`  
65. `doc-fwupd-secureboot`  
66. `doc-flatpak-overrides`  
67. `doc-power-battery`  
68. `doc-virtualization-windows-vm`  
69. `doc-swap-zram`  
70. `doc-clipboard-wslg`  
71. `doc-bluetooth-audio`  
72. `kde-plasma6-widgets`  
73. `pre-commit-secrets`  
74. `post-exec-mark-plan`  
75. `provision-atomic-declarative`  
