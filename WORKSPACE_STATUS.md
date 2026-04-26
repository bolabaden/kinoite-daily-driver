# Workspace execution status

This file is the **authoritative** execution log. The spec lives in **KotOR.js** (`.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`); **this** path is what was run on the host.

| Check | Status | Notes |
|-------|--------|-------|
| Workspace at `G:\workspaces\Kinoite` | **Done** | `docs/provisional-configuration-index.md` = phase→artifact map |
| `KINOITE_WORKSPACE_ROOT` (optional) | **Doc-only** | In profile or [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example) |
| **Full plan capture (all Win11 + WSL evidence)** | **Done 2026-04-26** (index [`CAPTURE-MANIFEST.txt`](imports/CAPTURE-MANIFEST.txt)) | [`scripts/run-full-plan-capture.ps1`](scripts/run-full-plan-capture.ps1) overwrites **stable** names in `imports/`; bulk gitignored. **Optional `-SkipWinget`** = skip only export + `winget list` (faster; manifest `SKP` for that pair). The manifest also embeds **`wsl -l -v`** from System32 **wsl.exe** (separate from `wsl-*-verify.txt`). [Historical re-merge](scripts/merge-timestamped-imports.ps1) if `*-yyyyMMddTHHmmss.*` reappear. ARP, Appx, locale/net, Run, DISM/pnputil, in-distro verify, Start Menu, winget, etc. |
| Kinoite OCI + `wsl --import` | **Done** | `Kinoite-WS2` on `G:\WSL\Kinoite-WS2`; image `quay.io/.../kinoite:43` |
| `/etc/wsl.conf` `[boot] systemd=true` | **Present** | Confirmed in `imports/wsl-Kinoite-WS2-verify.txt` (ex-stamped runs may appear as `==== BEGIN` sections after a merge) |
| `rpm-ostree status` in WSL | **Documented** | *Not booted via libostree* in same verify file — expected for container import; see [kinoite-wsl2 — honesty](docs/kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) |
| **`winget export` (latest; full capture overwrites `imports/`)** | **Done 2026-04-26** | `imports/winget-export.json` |
| **`windows-inventory` (CIM+WSL+podman, same run)** | **Done 2026-04-26** | `imports/windows-inventory.txt` |
| TSV + `app-mapping.md` | **Done** | Plan table + links to `imports/` and manifest |
| `app-mapping` § when to keep Windows/VM | **Done** | Parity gaps, PUP/ARP note (ex-`docs/keep-windows.md`) |
| Host `~/.wslconfig` | **Template** | `config/.wslconfig.example` |
| Research (Tavily / URLs) | **In tree** | `research/*`, [docs/README — Research](docs/README.md#research-tavily-firecrawl-and-the-web) |
| Plan crosswalk | **Done** | [`docs/provisional-configuration-index.md`](docs/provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) (KotOR ↔ workspace matrix) |
| `kinoite-wsl2.md` VPN overlay | **Done** | **## VPN and overlay network stack** |
| **KotOR spec ↔ this tree (Phase A)** | **Done** | [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md) **## Spec and the KotOR.js repository**; [docs/provisional-configuration-index.md#plan-stipulated-file-tree](docs/provisional-configuration-index.md#plan-stipulated-file-tree) + [coverage matrix](docs/provisional-configuration-index.md#kotor-plan-and-workspace-coverage-matrix) |
| **KDE Plasma + WSLg (interactive runtime)** | **Not done (2026-04-26)** | RPMs + `plasmashell` on disk, but **`wsl -e whoami` = `root`**, `loginctl` = **no sessions**, no WSLg **DISPLAY** in a non-GUI `wsl -e` probe — see [kinoite-wsl2.md — runtime bar](docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg). “Done” = default **non-root** user, WSLg session, `plasmashell` **running**, [scripts/verify-kde-wsl2-runtime.sh](scripts/verify-kde-wsl2-runtime.sh) exit **0**; *windows-mcp* / *desktop-commander* are **user-tooling**, not assumed in this repo. |
| Phases A/B/C (definition) | **Done** | [provisional-configuration: phases DOD](docs/provisional-configuration-index.md#phases-definition-of-done) — **A** evidence in `imports/`; **B/C** repo docs + checklists **complete**; real VM/ISO and bare metal remain **on hardware** (e.g. `host-tools.txt`: VBoxManage **not on `PATH`**) — **KDE runtime** is a **separate** line above |
| KotOR `AGENTS.md` | **Done** | Kinoite block + plan path |
| **Every plan YAML `id` (75)** | **Done** | [docs/plan-frontmatter-coverage.md](docs/plan-frontmatter-coverage.md) (Appendix **C**); after KotOR `todos` edits run [scripts/verify-plan-frontmatter-coverage.ps1](scripts/verify-plan-frontmatter-coverage.ps1) or [scripts/verify-repo-health.ps1](scripts/verify-repo-health.ps1) (adds a markdown file-link check) |
| **Linux: declarative `rpm-ostree` + Flathub** (immutable OS provision) | **Applied 2026-04-26 on `Kinoite-WS2`** | [`scripts/apply-atomic-provision.sh`](scripts/apply-atomic-provision.sh) from `/mnt/g/workspaces/Kinoite`: **user** Flatpaks via `flatpak --user` + `dbus-run-session` when `/run/user/UID` absent; **`rpm-ostree install`** staged daily-driver layers. From Windows, **`wsl --shutdown` was run** in this session to relaunch the VM; re-run script shows **empty transaction** (layers already applied). WSL: **`rpm-ostree status` still “not booted via libostree”** (container import) — see [kinoite-wsl2 — honesty](docs/kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) — packages still **layered** in the read-only image stack. |

**Last update:** 2026-04-26 — `wsl --shutdown` executed from host after provisioning; post-restart `KINOITE_SKIP_FLATPAK=1` **apply** = empty rpm-ostree transaction. Captures use **stable** `imports/*` names; `run-full-plan-capture.ps1` can take **`-SkipWinget`**; **`CAPTURE-MANIFEST.txt`** embeds **`wsl -l -v`**. **`ratbagd` → `libratbag-ratbagd`**; Qalculate id **`io.github.Qalculate`**; **7zip** RPM; `*.sh` LF + [`.editorconfig`](.editorconfig). KDE runtime row unchanged.
