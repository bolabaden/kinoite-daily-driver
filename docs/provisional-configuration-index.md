# Provisional configuration index (exhaustive vs plan)

This file maps **phases** from `.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md` to **concrete** artifacts in **`G:\workspaces\Kinoite`**. The **plan file itself** is the **spec**; this repo is the **executed** workspace (see `../WORKSPACE_STATUS.md` for live state).

| Phase / topic | Plan intent | This workspace |
|---------------|------------|----------------|
| **Primary path** | `G:\workspaces\Kinoite` + optional `KINOITE_WORKSPACE_ROOT` | `README.md`, env documented at repo root |
| **Phase A — Kinoite in WSL2** | `podman` pull/export → `wsl --import`; systemd, Plasma, Flathub | `docs/kinoite-wsl2.md`, `scripts/import-kinoite-rootfs-to-wsl.ps1`, `scripts/bootstrap-kinoite-wsl2.sh` |
| **OSTree / rpm-ostree honesty** | No false claims for container import | `docs/systemd-rpm-ostree-wsl2-claims.md` |
| **Win11 → Kinoite app map** | TSV + winget; named apps (ShareX, Steam, …) | `docs/app-mapping.md` + `imports/winget-export-*.json` (**gitignored**; re-run `scripts/export-winget.ps1`) |
| **Keep Windows** | 3ds, anti-cheat, Voicemod-grade, ShareX automation | `docs/keep-windows.md` |
| **Host tuning** | `.wslconfig` memory/swap, PATH noise | `config/.wslconfig.example`, `config/wsl.conf.example` (in-distro) |
| **Phase B / VirtualBox** | Kinoite ISO, snapshots | `docs/virtualbox-kinoite-fallback.md`, `docs/virtualbox-snapshots-workflow.md` |
| **Phase C / bare metal** | Migration, firmware, rebase | `docs/migration-baremetal-checklist.md`, `docs/firmware-and-secure-boot.md`, `docs/atomic-updates-rollback.md` |
| **Daily driver KDE** | Plasma, fonts, input, audio, print | `docs/kde-daily-driver-recommendations.md` + `docs/*` topical files (audio, print, network, games, 3D, M365, …) |
| **Research** | Tavily / Firecrawl / external | `docs/research-workflow-tavily-firecrawl.md`, `../research/`, `../.firecrawl/README` |
| **Inventory** | winget, shortcuts, optional events | `scripts/run-windows-inventory.ps1`, `scripts/export-winget.ps1`, `docs/this-pc-inventory-template.md` |

**“All phases complete” in documentation terms:** every **plan** deliverable that can be represented as **markdown + scripts + config templates** exists in-tree. **Phases that require real hardware/ISO installs** (bare metal, full VBox run) are **checklisted**, not **machine-completed** from automation alone.
