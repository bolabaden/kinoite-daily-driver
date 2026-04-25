# Plan-stipulated workspace file tree (satisfied)

The plan **“Workspace path”** block in `silverblue_wsl_workspace_ec9c3c8b.plan.md` shows an example tree. This repository **includes** that tree **and** the **“(… other topic docs from prior plans …)”** expansion (atomic rollback, M365, games, 3D, swap, WSLg clipboard, etc. — all under `docs/`).

| Plan line / intent | In `G:\workspaces\Kinoite` |
|--------------------|----------------------------|
| `Kinoite/README.md` | [README.md](../README.md) |
| `.gitignore` | [../.gitignore](../.gitignore) |
| `docs/kinoite-wsl2.md` | [kinoite-wsl2.md](kinoite-wsl2.md) (authoritative Phase A) |
| `docs/kinoite-vs-atomic-desktops.md` | [kinoite-vs-atomic-desktops.md](kinoite-vs-atomic-desktops.md) (Kinoite vs **Silverblue**) |
| `docs/strategy-phaseA-kinoite-wsl2.md` | [strategy-phaseA-kinoite-wsl2.md](strategy-phaseA-kinoite-wsl2.md) |
| `docs/app-mapping.md` + winget TSV | [app-mapping.md](app-mapping.md) + `imports/winget-export-*.json` (gitignored) |
| `docs/keep-windows.md` | [keep-windows.md](keep-windows.md) |
| `docs/virtualbox-kinoite-fallback.md` | [virtualbox-kinoite-fallback.md](virtualbox-kinoite-fallback.md) + [virtualbox-snapshots-workflow.md](virtualbox-snapshots-workflow.md) |
| `(… other topic docs …)` | 40+ topic files — index: [provisional-configuration-index.md](provisional-configuration-index.md); every `doc-*` plan todo: [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) |
| `config/` | [wsl.conf.example](../config/wsl.conf.example), [`.wslconfig.example`](../config/.wslconfig.example), [flatpak/*.list](../config/flatpak/), [shell/](../config/shell/) |
| `scripts/` | [../scripts/](../scripts/) (import, bootstrap, inventory, optional inv-*) |
| `imports/` | [../imports/README.md](../imports/README.md) (bulk exports gitignored; **`CAPTURE-MANIFEST-*.txt`** committed) |
| **Env (plan):** `KINOITE_WORKSPACE_ROOT` | [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) |
| **Fallback path** `C:\Users\…\workspaces\Kinoite` | Same layout; [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) can be edited to that path |

**Execution state** (not a second copy of the tree): [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md).
