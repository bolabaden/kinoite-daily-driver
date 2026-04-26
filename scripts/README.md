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
| **Windows inventory / capture** | [run-full-plan-capture.ps1](run-full-plan-capture.ps1) | **One-shot** — overwrites `imports/*` **stable** names; index → `imports/CAPTURE-MANIFEST.txt` · **`-SkipWinget`** = skip `export-winget` + `winget list` (faster; leaves prior winget files on disk; manifest line `SKP` for that pair) · host phases logged as `[n/m]`; **`$TotalCaptureSteps = 16`** in the script (raise when adding a step) |
| | [export-winget.ps1](export-winget.ps1) | `winget export` only |
| | [run-windows-inventory.ps1](run-windows-inventory.ps1) | CIM + WSL + podman |
| | [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) | Start Menu + Desktop |
| | [merge-linux-map-stub.ps1](merge-linux-map-stub.ps1) | Map CSV merge helper |
| | [verify-plan-frontmatter-coverage.ps1](verify-plan-frontmatter-coverage.ps1) | Every plan `todos` `id` in [docs/plan-frontmatter-coverage.md](../docs/plan-frontmatter-coverage.md) |
| | [list-thin-docs.ps1](list-thin-docs.ps1) | Line-count on short `docs/*.md` |
| | [check-md-links.ps1](check-md-links.ps1) | **Optional:** print broken relative `](path)` file targets in `*.md` (skips `.git` / `.history` / `.cursor` / `.firecrawl`); **exit 1** if any missing; one **OK** line on success. **CI:** [`.github/workflows/markdown-link-check.yml`](../.github/workflows/markdown-link-check.yml) |
| | [verify-repo-health.ps1](verify-repo-health.ps1) | **Optional:** run **check-md-links** + **verify-plan-frontmatter-coverage** (first failure stops; for pre-commit / quick CI). **VS Code / Cursor:** [.vscode/tasks.json](../.vscode/tasks.json) — *Run Task* **Kinoite: verify repo health** or **Kinoite: check markdown links (only)** |
| | [inv-scoop-list.ps1](inv-scoop-list.ps1), [inv-hardware-outline.ps1](inv-hardware-outline.ps1), [inv-reliability-sample.ps1](inv-reliability-sample.ps1), [inv-startapps-sample.ps1](inv-startapps-sample.ps1) | Scoop, hardware, events, start apps (also in full capture) |
| | [sample-event-logs.ps1](sample-event-logs.ps1) | Event log sample |
| | *Capture output folder* + **stamp re-merge (optional)** | [`../imports/`](../imports/) — [§ The imports directory](#the-imports-directory) · [merge-timestamped-imports.ps1](merge-timestamped-imports.ps1) |
| **WSL2 / WSLg helpers** | [wsl2/Focus-Kinoite-WslgWindow.ps1](wsl2/Focus-Kinoite-WslgWindow.ps1) | Focus WSLg window (Windows) |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | Show GUI (Windows) |
| | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | Launch KDE in WSLg (Linux) |
| | [wsl2/install-wslg-profile-d.sh](wsl2/install-wslg-profile-d.sh) | Profile.d env for WSLg |
| | [wsl2/smoke-wslg-gui.sh](wsl2/smoke-wslg-gui.sh) | Quick GUI smoke test |

## The imports directory

Place **raw** Windows inventory output under **[`../imports/`](../imports/)** (sibling to `scripts/`). The committed **“current”** filenames for this host (after a fresh capture) also appear in [`../WORKSPACE_STATUS.md`](../WORKSPACE_STATUS.md), [`../docs/app-mapping.md`](../docs/app-mapping.md), and the run index **`CAPTURE-MANIFEST.txt`**, produced by [`run-full-plan-capture.ps1`](run-full-plan-capture.ps1) (unignored in root `.gitignore` so the manifest can be committed). The same run overwrites stable names: `winget-export.json`, `winget-list.txt`, `windows-inventory.txt`, etc. **`.gitignore` excludes the usual patterns**; so a normal `git add` will not pick up bulk exports. Run `git status` before a push if you add new name patterns. A [`.gitkeep`](../imports/.gitkeep) can sit alongside manifests when a clone has not yet had a run.

| File pattern | Source script | Notes |
|--------------|---------------|--------|
| `CAPTURE-MANIFEST.txt` | [run-full-plan-capture.ps1](run-full-plan-capture.ps1) | **Commit-friendly** list of the current `imports/*` set, short notes (run id in the file body), plus a `wsl -l -v` table from `%WINDIR%\System32\wsl.exe` (UTF-8; avoids `cmd` PATH/encoding issues) |
| `winget-export.json` (gitignored via `*winget*`) | [run-full-plan-capture.ps1](run-full-plan-capture.ps1) or [export-winget.ps1](export-winget.ps1) | Many `not available from any source` / Steam / MSIX lines are **normal** |
| `windows-inventory.txt` | [run-windows-inventory.ps1](run-windows-inventory.ps1) (or full-capture) | CIM OS, `wsl -l -v`, `wsl --version`, **podman** (stderr if VM not up) |
| `registry-uninstall.csv` | [run-full-plan-capture.ps1](run-full-plan-capture.ps1) | Add/Remove Programs (ARP) export; join with [`../config/capture/linux-map.template.csv`](../config/capture/linux-map.template.csv) for Kinoite rows |
| `appx-packages.csv` | full-capture | Per-user Appx inventory |
| `host-locale-network.txt` | full-capture | Culture, timezone, language list, connection profiles; **Wi-Fi PSK never exported** (only `netsh wlan show profiles` names) |
| `run-keys.txt` | full-capture | HKCU/HKLM `Run` values |
| `dism-features.txt`, `pnputil-drivers.txt` | full-capture | Optional; elevation improves usefulness |
| (optional) hardware / scoop / events / shortcuts | `inv-*.ps1`, `sample-event-logs.ps1`, [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) | Full-capture uses stable names, e.g. `start-menu-shortcuts.txt` under `imports/`, with **`-OutFile`**, not only `%TEMP%` |

**Start Menu / Desktop** shortcuts: standalone [list-windows-shortcuts.ps1](list-windows-shortcuts.ps1) defaults to **`%TEMP%`**; **`run-full-plan-capture.ps1`** writes **`start-menu-shortcuts.txt`** under **`imports/`** and lists it in the manifest.

**Plan YAML sync:** if **`kinoite_wsl_workspace_ec9c3c8b.plan.md`** `todos` in KotOR change, run [verify-plan-frontmatter-coverage.ps1](verify-plan-frontmatter-coverage.ps1) and refresh [`../docs/plan-frontmatter-coverage.md`](../docs/plan-frontmatter-coverage.md) (Appendix C) as needed; **or** run [verify-repo-health.ps1](verify-repo-health.ps1) to also scan markdown links first. **Inventory files in `imports/`** are unrelated to that check.

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

**Documentation hub:** [docs/README.md](../docs/README.md) · [GETTING_STARTED.md](../GETTING_STARTED.md) · [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md)
