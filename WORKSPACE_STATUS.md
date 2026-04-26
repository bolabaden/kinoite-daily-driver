# Workspace execution status

This file is the **authoritative** execution log. The spec lives in **KotOR.js** (`.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`); **this** path is what was run on the host.

| Check | Status | Notes |
|-------|--------|-------|
| Workspace at `G:\workspaces\Kinoite` | **Done** | `docs/provisional-configuration-index.md` = phase→artifact map |
| `KINOITE_WORKSPACE_ROOT` (optional) | **Doc-only** | In profile or [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example) |
| **Full plan capture (all Win11 + WSL evidence)** | **Done 2026-04-26** (index [`CAPTURE-MANIFEST-20260426T011259.txt`](imports/CAPTURE-MANIFEST-20260426T011259.txt)) | [`scripts/run-full-plan-capture.ps1`](scripts/run-full-plan-capture.ps1) — **`imports/CAPTURE-MANIFEST-*.txt`** in repo; bulk gitignored. Includes ARP CSV, Appx CSV, locale/network (no PSK), Run keys, DISM/pnputil samples, `wsl-Kinoite-WS2-verify-*`, Start Menu shortcuts, winget export/list. |
| Kinoite OCI + `wsl --import` | **Done** | `Kinoite-WS2` on `G:\WSL\Kinoite-WS2`; image `quay.io/.../kinoite:43` |
| `/etc/wsl.conf` `[boot] systemd=true` | **Present** | Confirmed in `imports/wsl-Kinoite-WS2-verify-20260425T175108.txt` (same content as prior verify runs) |
| `rpm-ostree status` in WSL | **Documented** | *Not booted via libostree* in same verify file — expected for container import; see `docs/systemd-rpm-ostree-wsl2-claims.md` |
| **`winget export` (latest in last full capture)** | **Done 2026-04-25** | `imports/winget-export-20260425T175108.json` |
| **`windows-inventory` (CIM+WSL+podman, same run)** | **Done 2026-04-25** | `imports/windows-inventory-20260425T175121.txt` |
| TSV + `app-mapping.md` | **Done** | Plan table + links to `imports/` and manifest |
| `docs/keep-windows.md` | **Done** | Parity gaps, PUP/ARP note |
| Host `~/.wslconfig` | **Template** | `config/.wslconfig.example` |
| Research (Tavily / URLs) | **In tree** | `research/*`, `docs/research-workflow-tavily-firecrawl.md` |
| Plan crosswalk | **Done** | [`docs/provisional-configuration-index.md`](docs/provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) (matrix); [`docs/plan-alignment.md`](docs/plan-alignment.md) redirect |
| `kinoite-wsl2.md` VPN overlay | **Done** | **## VPN and overlay network stack** |
| **KotOR spec ↔ this tree (Phase A)** | **Done** | [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) **## Spec and the KotOR.js repository**; [docs/plan-stipulated-file-tree.md](docs/plan-stipulated-file-tree.md); [docs/provisional-configuration-index.md](docs/provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) |
| **KDE Plasma + WSLg (interactive runtime)** | **Not done (2026-04-26)** | RPMs + `plasmashell` on disk, but **`wsl -e whoami` = `root`**, `loginctl` = **no sessions**, no WSLg **DISPLAY** in a non-GUI `wsl -e` probe — see [docs/kde-wsl2-runtime-verification.md](docs/kde-wsl2-runtime-verification.md). “Done” = default **non-root** user, WSLg session, `plasmashell` **running**, [scripts/verify-kde-wsl2-runtime.sh](scripts/verify-kde-wsl2-runtime.sh) exit **0**; *windows-mcp* / *desktop-commander* are **user-tooling**, not assumed in this repo. |
| Phases A/B/C (definition) | **Done** | [docs/phases-definition-of-done.md](docs/phases-definition-of-done.md) — **A** evidence in `imports/`; **B/C** repo docs + checklists **complete**; real VM/ISO and bare metal remain **on hardware** (e.g. `host-tools-20260425T175108.txt`: VBoxManage **not on `PATH`**) — **KDE runtime** is a **separate** line above |
| KotOR `AGENTS.md` | **Done** | Kinoite block + plan path |
| **Every plan YAML `id` (75)** | **Done** | [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) (Appendix **C**); after KotOR `todos` edits run [scripts/verify-plan-frontmatter-coverage.ps1](scripts/verify-plan-frontmatter-coverage.ps1) |
| **Linux: declarative `rpm-ostree` + Flathub** (immutable OS provision) | **Applied 2026-04-26 on `Kinoite-WS2`** | [`scripts/apply-atomic-provision.sh`](scripts/apply-atomic-provision.sh) from `/mnt/g/workspaces/Kinoite`: **user** Flatpaks via `flatpak --user` + `dbus-run-session` when `/run/user/UID` absent; **`rpm-ostree install`** staged daily-driver layers. From Windows, **`wsl --shutdown` was run** in this session to relaunch the VM; re-run script shows **empty transaction** (layers already applied). WSL: **`rpm-ostree status` still “not booted via libostree”** (container import) — see `docs/systemd-rpm-ostree-wsl2-claims.md` — packages still **layered** in the read-only image stack. |

**Last update:** 2026-04-26 — `wsl --shutdown` executed from host after provisioning; post-restart `KINOITE_SKIP_FLATPAK=1` **apply** = empty rpm-ostree transaction. Full capture **20260426T011259**; prior: **`ratbagd` → `libratbag-ratbagd`**; Qalculate id **`io.github.Qalculate`**; **7zip** RPM; `*.sh` LF + [`.editorconfig`](.editorconfig). KDE runtime row unchanged.
