# Workspace execution status

This file is the **authoritative** execution log (the Cursor plan is **read-only** for the same content).

| Check | Status | Notes |
|-------|--------|-------|
| Workspace at `G:\workspaces\Kinoite` | **Done** | `docs/provisional-configuration-index.md` = phase→artifact map |
| `KINOITE_WORKSPACE_ROOT` (optional) | **Doc-only** | Set in shell/profile to this path if you want cross-tool consistency |
| Kinoite OCI pull + export + `wsl --import` | **Done** | `Kinoite-WS2` on `G:\WSL\Kinoite-WS2`; image `quay.io/.../kinoite:43` |
| `/etc/wsl.conf` `[boot] systemd=true` | **Present** | Minimal file in distro; **host** `wsl --shutdown` then restart **required** for a clean systemd bring-up (see [systemd in WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd)) |
| systemd health inside distro | **Observed 2026-04-25** | Long-running `wsl` check: `systemctl is-system-running` → `starting` + “failed to start user session for root” / earlier minimal-PATH check: no `/run/systemd` — **treat as “needs full shutdown or non-root user”**; re-run after `wsl --shutdown` |
| `rpm-ostree status` | **Expected fail** in Phase A | Container import → *not booted via libostree* — not a WSL “bug,” see `docs/systemd-rpm-ostree-wsl2-claims.md` |
| `winget export` refresh | **Done 2026-04-25** | `imports/winget-export-20260425T165851.json` (gitignored) — many `Installed package is not available from any source` lines = normal for Win32/MSIX/Steam game rows |
| TSV + daily-driver table in `docs/app-mapping.md` | **Done** | Plan table merged; re-export winget to diff |
| `docs/keep-windows.md` | **Expanded** | Parity gaps, VM note, PUP/ARP hygiene |
| Host `~/.wslconfig` | **Template** | `config/.wslconfig.example` |
| External research (Tavily) | **Fallback** | `tvly` not on PATH; see `research/kinoite-wsl-systemd-sources-2026-04-25.md` + `docs/research-workflow-tavily-firecrawl.md` |

**Last update:** 2026-04-25 (exhaustive configuration pass, git commit in this repo).
