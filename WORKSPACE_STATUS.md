# Workspace execution status

This file is the **authoritative** execution log. The spec lives in **KotOR.js** (`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`); **this** path is what was run on the host.

| Check | Status | Notes |
|-------|--------|-------|
| Workspace at `G:\workspaces\Kinoite` | **Done** | `docs/provisional-configuration-index.md` = phase→artifact map |
| `KINOITE_WORKSPACE_ROOT` (optional) | **Doc-only** | In profile or [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example) |
| **Full plan capture (all Win11 + WSL evidence)** | **Done 2026-04-25** (index [`CAPTURE-MANIFEST-20260425T175108.txt`](imports/CAPTURE-MANIFEST-20260425T175108.txt)) | [`scripts/run-full-plan-capture.ps1`](scripts/run-full-plan-capture.ps1) — committed **`imports/CAPTURE-MANIFEST-*.txt`** only; bulk outputs gitignored. Latest run: winget export + `winget list` (**318** **lines**, plan “Windows C”), CIM inventory, **Start Menu in `imports/`** (`start-menu-shortcuts-*`, **838** lines this run), Scoop, StartApps, hardware, reliability + app log samples, **`wsl-Kinoite-WS2-verify-*.txt`**, `host-tools-*.txt` |
| Kinoite OCI + `wsl --import` | **Done** | `Kinoite-WS2` on `G:\WSL\Kinoite-WS2`; image `quay.io/.../kinoite:43` |
| `/etc/wsl.conf` `[boot] systemd=true` | **Present** | Confirmed in `imports/wsl-Kinoite-WS2-verify-20260425T175108.txt` (same content as prior verify runs) |
| `rpm-ostree status` in WSL | **Documented** | *Not booted via libostree* in same verify file — expected for container import; see `docs/systemd-rpm-ostree-wsl2-claims.md` |
| **`winget export` (latest in last full capture)** | **Done 2026-04-25** | `imports/winget-export-20260425T175108.json` |
| **`windows-inventory` (CIM+WSL+podman, same run)** | **Done 2026-04-25** | `imports/windows-inventory-20260425T175121.txt` |
| TSV + `app-mapping.md` | **Done** | Plan table + links to `imports/` and manifest |
| `docs/keep-windows.md` | **Done** | Parity gaps, PUP/ARP note |
| Host `~/.wslconfig` | **Template** | `config/.wslconfig.example` |
| Research (Tavily / URLs) | **In tree** | `research/*`, `docs/research-workflow-tavily-firecrawl.md` |
| Plan crosswalk | **Done** | `docs/plan-alignment.md` |
| `kinoite-wsl2.md` VPN overlay | **Done** | **## VPN and overlay network stack** |
| Phases A/B/C (definition) | **Done** | [docs/phases-definition-of-done.md](docs/phases-definition-of-done.md) — **A** evidence in `imports/`; **B/C** repo docs + checklists **complete**; real VM/ISO and bare metal remain **on hardware** (e.g. `host-tools-20260425T175108.txt`: VBoxManage **not on `PATH`**) |
| KotOR `AGENTS.md` | **Done** | Kinoite block + plan path |
| **Every plan YAML `id`** | **Done** | [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) |
| **Linux: declarative `rpm-ostree` + Flathub** (immutable OS provision) | **In tree** | [`PROVISION`](PROVISION), [`config/rpm-ostree/layers.list`](config/rpm-ostree/layers.list), [`scripts/apply-atomic-provision.sh`](scripts/apply-atomic-provision.sh), optional boot [`config/systemd/kinoite-atomic-ostree.service`](config/systemd/kinoite-atomic-ostree.service) via [`scripts/install-atomic-provision-service.sh`](scripts/install-atomic-provision-service.sh) — run **inside** the distro; layers need **reboot** to finalize |

**Last update:** 2026-04-25 — full **[`run-full-plan-capture.ps1`](scripts/run-full-plan-capture.ps1)**; manifest **`CAPTURE-MANIFEST-20260425T175108`** = current **Windows 11 + WSL** evidence index in git.
