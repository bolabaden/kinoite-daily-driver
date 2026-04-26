# KDE Plasma + WSLg — runtime completion bar (not automatic from git)

**This document defines “done” for an *interactive* desktop, not for markdown coverage.**

- Having **KDE/Plasma RPMs** and `plasmashell` on disk is **necessary** and **not sufficient**.
- **Documentation-only** or **appendix-75 complete** in KotOR + this repo does **not** prove: boot → login user → WSLg → working Plasma.

## What a coding agent in Cursor can and cannot do here

- **In scope from a shell:** `wsl -d Kinoite-WS2` probes, `rpm -q`, `ps`, `loginctl`, checking `/etc/wsl.conf`, running [`scripts/verify-kde-wsl2-runtime.sh`](../scripts/verify-kde-wsl2-runtime.sh) *after* you have a default user and a graphical session.
- **Out of scope unless you wire them in your IDE:** `windows-mcp`, **desktop-commander**, or any MCP that automates a **Windows desktop** or **WSLg window** was **not** available in the session that last edited this file. Treat any claim of “fully verified with those tools” as **user-provided** until attached to logs.

## Evidence run (2026-04-26) — what was actually true on the host

| Check | Result |
|-------|--------|
| `wsl -d Kinoite-WS2` | Starts; `Fedora 43` **Kinoite** userland, Plasma **6.6.4**-era packages present |
| `wsl: Failed to start the systemd user session for 'root'.` | Observed on entry — **root**-oriented WSL + systemd user do not match typical desktop flow |
| `wsl -d Kinoite-WS2 -e whoami` | **`root`** (default user for this import) |
| `loginctl list-sessions` | **No sessions.** (expected if only root, no GUI session) |
| `DISPLAY` / `WAYLAND_DISPLAY` in non-interactive `wsl -e bash -lc` | **Empty** (no WSLg client session in that path) |
| `command -v plasmashell` | **`/usr/sbin/plasmashell`** — binary present |
| `pgrep plasmashell` / full Plasma stack | **Not running** in that probe (no session started) |
| `getent passwd` (human login) | **No unprivileged “human” user** in the file — only **root** and system accounts |

**Conclusion:** the machine is **not** at “KDE fully configured and confirmed functional out of the box” until a **default non-root user** exists, **`/etc/wsl.conf`** has `[user] default=…` (see [wsl.conf.example](../config/wsl.conf.example)), you **`wsl --shutdown`** and re-enter, then start Plasma under WSLg per [kinoite-wsl2.md](kinoite-wsl2.md) **## Plasma / WSLg** (e.g. `dbus-run-session plasmashell`).

## Required steps (order)

1. **Create a normal user** (WSL is not “fully configured” for KDE while default login is `root` only). Use [`scripts/bootstrap-wsl-default-user.sh`](../scripts/bootstrap-wsl-default-user.sh) **inside** the distro as root, or:  
   `useradd -m -s /bin/bash -G wheel <name>` and `passwd <name>`.
2. **Set** `/etc/wsl.conf` `[user] default=<name>` (and keep `[boot] systemd=true`), then from **Windows:** `wsl --shutdown` → `wsl -d Kinoite-WS2` and confirm `whoami` is **not** `root`.
3. **WSLg:** from an interactive logon shell, `echo $DISPLAY` / `$WAYLAND_DISPLAY` should usually be set (WSLg). If not, see Microsoft WSLg troubleshooting.
4. **Plasma:** follow [kinoite-wsl2.md](kinoite-wsl2.md) **## Plasma / WSLg**; then run [../scripts/verify-kde-wsl2-runtime.sh](../scripts/verify-kde-wsl2-runtime.sh).
5. **Record** the exact working command(s) in [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) and, if you use external MCP tools, keep **command logs** or **screenshots** in `imports/` (sanitized) *if* you choose to commit evidence.

## Exit criteria (copy into WORKSPACE_STATUS when true)

- [ ] Default WSL user is **not** `root` (`/etc/wsl.conf` + `wsl` opens as your user).
- [ ] `loginctl` shows a **user** session (or you document WSLg-only session where loginctl stays empty, with evidence).
- [ ] `plasmashell` (or your chosen Plasma surface) is **running** and usable under WSLg.
- [ ] [../scripts/verify-kde-wsl2-runtime.sh](../scripts/verify-kde-wsl2-runtime.sh) **exit 0** in that context.

When all are checked, the **KDE runtime** line in [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) can move from **Not done** to **Done** with a **date** and the evidence pointer.
