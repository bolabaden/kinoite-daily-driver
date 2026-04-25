# Phases: definition of done (plan vs this workspace)

**Plan:** **`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`** in **KotOR.js**.

## Done in this tree (automation, not a handoff)

- Every YAML `todos` entry from the plan maps to a path in [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) (Appendix A + B), including **declarative** Linux provision (`provision-atomic-declarative`).
- **Windows (this host):** [`scripts/run-full-plan-capture.ps1`](../scripts/run-full-plan-capture.ps1) runs `export-winget.ps1`, `run-windows-inventory.ps1`, `winget list`, `list-windows-shortcuts.ps1` into `imports/`, Scoop, StartApps, CIM hardware outline, performance + application log samples, **`wsl -d Kinoite-WS2`**, and **VBoxManage** presence. It writes **`imports/CAPTURE-MANIFEST-<timestamp>.txt`**. Re-run only after a **big** add/remove of Windows apps; update [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) to the new manifest.
- **Linux (Kinoite) immutable provision:** [PROVISION](../PROVISION), [`config/rpm-ostree/layers.list`](../config/rpm-ostree/layers.list) + [config/flatpak/*.list](../config/flatpak/), [`scripts/apply-atomic-provision.sh`](../scripts/apply-atomic-provision.sh), and optional boot [`config/systemd/kinoite-atomic-ostree.service`](../config/systemd/kinoite-atomic-ostree.service) via [`scripts/install-atomic-provision-service.sh`](../scripts/install-atomic-provision-service.sh).
- Phase A oddities (e.g. `rpm-ostree` *not booted* on a container import) appear in `imports/wsl-Kinoite-WS2-verify-*.txt` and in `kinoite-wsl2.md` + `systemd-rpm-ostree-wsl2-claims.md`.

## B / C: only physical installs are out of scope for a repo

| Phase | In git (complete when present) | Outside any script (requires an OS install or bare metal) |
|-------|--------------------------------|-----------------------------------------------------------|
| **A** | WSL2 rootfs, scripts, `docs/*`, `imports/*` with manifest, **`config/rpm-ostree` + `apply-atomic-provision.sh` + `PROVISION`** | Iterating until **satisfied** with a given `rpm-ostree` experiment — but **state is captured** in `WORKSPACE_STATUS` and `imports/`, not “pending on the user” for evidence. |
| **B** | `virtualbox-kinoite-fallback.md`, `virtualbox-snapshots-workflow.md` — **repo deliverable: complete** (procedures, ISO link, snapshot strategy). Machine: create VM, install guest additions, validate GPU. Evidence on Windows: `imports/host-tools-*.txt` (VBoxManage on `PATH` or not). |
| **C** | `migration-baremetal-checklist.md`, `firmware-and-secure-boot.md`, `atomic-updates-rollback.md`, `power-and-battery.md` — **repo deliverable: complete** (firmware, ostree rollback, zram/swap, migration steps). Machine: real disk layout, `fwupd`, bare-metal install. |

**Win 11 + plan “Windows C”** evidence: [app-mapping.md](app-mapping.md), [windows11-daily-driver-baseline.md](windows11-daily-driver-baseline.md), and the **latest** `CAPTURE-MANIFEST-*.txt` under `imports/`. **Start Menu** paths for this host are now under `imports/start-menu-shortcuts-*.txt` (same script; full capture) instead of only `%TEMP%`. Optional env: [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example).
