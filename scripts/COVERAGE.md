# Documentation to automation coverage

Maps primary docs to the **single entry** script and **non-interactive** env/flags. TUI is available where noted; same operations are reachable without prompts.

| Doc / section | Script | Non-interactive (env or flags) | Notes |
|---------------|--------|-------------------------------|--------|
| (hub) | [Kinoite-AIO.ps1](Kinoite-AIO.ps1) | `KINOITE_AIO_RUN=Safe,MdLinks,...` | **Orchestrator only**; dispatches to other `*.ps1` and `wsl` |
| [README.md](../README.md) — install path | [import-kinoite-rootfs-to-wsl.ps1](import-kinoite-rootfs-to-wsl.ps1) | `KINOITE_OCI_IMAGE`, `KINOITE_WSL_DO_IMPORT=1`, `KINOITE_WSL_INSTALL_DIR` | `-Interactive` |
| | [bootstrap-kinoite-wsl2.sh](bootstrap-kinoite-wsl2.sh) | `KINOITE_INSTALL_WSLG_PROFILE=1`, `KINOITE_TUI_CHOICE=run` | `menu` / `KINOITE_INTERACTIVE=1` (WSL) |
| | [apply-atomic-provision.sh](apply-atomic-provision.sh) | `KINOITE_SKIP_*`, subcommands in `--help` | `menu` / `KINOITE_INTERACTIVE=1` |
| [docs/kinoite-wsl2.md](../docs/kinoite-wsl2.md) | [wsl2/launch-kde-gui-wslg.sh](wsl2/launch-kde-gui-wslg.sh) | `WSLG_GUI_BACKEND`, `KINOITE_TUI_CHOICE`, `KINOITE_INTERACTIVE` | `menu` subcommand |
| | [wsl2/Show-Kinoite-Gui.ps1](wsl2/Show-Kinoite-Gui.ps1) | `KINOITE_DISTRO`, `KINOITE_GUI_ACTION=Launch\|Focus\|Menu`, `KINOITE_WSL_BASH_INIT` | wsl.exe only; `-Interactive` |
| | [wsl2/Kinoite-WindowsPlasmaLogon.ps1](wsl2/Kinoite-WindowsPlasmaLogon.ps1) | `KINOITE_LOGON_AT_STARTUP`, `KINOITE_STOP_EXPLORER=1` | Task Scheduler; `-RunSession` |
| [docs/windows-migration.md](../docs/windows-migration.md) | [windows-inventory.ps1](windows-inventory.ps1) | `KINOITE_INVENTORY_MODE=winget,cim,start,dism` (comma tokens) | `-Interactive`; child PS for DISM UAC (see [AGENTS.md](../AGENTS.md)) |
| [config/wsl2/README.md](../config/wsl2/README.md) | Same WSL2 scripts + bootstrap WSLg profile | `KINOITE_INSTALL_WSLG_PROFILE=1` | Fenced `sh` block installed by bootstrap |
| Wiki + Jekyll | [Kinoite-Wiki.ps1](Kinoite-Wiki.ps1) | `KINOITE_WIKI_ACTION`, `KINOITE_WIKI_PUSH=1` | `-Action Init\|Sync\|GenerateDocs`; `CI` skips menu |
| Link hygiene | [check-md-links.ps1](check-md-links.ps1) | `KINOITE_MD_LINK_ROOT` | `-Interactive` |

CI: [markdown-link-check.yml](../.github/workflows/markdown-link-check.yml) uses **Windows PowerShell 5.1** (same as local `powershell.exe`).

OS boundaries (not “scripts calling scripts” in-repo): `wsl.exe` from Windows, Task Scheduler, elevated one-off `dism` child, `bash -lc` with `exec` to one `.sh` file.
