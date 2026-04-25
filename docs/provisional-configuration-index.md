# Provisional configuration index (exhaustive vs plan)

This file maps **phases** from `.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md` to **concrete** artifacts in **`G:\workspaces\Kinoite`**. The **plan file itself** is the **spec**; this repo is the **executed** workspace (see `../WORKSPACE_STATUS.md` for live state).

| Phase / topic | Plan intent | This workspace |
|---------------|------------|----------------|
| **Primary path** | `G:\workspaces\Kinoite` + optional `KINOITE_WORKSPACE_ROOT` | `README.md`, [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) |
| **Win11 map ↔ plan** | same host, inventory scripts | [windows11-daily-driver-baseline.md](windows11-daily-driver-baseline.md) |
| **Phase A — Kinoite in WSL2** | `podman` pull/export → `wsl --import`; systemd, Plasma, Flathub, **declarative** layers | `docs/kinoite-wsl2.md`, `scripts/import-kinoite-rootfs-to-wsl.ps1`, `scripts/bootstrap-kinoite-wsl2.sh`, `config/rpm-ostree/layers.list`, `scripts/apply-atomic-provision.sh`, `PROVISION` |
| **OSTree / rpm-ostree honesty** | No false claims for container import | `docs/systemd-rpm-ostree-wsl2-claims.md` |
| **Win11 → Kinoite app map** | TSV + winget; named apps (ShareX, Steam, …) | `docs/app-mapping.md` + `imports/winget-export-*.json` (**gitignored**; re-run `scripts/run-full-plan-capture.ps1` or `export-winget.ps1`) |
| **Keep Windows** | 3ds, anti-cheat, Voicemod-grade, ShareX automation | `docs/keep-windows.md` |
| **Host tuning** | `.wslconfig` memory/swap, PATH noise | `config/.wslconfig.example`, `config/wsl.conf.example` (in-distro) |
| **Phase B / VirtualBox** | Kinoite ISO, snapshots | `docs/virtualbox-kinoite-fallback.md`, `docs/virtualbox-snapshots-workflow.md` |
| **Phase C / bare metal** | Migration, firmware, rebase, power | `docs/migration-baremetal-checklist.md`, `docs/firmware-and-secure-boot.md`, `docs/atomic-updates-rollback.md`, `docs/power-and-battery.md` |
| **Daily driver KDE** | Plasma, fonts, input, audio, print | `docs/kde-daily-driver-recommendations.md` + `docs/*` topical files (audio, print, network, games, 3D, M365, …) |
| **Research** | Tavily / Firecrawl / external | `docs/research-workflow-tavily-firecrawl.md`, `../research/`, `../.firecrawl/README` |
| **Inventory** | winget, shortcuts, optional events | `scripts/run-full-plan-capture.ps1` (one-shot + **CAPTURE-MANIFEST**), or `run-windows-inventory.ps1` + `export-winget.ps1` + `list-windows-shortcuts.ps1` (last may use `%TEMP%` unless orchestrated), `docs/this-pc-inventory-template.md` |
| **Plan ↔ files** | Crosswalk | `docs/plan-alignment.md` |
| **A/B/C “done”** | What repo vs machine means | `docs/phases-definition-of-done.md` |
| **All plan YAML ids (75)** | `todos` + **A** / **B** / **C** (ordered `id` list) | `docs/plan-frontmatter-coverage.md` |
| **Plan § file tree** | `Kinoite/ README, docs/…, config/, …` | `docs/plan-stipulated-file-tree.md` |
| **Tavily (agents)** | RAG / research params | `research/tavily-best-practices-agents-2026-04-25.md` |

**“All phases complete” in documentation terms:** every **plan** deliverable that can be represented as **markdown + scripts + config templates** exists in-tree, [plan-frontmatter-coverage](plan-frontmatter-coverage.md) (including **Appendix C** — **75** YAML `id` values vs KotOR `silverblue_wsl_workspace_ec9c3c8b.plan.md`, verifiable with [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1)) is exhaustive, and [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) + [app-mapping.md](app-mapping.md) + **`imports/CAPTURE-MANIFEST-*.txt`** (when present) name the **latest** `winget` / full-inventory files under `imports/`. **Phases that require real hardware/ISO installs** (bare metal, full VBox run) are **checklisted** in the repo, not **machine-completed** from git alone; see [phases-definition-of-done](phases-definition-of-done.md).
