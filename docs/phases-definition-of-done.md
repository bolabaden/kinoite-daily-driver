# Phases: definition of done (plan vs this workspace)

**Plan:** the Cursor file **`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`** in the **KotOR.js** repository (e.g. `c:\GitHub\KotOR.js\...`). This file separates what is **verifiable in this Kinoite tree** from work that only exists on **hardware**.

| Phase | What the **repository** delivers (exhaustive config) | What is **on the machine** (out of tree) |
|-------|------------------------------------------------------|-------------------------------------------|
| **A — Kinoite in WSL2** | `docs/kinoite-wsl2.md` (incl. VPN/overlay section), `systemd-rpm-ostree-wsl2-claims.md`, `import-kinoite-rootfs-to-wsl.ps1`, `bootstrap-kinoite-wsl2.sh`, `config/wsl.conf.example`, `config/.wslconfig.example`, `app-mapping`, `keep-windows`, `WORKSPACE_STATUS.md` | WSL2 distro import, `wsl.conf` effect after **full** WSL shutdown, Plasma/WSLg smoke test, your choice of `rpm-ostree` experiments — **container-import** trees may **not** show a clean `rpm-ostree status` (documented) |
| **B — VirtualBox (or other type-2 VM)** | `docs/virtualbox-kinoite-fallback.md`, `docs/virtualbox-snapshots-workflow.md`, Phase B section in `strategy-*.md` / index | Kinoite **ISO** install, Guest Additions, **GPU/3D** as needed, **snapshots** before risky `rpm-ostree` |
| **C — Bare metal** | `docs/migration-baremetal-checklist.md`, `firmware-and-secure-boot.md`, `atomic-updates-rollback.md`, `power-and-battery.md` | **Firmware** updates, **Secure Boot** policy, full-disk layout, real **Kinoite** install, **data migration** from Windows |

**“All phases complete” for automation:** the **row “repository delivers”** is **complete** when every linked artifact exists and **WORKSPACE_STATUS** reflects the latest **winget/shortcut/inventory** runs (where applicable). The **on the machine** column is **not** a git deliverable; it is **tracked in notes** and checklists, not claimed as “done by the agent in chat.”

**Win11 daily-driver map:** `docs/app-mapping.md`, `docs/windows11-daily-driver-baseline.md` + `imports/winget-export-*.json` (local, gitignored) + `%TEMP%` shortcut dumps from `scripts/list-windows-shortcuts.ps1`. Optional env: [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example).
