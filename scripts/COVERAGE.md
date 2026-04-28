# Documentation to automation coverage

Maps primary docs to the **single entry** script and **non-interactive** env/flags. TUI is available where noted; same operations are reachable without prompts.

| Doc / section | Script | Non-interactive (env or flags) | Notes |
|---------------|--------|-------------------------------|--------|
| (hub) | [Kinoite-AIO.ps1](Kinoite-AIO.ps1) (same step IDs: [kinoite-aio.sh](kinoite-aio.sh)) | `KINOITE_AIO_RUN=Safe,MdLinks,...` (comma steps; `KINOITE_AIO_RUN` or `-Run`) | **Orchestrator only**; dispatches to other `*.ps1` and `wsl` — not a second package source |
| | **AIO step IDs:** `Import`, `WslConfig`, `ShowGui`, `FocusGui`, `LogonReg`, `LogonRun`, `WikiMenu`, `WikiSync`, `Inv`, `MdLinks`, `Safe`, `Bootstrap`, `Apply` + aliases: `WikiInit`, `WikiGen` | | See [Kinoite-AIO.ps1](Kinoite-AIO.ps1) `Get-StepList` and `$map` |
| [README.md](../README.md) — install path | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | `KINOITE_OCI_IMAGE`, `KINOITE_WSL_DO_IMPORT=1`, `KINOITE_WSL_INSTALL_DIR` | `-Interactive` |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | `KINOITE_INSTALL_WSLG_PROFILE=1`, `KINOITE_TUI_CHOICE=run\|menu`, `KINOITE_INTERACTIVE=0\|1`, `CI=1` | TUI: `./bootstrap-kinoite-wsl2.sh menu` (see script header) |
| | [apply-atomic-provision.sh](apply-atomic-provision.sh) | `KINOITE_SKIP_PROVISION_HOOKS`, `KINOITE_SKIP_FLATPAK`, `KINOITE_OSTREE_ONLY`, `KINOITE_PROVISION_CONFIG`, `KINOITE_NIGHT_COLOR_LIST` | `menu` / `KINOITE_INTERACTIVE=1`; subcommands: `kde-night-light`, `install-service`, … |
| [docs/kinoite-wsl2.md](../docs/kinoite-wsl2.md) | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | `WSLG_GUI_BACKEND`, `KINOITE_TUI_CHOICE`, `KINOITE_INTERACTIVE` | `menu` subcommand |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | `KINOITE_DISTRO`, `KINOITE_GUI_ACTION=Launch\|Focus\|Menu`, `KINOITE_WSL_BASH_INIT` | wsl.exe only; `-Interactive` |
| | [wsl2/Kinoite-WindowsPlasmaLogon.ps1](wsl2/Kinoite-WindowsPlasmaLogon.ps1) | `KINOITE_LOGON_AT_STARTUP`, `KINOITE_STOP_EXPLORER=1` | Task Scheduler; `-RunSession` |
| [docs/windows-migration.md](../docs/windows-migration.md) | [windows-inventory.ps1](windows-inventory.ps1) | `KINOITE_INVENTORY_MODE`: `all\|0\|full` or comma tokens `winget`, `cim\|cimwsl\|wsl`, `start\|startmenu`, `dism` | Switches: `-Winget`, `-CimWsl`, `-StartMenu`, `-Dism` (subset); `-Interactive` |
| [config/wsl2/README.md](../config/wsl2/README.md) | [wsl2/Install-WslHostConfig.ps1](wsl2/Install-WslHostConfig.ps1) (host `.wslconfig`); bootstrap WSLg `profile.d` | `-Force`; `KINOITE_INSTALL_WSLG_PROFILE=1` for Linux `sh` block | AIO step `WslConfig` |
| Wiki + Jekyll | [Kinoite-Wiki.ps1](Kinoite-Wiki.ps1) | `KINOITE_WIKI_ACTION=Init\|Sync\|GenerateDocs`, `KINOITE_WIKI_PUSH=1`, `KINOITE_WIKI_URL` | `-Action` same as `KINOITE_WIKI_ACTION`; `CI` skips menu |
| Link hygiene | [check-md-links.ps1](check-md-links.ps1) | `KINOITE_MD_LINK_ROOT` (default: repo parent of `scripts/`) | `-Interactive` chooses scan root |
| Provision list shape (CI) | [validate-provision-lists.sh](validate-provision-lists.sh) | (none) | [validate-provision-lists.yml](../.github/workflows/validate-provision-lists.yml) on `ubuntu-latest` |

CI: [markdown-link-check.yml](../.github/workflows/markdown-link-check.yml) uses **Windows PowerShell 5.1** (same as local `powershell.exe`). [validate-provision-lists.yml](../.github/workflows/validate-provision-lists.yml) uses **bash** (no Flathub network).

OS boundaries (not “scripts calling scripts” in-repo): `wsl.exe` from Windows, Task Scheduler, elevated one-off `dism` child, `bash -lc` with `exec` to one `.sh` file.
