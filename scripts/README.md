# Scripts index

Use this as a **single catalog**; you do not need to open every `*.ps1` / `*.sh` in tree order.

## WSL2 and WSLg

All WSL2- and WSLg-specific explanation (what each **script** does, troubleshooting, and **what to do instead on bare metal**) lives in **[config/wsl2/README.md](../config/wsl2/README.md)**. The **`scripts/wsl2/`** directory only contains the helper scripts that the config doc **references**; they are in the table below. (The old one-line `scripts/wsl2/README` was removed — use this file only.)

| Group | Script | Role |
|-------|--------|------|
| **Import WSL2** | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | Podman pull → export → `wsl --import` |
| | [bootstrap-wsl-default-user.sh](bootstrap-wsl-default-user.sh) | First user setup hints |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | After import: `rpm-ostree` / Flathub, points at apply + [GETTING_STARTED.md](../GETTING_STARTED.md) |
| **Kinoite provision (Linux)** | [apply-atomic-provision.sh](apply-atomic-provision.sh) | Main declarative apply (`config/`, [provision.d](provision.d/)) |
| | [install-atomic-provision-service.sh](install-atomic-provision-service.sh) | Optional systemd: layers at boot only |
| | [provision-locale.sh](provision-locale.sh) | One-shot locale from `host-local/locale.env` |
| | [apply-kde-night-light.sh](apply-kde-night-light.sh) | KDE night light from `config/kde/night-light/`; see [kde-daily-driver — Provisional KDE config](../docs/kde-daily-driver-recommendations.md#provisional-kde-config-in-repo-user-scope) |
| | [verify-flathub.sh](verify-flathub.sh) | Check Flathub remote |
| | [verify-kde-wsl2-runtime.sh](verify-kde-wsl2-runtime.sh) | WSLg + `plasmashell` bar; see [kinoite-wsl2 — runtime bar](../docs/kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg) |
| **Tooling / optional** | [appimage-fuse-atomic.sh](appimage-fuse-atomic.sh) | FUSE + AppImage on atomic |
| | — | [ides-and-terminals — quick distrobox](../docs/ides-and-terminals.md#quick-distrobox-mutable-dnf-in-a-box) (commands; former `distrobox-optional.sh` removed) |
| | [fedora-dnf-fallback.sh](fedora-dnf-fallback.sh) | Documented dnf-in-box; see [kinoite-wsl2 — optional classic Fedora](../docs/kinoite-wsl2.md#optional-classic-fedora-in-wsl) |
| | [flatpak-maintain.sh](flatpak-maintain.sh) | Repair/update user Flatpaks |
| | [kinoite-first-week.sh](kinoite-first-week.sh) | Post-install checklist |
| **Plasma in WSL** | [bootstrap-kde-wsl.sh](bootstrap-kde-wsl.sh) | KDE + WSLg path |
| **Windows inventory / capture** | [export-winget.ps1](export-winget.ps1) | `winget export` → `imports/winget-export.json` (gitignored via `*winget*`) |
| | [run-windows-inventory.ps1](run-windows-inventory.ps1) | CIM + WSL + podman → `imports/windows-inventory.txt` |
| | [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) | Start Menu + Desktop; pass **`-OutFile ..\imports\start-menu-shortcuts.txt`** to write under `imports/` |
| | [check-md-links.ps1](check-md-links.ps1) | Relative `](path)` targets in `*.md` (skips `.git` / `.history` / `.cursor` / `.firecrawl`); **exit 1** if any missing. **CI:** [`.github/workflows/markdown-link-check.yml`](../.github/workflows/markdown-link-check.yml) |
| | [verify-repo-health.ps1](verify-repo-health.ps1) | Same as **check-md-links** (convenience wrapper). **VS Code / Cursor:** [.vscode/tasks.json](../.vscode/tasks.json) — *Run Task* **Kinoite: check markdown links** |
| | *Capture output folder* | [`../imports/`](../imports/) — [§ The imports directory](#the-imports-directory) |
| **WSL2 / WSLg helpers** | [wsl2/Focus-Kinoite-WslgWindow.ps1](wsl2/Focus-Kinoite-WslgWindow.ps1) | Focus WSLg window (Windows) |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | Show GUI (Windows) |
| | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | Launch KDE in WSLg (Linux) |
| | [wsl2/install-wslg-profile-d.sh](wsl2/install-wslg-profile-d.sh) | Profile.d env for WSLg |
| | [wsl2/smoke-wslg-gui.sh](wsl2/smoke-wslg-gui.sh) | Quick GUI smoke test |

## The imports directory

Place **raw** Windows inventory output under **[`../imports/`](../imports/)** (sibling to `scripts/`). **Typical workflow:** from the repo root on Windows, run [export-winget.ps1](export-winget.ps1) and [run-windows-inventory.ps1](run-windows-inventory.ps1). Optionally run [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) with **`-OutFile`** pointing at `imports\…`. If you want a local index, create **`imports\CAPTURE-MANIFEST.txt`** on disk (gitignored with other `imports/*.txt`). **`.gitignore` excludes** most bulk exports; run **`git status`** before a push. A [`.gitkeep`](../imports/.gitkeep) can sit in `imports/` when the clone has not had a run yet.

| File pattern | Source script | Notes |
|--------------|---------------|--------|
| `CAPTURE-MANIFEST.txt` | (manual / local) | Optional index of what lives under `imports/` for this host |
| `winget-export.json` (gitignored via `*winget*`) | [export-winget.ps1](export-winget.ps1) | Many `not available from any source` / Steam / MSIX lines are **normal** |
| `windows-inventory.txt` | [run-windows-inventory.ps1](run-windows-inventory.ps1) | CIM OS, `wsl -l -v`, `wsl --version`, **podman** (stderr if VM not up) |
| `start-menu-shortcuts.txt` | [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) with `-OutFile` | Default without `-OutFile` is `%TEMP%\start-menu-shortcuts-YYYYMMDD.txt` |

Older capture artifacts (ARP CSV, Appx, DISM, etc.) may still exist on disk from prior runs; they are **not** produced by scripts in this repo anymore.

**Sanitization for sharing:** strip internal hostnames, e-mails, or one-off ARP junk before copying exports off this machine.

*Merged from the former `imports/README.md` — that file **removed**.*

## Post-provision hooks

Executable scripts under **`provision.d/`** run **after** Flatpak and `rpm-ostree` layering in [apply-atomic-provision.sh](apply-atomic-provision.sh), in **sorted** order.

### Rules

- Name hooks **`NN-descriptive-name.sh`** with a two-digit prefix (`10-`, `20-`, …).
- Mark them **executable** (`chmod +x`); non-executable files are skipped.
- Hooks must be **idempotent** — safe to run on every `apply-atomic-provision.sh` invocation.
- Skip all hooks: `KINOITE_SKIP_PROVISION_HOOKS=1 sudo ./scripts/apply-atomic-provision.sh`

### WSL vs bare metal

Use `grep -qi microsoft /proc/version` inside a hook if a step only applies on one environment. Do not assume Wi-Fi or `fwupd` exist under WSL.

### First-boot gating (optional)

To run a hook only until a marker exists:

```bash
MARK=/var/lib/kinoite-provision/hook-10-example.done
[ -f "$MARK" ] && exit 0
# ... work ...
touch "$MARK"
```

*Merged from the former `scripts/provision.d/README.md` — that file **removed**.*

**Documentation hub:** [docs/README.md](../docs/README.md) · [GETTING_STARTED.md](../GETTING_STARTED.md) · [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) (suggested order / reminders)
