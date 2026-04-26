# Plan frontmatter `todos` → workspace artifacts (exhaustive)

**Plan:** `KotOR.js` → `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md` (all items below were **`completed`** or **`cancelled`** in plan YAML as of the plan revision). This file is the **machine-readable** map for “is every `id` covered in `G:\workspaces\Kinoite`?”

| `id` | Plan status | This workspace (path or note) |
|------|-------------|------------------------------|
| `phaseA-kinoite-wsl2-import` | completed | `docs/kinoite-wsl2.md` + `scripts/import-kinoite-rootfs-to-wsl.ps1` + executed import recorded in `WORKSPACE_STATUS.md` |
| `phaseA-wsl-conf-systemd` | completed | `config/wsl.conf.example` + in-distro `/etc/wsl.conf` note in `kinoite-wsl2.md` |
| `phaseA-rpm-ostree-verify` | completed | [kinoite-wsl2 — honesty](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) + `kinoite-wsl2.md` (expected not-booted error) |
| `phaseA-plasma-wslg` | completed | `kinoite-wsl2.md` § Plasma/WSLg, `scripts/bootstrap-kde-wsl.sh`, `scripts/wsl2/launch-kde-gui-wslg.sh` |
| `research-kinoite-rootfs-sources` | completed | `kinoite-wsl2.md` (Quay pin) + `research/*` |
| `doc-kinoite-wsl2-authoritative` | completed | `docs/kinoite-wsl2.md` |
| `inv-refresh-date` / `inv-os-cim` / `inv-winget-json` | completed | `run-windows-inventory.ps1` + `export-winget.ps1` → `imports/*` (gitignored); or **`run-full-plan-capture.ps1`** (all of the above + `winget list`, Start Menu, optional logs; **`CAPTURE-MANIFEST.txt`** unignored) |
| `win-c-drive-app-snapshot-2026-04` | completed | `app-mapping.md`, [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts), local exports |
| `inv-scoop-list` / `inv-wsl-snapshot` / `inv-startapps-sample` / `inv-reliability-optional` / `inv-event-logs-optional` / `inv-hardware-outline` | completed | `inv-scoop-list.ps1`, `inv-*.ps1`, `sample-event-logs.ps1` |
| `path-resolve-g` / `create-tree` | completed | `G:\workspaces\Kinoite`, `kinoite-workspace-root.env.example` |
| `doc-readme-main` | completed | `README.md` |
| `doc-strategy-phaseA-kinoite-wsl2` | completed | `docs/kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only` |
| `doc-virtualbox-kinoite` / `script-virtualbox-snapshots` | completed | [migration-baremetal — Kinoite guest VM + snapshots](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) |
| `doc-fallback-classic-fedora-optional` | completed | [kinoite-wsl2 — optional classic Fedora](kinoite-wsl2.md#optional-classic-fedora-in-wsl) + `scripts/fedora-dnf-fallback.sh` (not Phase A) |
| `doc-pc-inventory-snapshot` | completed | [win11 matrix — This PC](win11-kinoite-parity-matrix.md#this-pc-quick-template) |
| `doc-kinoite-vs-other-atomic-desktops` | completed | `docs/kinoite-wsl2.md#kinoite-and-other-atomic-desktops` (former stub file **removed**) |
| `doc-wsl-atomic-parity` | completed | `docs/kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity` (former stub file **removed**) |
| `doc-app-mapping` | completed | `docs/app-mapping.md` |
| `doc-kde-daily-driver` / `kde-plasma6-widgets` | completed | `docs/kde-daily-driver-recommendations.md` (Plasma 6) |
| `doc-fonts-theming` … `doc-migration-baremetal` | completed | See **Appendix A** (one row per `id`); [provisional-configuration-index.md](provisional-configuration-index.md) |
| `doc-research-workflow` | completed | [README — Research (Tavily, Firecrawl, web)](README.md#research-tavily-firecrawl-and-the-web) (includes [Tavily agent digest](README.md#tavily-agent-rag-and-cli-digest)) |
| `config-wsl-conf` / `config-flatpak-lists` / `config-shell-skel` | completed | `config/wsl.conf.example`, `config/.wslconfig.example`, `config/flatpak/*.list`, [ides-and-terminals — Optional shell skeleton](ides-and-terminals.md#optional-shell-skeleton) (`config/shell/`) |
| `script-*` (bootstrap, kde, appimage, distrobox, flathub, first-week) | completed | `scripts/*.sh` / `*.ps1` named in plan (see `README.md` Scripts) |
| `script-bootstrap-fedoraclassic-NOT-PHASE-A` | completed | `fedora-dnf-fallback.sh` (deprecated for Phase A) |
| `security-sanitize` | completed | `.gitignore` (imports) |
| `git-init-optional` | completed | `G:\workspaces\Kinoite` has `.git` |
| `research-pass-external` / `research-firecrawl-pass` | completed | `research/*`, [kinoite-wsl2 — community + primary digest](kinoite-wsl2.md#community-pointers-non-authoritative), `.firecrawl/README` (credit note) |
| `handoff-user-test` | completed | `WORKSPACE_STATUS.md` + [provisional: phases DOD](provisional-configuration-index.md#phases-definition-of-done) (Phase A real-world caveats) |
| `doc-ostree-rollback` … `doc-bluetooth-audio` | completed | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) (OSTree, firmware, power, swap; those topic files were merged into the checklist and **removed**) … [kde-daily-driver — Bluetooth / PipeWire](kde-daily-driver-recommendations.md#bluetooth-and-pipewire) (ex-`bluetooth-pipewire.md` / ex-`audio-and-display.md`) |
| `pre-commit-secrets` | completed | [GETTING_STARTED.md#optional-gitleaks](../GETTING_STARTED.md#optional-gitleaks) (former `gitleaks-optional.md` **removed**) |
| `post-exec-mark-plan` | completed in plan (KotOR) | `WORKSPACE_STATUS.md` + KotOR plan **Status** (`.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`) + `AGENTS.md` (full-capture pointer) |
| `provision-atomic-declarative` | completed | `config/rpm-ostree/layers.list`, [../scripts/apply-atomic-provision.sh](../scripts/apply-atomic-provision.sh), [../scripts/install-atomic-provision-service.sh](../scripts/install-atomic-provision-service.sh), [../config/systemd/kinoite-atomic-ostree.service](../config/systemd/kinoite-atomic-ostree.service), [../GETTING_STARTED.md](../GETTING_STARTED.md#step-3--edit-the-declarative-lists) |
| *Pre-provision-atomic execution extras (subsumed by id above when present):* | — | (historical) same paths as `provision-atomic-declarative` + [provisional KotOR matrix](provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) |
| *Added by execution (other):* | — | `scripts/run-full-plan-capture.ps1`, committed `imports/CAPTURE-MANIFEST.txt`, [provisional: phases DOD](provisional-configuration-index.md#phases-definition-of-done) + [win11-kinoite-parity-matrix](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts), `plan-frontmatter-coverage.md` (this file) |

**Exhaustive definition:** if it appears in the plan’s **todos** table above, there is a **concrete** script, `docs/*.md`, `config/`, or **notes in `WORKSPACE_STATUS.md`** (for host-only state). If an `id` is **`cancelled`**, the replacement artifact is named.

---

## Appendix A — every `doc-*` and related `kde-` / `pre-commit` id → file

| `id` | `docs/…` or note |
|------|------------------|
| `doc-kinoite-wsl2-authoritative` | [kinoite-wsl2.md](kinoite-wsl2.md) |
| `doc-readme-main` | [README.md](../README.md) |
| `doc-strategy-phaseA-kinoite-wsl2` | [kinoite-wsl2.md § Strategy](kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only) |
| `doc-virtualbox-kinoite` | [migration-baremetal-checklist — Kinoite guest VM](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) |
| `doc-fallback-classic-fedora-optional` | [kinoite-wsl2 — optional classic dnf in WSL](kinoite-wsl2.md#optional-classic-fedora-in-wsl) |
| `doc-pc-inventory-snapshot` | [win11 — This PC template](win11-kinoite-parity-matrix.md#this-pc-quick-template) |
| `doc-kinoite-vs-other-atomic-desktops` | [kinoite-wsl2.md § other Atomic](kinoite-wsl2.md#kinoite-and-other-atomic-desktops) |
| `doc-wsl-atomic-parity` | [kinoite-wsl2 — parity](kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity) |
| `doc-app-mapping` | [app-mapping.md](app-mapping.md) |
| `doc-kde-daily-driver` | [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) |
| `doc-fonts-theming` | [kde-daily-driver — Fonts and theming](kde-daily-driver-recommendations.md#fonts-and-theming-kinoite) |
| `doc-audio-display` | [kde-daily-driver — Audio and display](kde-daily-driver-recommendations.md#audio-and-display) |
| `doc-input-accessibility` | [kde-daily-driver — Input, IME, accessibility](kde-daily-driver-recommendations.md#input-ime-and-accessibility) |
| `doc-printing-scanning` | [kde-daily-driver — Printing and scanning](kde-daily-driver-recommendations.md#printing-and-scanning) |
| `doc-filesystems` | [migration-baremetal — Filesystems and external drives](migration-baremetal-checklist.md#filesystems-and-external-drives) |
| `doc-backup-sync` | [migration-baremetal — Backup and sync](migration-baremetal-checklist.md#backup-and-sync) |
| `doc-appimage-fuse` | [../scripts/appimage-fuse-atomic.sh](../scripts/appimage-fuse-atomic.sh) + FUSE tier in [../config/rpm-ostree/layers.list](../config/rpm-ostree/layers.list) (topic doc removed; behavior in repo) |
| `doc-gear-lever` | [../config/flatpak/README](../config/flatpak/README) + [../scripts/flatpak-maintain.sh](../scripts/flatpak-maintain.sh) (topic doc removed) |
| `doc-podman-docker` | [ides-and-terminals — Podman / toolbox](ides-and-terminals.md#podman-toolbox-and-docker-compatibility) |
| `doc-secrets-ssh` | [networking — Secrets, SSH, and GPG](networking.md#secrets-ssh-and-gpg) |
| `doc-3d-autodesk` | [app-mapping — 3D and Autodesk (DCC)](app-mapping.md#3d-and-autodesk-dcc) |
| `doc-gaming` | [app-mapping — Steam, Proton, anti-cheat](app-mapping.md#steam-proton-heroic-and-anti-cheat) |
| `doc-network-vpn` | [networking.md](networking.md) |
| `doc-media-homelab` | [llm-and-dev-ai — Media and homelab](llm-and-dev-ai.md#media-and-homelab-jellyfin-plex-and-arr) |
| `doc-llm-local` | [llm-and-dev-ai.md](llm-and-dev-ai.md) |
| `doc-ides` | [ides-and-terminals.md](ides-and-terminals.md) |
| `doc-m365` | [kde-daily-driver — Microsoft 365 on Linux](kde-daily-driver-recommendations.md#microsoft-365-on-linux) |
| `doc-optional-kde-wsl` | [../scripts/bootstrap-kde-wsl.sh](../scripts/bootstrap-kde-wsl.sh) + [../config/wsl2/README.md](../config/wsl2/README.md) (topic doc removed; behavior in repo) |
| `doc-migration-baremetal` | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) |
| *Plan **Workspace** tree* — `keep-windows` *(no separate YAML `doc-` `id`)* | [app-mapping — keep Windows](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads) |
| *`win-c-drive-app-snapshot-2026-04` + Win11 host mirror* | [app-mapping.md](app-mapping.md) + [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts) + `imports/*` (see [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md)) |
| `doc-research-workflow` | [README — Research + Tavily digest](README.md#research-tavily-firecrawl-and-the-web) |
| `doc-ostree-rollback` | [migration — Atomic updates and rollback](migration-baremetal-checklist.md#atomic-updates-and-rollback) |
| `doc-fwupd-secureboot` | [migration — Firmware and secure boot](migration-baremetal-checklist.md#firmware-and-secure-boot) |
| `doc-flatpak-overrides` | [GETTING_STARTED — Flatpak overrides](../GETTING_STARTED.md#flatpak-overrides-optional-per-app) |
| `doc-power-battery` | [migration — Power and battery](migration-baremetal-checklist.md#power-and-battery) |
| `doc-virtualization-windows-vm` | [migration-baremetal — Windows 11 guest VM](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm) |
| `doc-swap-zram` | [migration — Swap and zram](migration-baremetal-checklist.md#swap-and-zram) |
| `doc-clipboard-wslg` | [../config/wsl2/README.md](../config/wsl2/README.md) (topic doc removed) |
| `doc-bluetooth-audio` | [kde-daily-driver — Bluetooth / PipeWire](kde-daily-driver-recommendations.md#bluetooth-and-pipewire) |
| `kde-plasma6-widgets` | [kde-daily-driver-recommendations.md](kde-daily-driver-recommendations.md) (Plasma 6) |
| `pre-commit-secrets` | [GETTING_STARTED — gitleaks](../GETTING_STARTED.md#optional-gitleaks) |
| `script-virtualbox-snapshots` | [migration-baremetal — VirtualBox snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox) |

**See also (plan file names):** [provisional-configuration-index#plan-stipulated-file-tree](provisional-configuration-index.md#plan-stipulated-file-tree) (verbatim **Workspace path** tree).

---

## Appendix B — `config-*`, `script-*`, and `inv-*` / `phaseA-*` (exact paths)

| Plan `id` | Artifact |
|-----------|----------|
| `config-wsl-conf` | [../config/wsl.conf.example](../config/wsl.conf.example) |
| *Host* `%UserProfile%\.wslconfig` | [../config/.wslconfig.example](../config/.wslconfig.example) |
| `config-flatpak-lists` | [../config/flatpak/desktop-core.list](../config/flatpak/desktop-core.list), [../config/flatpak/dev.list](../config/flatpak/dev.list), [../config/flatpak/gaming.list](../config/flatpak/gaming.list) |
| `provision-atomic-declarative` | [../config/rpm-ostree/layers.list](../config/rpm-ostree/layers.list), [../scripts/apply-atomic-provision.sh](../scripts/apply-atomic-provision.sh), [../config/systemd/kinoite-atomic-ostree.service](../config/systemd/kinoite-atomic-ostree.service), [../scripts/install-atomic-provision-service.sh](../scripts/install-atomic-provision-service.sh), [../GETTING_STARTED.md](../GETTING_STARTED.md#step-3--edit-the-declarative-lists) |
| `config-shell-skel` | [ides-and-terminals — Optional shell skeleton](ides-and-terminals.md#optional-shell-skeleton) |
| `path-resolve-g` / `create-tree` | [../kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) (repo path convention) |
| `script-bootstrap-kinoite-wsl2` | [../scripts/bootstrap-kinoite-wsl2.sh](../scripts/bootstrap-kinoite-wsl2.sh) |
| `script-bootstrap-fedoraclassic-NOT-PHASE-A` | [../scripts/fedora-dnf-fallback.sh](../scripts/fedora-dnf-fallback.sh) |
| `script-bootstrap-kde` | [../scripts/bootstrap-kde-wsl.sh](../scripts/bootstrap-kde-wsl.sh) |
| `script-appimage-deps` | [../scripts/appimage-fuse-atomic.sh](../scripts/appimage-fuse-atomic.sh) |
| `script-distrobox-dev` | [ides-and-terminals — quick distrobox](ides-and-terminals.md#quick-distrobox-mutable-dnf-in-a-box) |
| `script-flathub-verify` | [../scripts/verify-flathub.sh](../scripts/verify-flathub.sh) |
| `script-kinoite-first-week` | [../scripts/kinoite-first-week.sh](../scripts/kinoite-first-week.sh) |
| `script-virtualbox-snapshots` | [migration-baremetal — VirtualBox snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox) |
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

**Source of truth (YAML order):** KotOR.js `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md` frontmatter. This appendix is a **1:1 ordered list** of all `id` values; **row-by-row** mapping to files is in the **main table** and in **Appendix A** and **B** above, plus [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) for on-host execution. **Regenerate** this list (or run [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1), or [`../scripts/verify-repo-health.ps1`](../scripts/verify-repo-health.ps1) to also check markdown file links) when the plan’s `todos` change.

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
23. `doc-kinoite-vs-other-atomic-desktops`  
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
