# Phases: definition of done (plan vs this workspace)

**Plan:** **`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`** in **KotOR.js**.

## Done in this tree (automation, not a handoff)

- Every YAML `todos` entry from the plan maps to a path in [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) (Appendix A + B).
- **[`scripts/run-full-plan-capture.ps1`](../scripts/run-full-plan-capture.ps1)** runs, in one session, `export-winget.ps1`, `run-windows-inventory.ps1`, `winget list`, `list-windows-shortcuts.ps1` into `imports/`, Scoop, StartApps, CIM hardware outline, performance + application event samples, **`wsl -d Kinoite-WS2`** in-distro checks, and a **VBoxManage** presence line. It leaves **`imports/CAPTURE-MANIFEST-<timestamp>.txt`** as the **index** of that run. Rerun only after a **big** add/remove of Windows apps, then point [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) at the new manifest.
- Phase A oddities (e.g. `rpm-ostree` *not booted* on a container import) appear in `imports/wsl-Kinoite-WS2-verify-*.txt` and in `kinoite-wsl2.md` + `systemd-rpm-ostree-wsl2-claims.md`.

## B / C: only physical installs are out of scope for a repo

| Phase | In git (complete when present) | Outside any script (requires an OS install or bare metal) |
|-------|--------------------------------|-----------------------------------------------------------|
| **A** | WSL2 rootfs, scripts, `docs/*`, `imports/*` with manifest | Iterating until **satisfied** with a given `rpm-ostree` experiment — but **state is captured** in `WORKSPACE_STATUS` and `imports/`, not “pending on the user” for evidence. |
| **B** | `virtualbox-kinoite-fallback.md`, `virtualbox-snapshots-workflow.md` | Creating a real **Kinoite ISO** VM, Guest Additions, GPU. `host-tools-*.txt` records if `VBoxManage` exists on Windows. |
| **C** | `migration-baremetal-checklist.md`, `firmware-and-secure-boot.md`, `atomic-updates-rollback.md`, `power-and-battery.md` | **Disk partitioning**, **firmware** UI, and bare-metal Kinoite install. |

**Win 11 + plan “Windows C”** evidence: [app-mapping.md](app-mapping.md), [windows11-daily-driver-baseline.md](windows11-daily-driver-baseline.md), and the **latest** `CAPTURE-MANIFEST-*.txt` under `imports/`. **Start Menu** paths for this host are now under `imports/start-menu-shortcuts-*.txt` (same script; full capture) instead of only `%TEMP%`. Optional env: [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example).
