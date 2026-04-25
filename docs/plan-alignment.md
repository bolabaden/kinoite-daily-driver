# Silverblue WSL / Kinoite plan — coverage matrix

**Source of truth (spec):** the Cursor plan in the **KotOR.js** repository at `.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md` (e.g. `c:\GitHub\KotOR.js\.cursor\plans\...`). The **G:\\** Kinoite tree is a **sibling** workspace, not a subtree of that repo, so cross-links are by **convention** (same `list-windows-shortcuts` behavior in both `scripts\` folders when you maintain both).

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
| Daily driver topics (audio, print, games, …) | `docs/*.md` (see `provisional-configuration-index.md`) | |
| Research: Tavily / Firecrawl | `docs/research-workflow-tavily-firecrawl.md`, `research/`, `.firecrawl/README` | |
| post-exec-mark-plan | completed | `WORKSPACE_STATUS.md`, KotOR plan **Status** + `AGENTS.md` |
| provision-atomic-declarative | `config/rpm-ostree/`, `apply-atomic-provision.sh`, `install-atomic-provision-service.sh`, systemd unit, `PROVISION` | Immutable provision (not docs-only) |
| 75 `id`s vs plan YAML + drift check | `docs/plan-frontmatter-coverage.md` Appendix C; `scripts/verify-plan-frontmatter-coverage.ps1` (exit 0 = all `id`s listed in coverage doc) | Re-run when KotOR `silverblue_wsl_workspace_ec9c3c8b.plan.md` `todos` change |

**Frontmatter `todos`:** all **completed** or **cancelled** in plan; this workspace is the **materialized** deliverable; new or renamed `id`s in KotOR must be mirrored in `plan-frontmatter-coverage.md` (main table + **Appendix C**) and pass **`verify-plan-frontmatter-coverage.ps1`**.
