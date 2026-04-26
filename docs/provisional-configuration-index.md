# Provisional configuration index (exhaustive vs plan)

This file maps **phases** from `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md` to **concrete** artifacts in **`G:\workspaces\Kinoite`**. The **plan file itself** is the **spec**; this repo is the **executed** workspace (see `../WORKSPACE_STATUS.md` for live state).

| Phase / topic | Plan intent | This workspace |
|---------------|------------|----------------|
| **Primary path** | `G:\workspaces\Kinoite` + optional `KINOITE_WORKSPACE_ROOT` | `README.md`, [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) |
| **Win11 map ↔ plan** | same host, inventory scripts | [windows11-daily-driver-baseline.md](windows11-daily-driver-baseline.md) |
| **Phase A — Kinoite in WSL2** | `podman` pull/export → `wsl --import`; systemd, Plasma, Flathub, **declarative** layers; KotOR plan+AGENTS in **sibling** clone | `docs/kinoite-wsl2.md` (incl. **## Spec and the KotOR.js repository**), [plan-stipulated-file-tree.md](plan-stipulated-file-tree.md), `scripts/import-kinoite-rootfs-to-wsl.ps1`, `scripts/bootstrap-kinoite-wsl2.sh`, `config/rpm-ostree/layers.list`, `scripts/apply-atomic-provision.sh`, `PROVISION` |
| **OSTree / rpm-ostree honesty** | No false claims for container import | `docs/systemd-rpm-ostree-wsl2-claims.md` |
| **Win11 → Kinoite app map** | TSV + winget; named apps (ShareX, Steam, …) | `docs/app-mapping.md` + `imports/winget-export-*.json` (**gitignored**; re-run `scripts/run-full-plan-capture.ps1` or `export-winget.ps1`) |
| **Keep Windows** | 3ds, anti-cheat, Voicemod-grade, ShareX automation | `docs/keep-windows.md` |
| **Host tuning** | `.wslconfig` memory/swap, PATH noise | **`config/wsl2/`** — [windows.wslconfig.example](../config/wsl2/windows.wslconfig.example), [distro.wsl.conf.example](../config/wsl2/distro.wsl.conf.example); stubs: `config/.wslconfig.example`, `config/wsl.conf.example` |
| **Phase B / VirtualBox** | Kinoite ISO, snapshots | `docs/virtualbox-kinoite-fallback.md`, `docs/virtualbox-snapshots-workflow.md` |
| **Phase C / bare metal** | Migration, firmware, rebase, power | `docs/migration-baremetal-checklist.md`, `docs/firmware-and-secure-boot.md`, `docs/atomic-updates-rollback.md`, `docs/power-and-battery.md` |
| **Daily driver KDE** | Plasma, fonts, input, audio, print | `docs/kde-daily-driver-recommendations.md` + `docs/*` topical files (audio, print, network, games, 3D, M365, …); **Night Light + day/night location:** [`config/kde/night-light/`](../config/kde/night-light/README.md), [`scripts/apply-kde-night-light.sh`](../scripts/apply-kde-night-light.sh) |
| **Secrets + Wi‑Fi + locale** | NM templates, gitignored `host-local/`, no PSK in git | [`config/secrets/README.md`](../config/secrets/README.md), [`config/network/`](../config/network/README.md), [`scripts/provision-locale.sh`](../scripts/provision-locale.sh), [`docs/win11-kinoite-parity-matrix.md`](win11-kinoite-parity-matrix.md) |
| **provision.d hooks** | Optional post-apply scripts | [`scripts/provision.d/README.md`](../scripts/provision.d/README.md) |
| **Research** | Tavily / Firecrawl / external | `docs/research-workflow-tavily-firecrawl.md`, `../research/`, `../.firecrawl/README` |
| **Thin topic stubs** | Many `docs/*.md` are short pointers; merge only with link updates | `scripts/list-thin-docs.ps1` (line-count report) |
| **Inventory** | winget, shortcuts, registry ARP, Appx, locale/net, Run keys, DISM/pnputil (optional) | `scripts/run-full-plan-capture.ps1` (one-shot + **CAPTURE-MANIFEST**), `imports/README.md`; **Win → Linux row map:** `config/capture/linux-map.template.csv`, `config/capture/README.md` |
| **Removed / renamed topic docs** | Single redirect table | **§ [Removed topic docs](#removed-topic-docs-replaced-by-repo-paths)** below |
| **Plan ↔ files** | Crosswalk | **§ [KotOR plan and workspace](#kotor-plan-and-workspace-coverage-matrix)** below; legacy stub [`plan-alignment.md`](plan-alignment.md) |
| **Topic → ostree/flatpak** | Every daily-driver doc vs provision plane | [`doc-to-provision-map.md`](doc-to-provision-map.md) |
| **A/B/C “done”** | What repo vs machine means | `docs/phases-definition-of-done.md` |
| **All plan YAML ids (75)** | `todos` + **A** / **B** / **C** (ordered `id` list) | `docs/plan-frontmatter-coverage.md` |
| **Plan § file tree** | `Kinoite/ README, docs/…, config/, …` | `docs/plan-stipulated-file-tree.md` |
| **Tavily (agents)** | RAG / research params | `research/tavily-best-practices-agents-2026-04-25.md` |

---

## Removed topic docs (replaced by repo paths)

Bookmarked paths that **no longer exist** as `docs/*.md` — use these instead:

| Old path (removed) | Use instead |
|--------------------|-------------|
| `docs/appimage-on-atomic.md` | [`scripts/appimage-fuse-atomic.sh`](../scripts/appimage-fuse-atomic.sh), `fuse3` in [`config/rpm-ostree/layers.list`](../config/rpm-ostree/layers.list) (bare-metal tier; comment out on WSL if needed), [doc-to-provision-map.md](doc-to-provision-map.md) |
| `docs/gear-lever.md` | [`config/flatpak/README.md`](../config/flatpak/README.md), [`scripts/flatpak-maintain.sh`](../scripts/flatpak-maintain.sh); [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) `doc-gear-lever` |
| `docs/optional-kde-wsl.md` | [`config/wsl2/README.md`](../config/wsl2/README.md), [`scripts/bootstrap-kde-wsl.sh`](../scripts/bootstrap-kde-wsl.sh), [`scripts/wsl2/`](../scripts/wsl2/) |
| `docs/wslg-clipboard-gui.md` | [`config/wsl2/README.md`](../config/wsl2/README.md), `config/wsl2/profile.d-00-kinoite-wslg-env.sh.example` |

---

## KotOR plan and workspace coverage matrix

**Source of truth (spec):** the Cursor plan in the **KotOR.js** repository at `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`. The **Kinoite** tree is a **sibling** workspace, not a subtree of that repo, so cross-links are by **convention**.

**Execution tree (this workspace):** `G:\workspaces\Kinoite` (or `KINOITE_WORKSPACE_ROOT`).

| Plan § / todo theme | In this workspace | Notes |
|---------------------|-------------------|-------|
| Phase A: Kinoite in WSL2, import, ostree | `docs/kinoite-wsl2.md` (**## Spec and the KotOR.js repository**), [plan-stipulated-file-tree.md](plan-stipulated-file-tree.md), `docs/systemd-rpm-ostree-wsl2-claims.md` | WSL2 container import → `rpm-ostree` limitations documented; Cursor plan + **KotOR.js** `AGENTS` live in sibling repo |
| `wsl.conf` systemd, user | `config/wsl.conf.example` | |
| Host WSL2 VM | `config/.wslconfig.example` | |
| App mapping, winget, plan “this host” § | `docs/app-mapping.md`, `docs/windows11-daily-driver-baseline.md`, `scripts/export-winget.ps1`, `imports/winget-export-*.json` (gitignored) | |
| `KINOITE_WORKSPACE_ROOT` | [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) | plan workspace path + env |
| PC + shortcuts | `docs/this-pc-inventory-template.md`, `scripts/list-windows-shortcuts.ps1` | **Same** as plan’s shortcut inventory pattern |
| Full Windows inventory | `scripts/run-windows-inventory.ps1` | CIM, `wsl -l -v`, podman |
| Phase B/C: VBox, bare metal | `docs/virtualbox-kinoite-fallback.md`, `docs/migration-baremetal-checklist.md`, `docs/virtualization-windows-vm.md` | |
| `keep-windows.md` | `docs/keep-windows.md` | |
| Daily driver topics (audio, print, games, …) | `docs/*.md` — see [doc-to-provision-map.md](doc-to-provision-map.md) | |
| Research: Tavily / Firecrawl | `docs/research-workflow-tavily-firecrawl.md`, `research/`, `.firecrawl/README` | |
| post-exec-mark-plan | completed | `WORKSPACE_STATUS.md`, KotOR plan **Status** + `AGENTS.md` |
| provision-atomic-declarative | `config/rpm-ostree/`, `apply-atomic-provision.sh`, `install-atomic-provision-service.sh`, systemd unit, `PROVISION` | Immutable provision (not docs-only) |
| 75 `id`s vs plan YAML + drift check | `docs/plan-frontmatter-coverage.md` Appendix C; `scripts/verify-plan-frontmatter-coverage.ps1` (exit 0 = all `id`s listed in coverage doc) | Re-run when KotOR `kinoite_wsl_workspace_ec9c3c8b.plan.md` `todos` change |

**Frontmatter `todos`:** all **completed** or **cancelled** in plan; this workspace is the **materialized** deliverable; new or renamed `id`s in KotOR must be mirrored in `plan-frontmatter-coverage.md` (main table + **Appendix C**) and pass **`verify-plan-frontmatter-coverage.ps1`**.

---

**“All phases complete” in documentation terms:** every **plan** deliverable that can be represented as **markdown + scripts + config templates** exists in-tree, [plan-frontmatter-coverage](plan-frontmatter-coverage.md) (including **Appendix C** — **75** YAML `id` values vs KotOR `kinoite_wsl_workspace_ec9c3c8b.plan.md`, verifiable with [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1)) is exhaustive, and [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) + [app-mapping.md](app-mapping.md) + **`imports/CAPTURE-MANIFEST-*.txt`** (when present) name the **latest** `winget` / full-inventory files under `imports/`. **Phases that require real hardware/ISO installs** (bare metal, full VBox run) are **checklisted** in the repo, not **machine-completed** from git alone; see [phases-definition-of-done](phases-definition-of-done.md).
