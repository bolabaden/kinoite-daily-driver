#!/usr/bin/env bash
# Bash AIO: mirrors Kinoite-AIO.ps1 for git-bash, native Linux, and WSL.
# Windows-only steps invoke PowerShell when available; WSL dist steps use wsl.exe from
# Windows or run in-place on Linux/WSL.
# Env: KINOITE_AIO_RUN, KINOITE_DISTRO, KINOITE_WORKSPACE_ROOT
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=${KINOITE_WORKSPACE_ROOT:-$(cd "$HERE/.." && pwd)}
REPO=$(cd "$REPO" && pwd)
export KINOITE_WORKSPACE_ROOT="$REPO"
cd "$REPO"
DISTRO=${KINOITE_DISTRO:-Kinoite-WS2}
export KINOITE_DISTRO="$DISTRO"

# Windows Git Bash / MSYS: can call powershell.exe; true WSL has no .exe in PATH
_in_wsl() { [[ -e /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version; }
_win_git_bash() { [[ "${OSTYPE:-}" == msys* ]] || [[ "${OSTYPE:-}" == cygwin* ]]; }
_powershell() {
  if _win_git_bash; then
    if command -v powershell.exe &>/dev/null; then echo powershell.exe; return; fi
    if [ -f "/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" ]; then
      echo /c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe; return; fi
  fi
  if command -v pwsh &>/dev/null; then echo pwsh; return; fi
  if command -v powershell &>/dev/null; then echo powershell; return; fi
  return 1
}
HAS_PS=$(_powershell 2>/dev/null || true)

# Repo path as seen inside a WSL distro (wsl -e bash -lc …)
# Windows drive paths -> /mnt/letter/... ; leave POSIX paths unchanged.
win_to_wsl() {
  local w="$1"
  if [[ "$w" =~ ^([A-Za-z]):[\\/] ]]; then
    local d="${BASH_REMATCH[1],,}"
    local r="${w:3}"
    r="${r//\\//}"
    echo "/mnt/$d/$r"
  else
    echo "$w"
  fi
}
WSL_ROOT=$(win_to_wsl "$REPO")

# From Git Bash, run command inside the configured WSL distro
wsl_bootstrap_apply() {
  local kind="$1"
  if _win_git_bash && command -v wsl.exe &>/dev/null; then
    if [[ "$kind" == boot ]]; then
      wsl.exe -d "$DISTRO" -e bash -lc "set -e; cd '$WSL_ROOT' && bash ./scripts/bootstrap-kinoite-wsl2.sh run"
    else
      wsl.exe -d "$DISTRO" -e bash -lc "set -e; cd '$WSL_ROOT' && sudo ./scripts/apply-atomic-provision.sh"
    fi
  elif _in_wsl; then
    if [[ "$kind" == boot ]]; then
      bash "$REPO/scripts/bootstrap-kinoite-wsl2.sh" run
    else
      sudo -E bash -lc "cd '$REPO' && ./scripts/apply-atomic-provision.sh"
    fi
  elif [[ "$(uname -s 2>/dev/null)" == Linux ]]; then
    if [[ "$kind" == boot ]]; then
      bash "$REPO/scripts/bootstrap-kinoite-wsl2.sh" run
    else
      sudo -E bash -lc "cd '$REPO' && ./scripts/apply-atomic-provision.sh"
    fi
  else
    echo "Bootstrap/Apply: from Windows Git Bash use wsl.exe -d $DISTRO, or run inside WSL / Linux with repo at $REPO" >&2
    return 1
  fi
}

BANNER() {
  echo ""
  echo "  Kinoite AIO (bash) - dispatches to repo scripts. See scripts/COVERAGE.md. MapImports: sync Windows winget → host-local flatpak list."
  echo "  Windows: prefer PowerShell Kinoite-AIO.ps1 (used by: uv run kinoite-bootstrap-init on Windows)"
  echo ""
}

step_Import() {
  local ps; ps=$(_powershell 2>/dev/null) || true
  if [[ -n "$ps" ]] && _win_git_bash; then
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -ExecutionPolicy Bypass -File "$REPO/scripts/import-kinoite-rootfs-to-wsl.ps1" || return "$?"
  fi
  echo "-> Import: run on Windows: $REPO/scripts/import-kinoite-rootfs-to-wsl.ps1" >&2
  return 1
}

step_WslConfig() {
  local ps; ps=$(_powershell 2>/dev/null) || true
  if [[ -n "$ps" ]]; then
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -ExecutionPolicy Bypass -File "$REPO/scripts/wsl2/Install-WslHostConfig.ps1" -RepoRoot "$REPO" && return 0
  fi
  echo "-> WslConfig: run on Windows: $REPO/scripts/wsl2/Install-WslHostConfig.ps1" >&2
  return 1
}

step_ShowGui() {
  local ps; ps=$(_powershell || true)
  if [[ -n "$ps" ]]; then
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -ExecutionPolicy Bypass -File "$REPO/scripts/wsl2/Show-Kinoite-Gui.ps1" -Distro "$DISTRO" -Action Launch
    return 0
  fi
  echo "-> ShowGui needs Windows + PowerShell or use Plasma start inside WSL: scripts/wsl2/launch-kde-gui-wslg.sh" >&2
  return 1
}

step_FocusGui() {
  local ps; ps=$(_powershell || true)
  if [[ -n "$ps" ]]; then
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -File "$REPO/scripts/wsl2/Show-Kinoite-Gui.ps1" -Distro "$DISTRO" -Action Focus
    return 0
  fi
  return 1
}

step_LogonReg() {
  local ps; ps=$(_powershell || true)
  if [[ -n "$ps" ]]; then
    echo "-> LogonReg: must be elevated; running Register..." >&2
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -File "$REPO/scripts/wsl2/Kinoite-WindowsPlasmaLogon.ps1" -Register -Distro "$DISTRO" -WorkspaceRoot "$REPO" || return "$?"
    return 0
  fi
  echo "-> $REPO/scripts/wsl2/Kinoite-WindowsPlasmaLogon.ps1 -Register" >&2
  return 1
}

step_LogonRun() {
  local ps; ps=$(_powershell || true)
  if [[ -n "$ps" ]]; then
    MSYS2_ARG_CONV_EXCL= "$ps" -NoProfile -File "$REPO/scripts/wsl2/Kinoite-WindowsPlasmaLogon.ps1" -RunSession -Distro "$DISTRO" -WorkspaceRoot "$REPO" || return "$?"
    return 0
  fi
  return 1
}

step_WikiMenu() { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/Kinoite-Wiki.ps1" && return; echo "Install PowerShell (pwsh) for wiki TUI: https://github.com/powershell/powershell" >&2; return 1; }
step_WikiSync()  { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/Kinoite-Wiki.ps1" -Action Sync; }
step_WikiInit()  { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/Kinoite-Wiki.ps1" -Action Init; }
step_WikiGen()  { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/Kinoite-Wiki.ps1" -Action GenerateDocs; }
step_Inv()       { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/windows-inventory.ps1"; return "$?"; }
step_MdLinks()   { [[ -n "$HAS_PS" ]] && MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/check-md-links.ps1" -Root "$REPO"; return "$?"; }
step_Safe() {
  [[ -n "$HAS_PS" ]] || { echo "Safe bundle needs pwsh/powershell." >&2; return 1; }
  step_MdLinks || true
  step_WikiGen || true
  KINOITE_INVENTORY_MODE=all MSYS2_ARG_CONV_EXCL= "$HAS_PS" -NoProfile -File "$REPO/scripts/windows-inventory.ps1" || true
}
step_Bootstrap() { wsl_bootstrap_apply boot; }
step_Apply()     { wsl_bootstrap_apply apply; }

step_MapImports() {
  if command -v python3 &>/dev/null; then
    python3 "$REPO/scripts/sync_imports_to_provision.py" --repo "$REPO" "$@"
    return $?
  fi
  if command -v python &>/dev/null; then
    python "$REPO/scripts/sync_imports_to_provision.py" --repo "$REPO" "$@"
    return $?
  fi
  echo "MapImports: install Python 3 and run: python3 $REPO/scripts/sync_imports_to_provision.py --repo $REPO" >&2
  return 1
}

step_MigrateAppConfigs() {
  chmod +x "$REPO/scripts/migrate-app-config.sh" 2>/dev/null || true
  if _in_wsl || [[ "$(uname -s 2>/dev/null)" == Linux ]]; then
    env KINOITE_REPO_ROOT="$REPO" bash "$REPO/scripts/migrate-app-config.sh" run
    return $?
  fi
  if _win_git_bash && command -v wsl.exe &>/dev/null; then
    wsl.exe -d "$DISTRO" -e bash -lc "set -e; cd '$WSL_ROOT' && chmod +x scripts/migrate-app-config.sh && env KINOITE_REPO_ROOT='$WSL_ROOT' bash ./scripts/migrate-app-config.sh run"
    return $?
  fi
  echo "MigrateAppConfigs: run inside WSL or Linux with repo at $REPO" >&2
  return 1
}

# Single invoke by canonical id
invoke() {
  local n=$1
  case "$n" in
  Import)       step_Import ;;
  WslConfig)    step_WslConfig ;;
  ShowGui)      step_ShowGui ;;
  FocusGui)     step_FocusGui ;;
  LogonReg)     step_LogonReg ;;
  LogonRun)     step_LogonRun ;;
  WikiMenu)     step_WikiMenu ;;
  WikiSync)     step_WikiSync ;;
  WikiInit)     step_WikiInit ;;
  WikiGen)      step_WikiGen ;;
  Inv)          step_Inv ;;
  MdLinks)      step_MdLinks ;;
  Safe)         step_Safe ;;
  MapImports)   step_MapImports ;;
  Bootstrap)    step_Bootstrap ;;
  Apply)        step_Apply ;;
  MigrateAppConfigs) step_MigrateAppConfigs ;;
  *)            echo "Unknown: $n" >&2; return 1 ;;
  esac
}

# Same aliases as Kinoite-AIO.ps1
resolve() {
  local k="${1,,}"; k="${k// /}"
  case "$k" in
  import|rootfs) echo Import ;;
  wslconfig|wslhost|hostwsl|dotwslconfig) echo WslConfig ;;
  showgui|launch|plasma|gui) echo ShowGui ;;
  focus|focusgui) echo FocusGui ;;
  logonreg|logonregister|plasmalogon) echo LogonReg ;;
  logonrun) echo LogonRun ;;
  wikimenu|wiki) echo WikiMenu ;;
  wikisync|sync) echo WikiSync ;;
  wikiinit|initiwiki) echo WikiInit ;;
  wikigen|gendocs|generatedocs) echo WikiGen ;;
  inv|inventory|host) echo Inv ;;
  safe|devcheck) echo Safe ;;
  md|links|mdlinks) echo MdLinks ;;
  mapimports|syncprovision) echo MapImports ;;
  bootstrap|boot) echo Bootstrap ;;
  apply|provision) echo Apply ;;
  migrateappconfigs|migrateconfigs|appconfigs) echo MigrateAppConfigs ;;
  *) for id in Import WslConfig ShowGui FocusGui LogonReg LogonRun WikiMenu WikiSync WikiInit WikiGen Inv MdLinks Safe MapImports Bootstrap Apply MigrateAppConfigs; do
      [[ ${id,,} == "$k" ]] && { echo "$id"; return; }
    done; echo "" ;;
  esac
}

run_list() {
  local s=$1
  s=${s//%3B/,}
  s=${s//;/,}
  IFS=',' read -r -a PARTS <<< "$s"
  local p
  for p in "${PARTS[@]}"; do
    p=$(echo "$p" | tr -d ' ')
    [[ -z "$p" ]] && continue
    local id
    id=$(resolve "$p")
    if [[ -z "$id" ]]; then echo "Unknown token: $p" >&2; exit 2; fi
    echo "=== AIO: $id ==="
    invoke "$id" || true
  done
}

MENU() {
  BANNER
  echo "1 Import 2 WslConfig 3 ShowGui 4 Focus 5 LogonReg 6 LogonRun 7 WikiMenu 8 WikiSync 9 Inv 10 MdLinks 11 Safe 12 MapImports 13 Bootstrap 14 Apply 15 MigrateAppConfigs 0 exit  H help  R run list"
  read -r -p "Choice (default 7=WikiMenu): " c || c=
  c=${c:-7}
  case "$c" in
  0) exit 0 ;;
  1) invoke Import ;;
  2) step_WslConfig ;;
  3) step_ShowGui ;;
  4) step_FocusGui ;;
  5) step_LogonReg ;;
  6) step_LogonRun ;;
  7) step_WikiMenu ;;
  8) step_WikiSync ;;
  9) step_Inv ;;
  10) step_MdLinks ;;
  11) step_Safe ;;
  12) step_MapImports ;;
  13) step_Bootstrap ;;
  14) step_Apply ;;
  15) step_MigrateAppConfigs ;;
  h|H) BANNER; echo "Run:  $0 -Run MdLinks,Inv  or  KINOITE_AIO_RUN=MapImports,Bootstrap,Apply,MigrateAppConfigs" ;;
  r|R) read -r -p "Comma list: " L; run_list "$L" ;;
  *) rid=$(resolve "$c"); if [[ -n "$rid" ]]; then invoke "$rid"; else echo "1-15 or name"; fi ;;
  esac
}

# --- main ---
if [[ -n "${KINOITE_AIO_RUN:-}" ]] && [[ $# -eq 0 ]]; then
  BANNER
  run_list "$KINOITE_AIO_RUN"
  exit 0
fi

if [[ $# -ge 1 && ( $1 == -Run || $1 == run || $1 == -run ) ]]; then
  shift
  combined="${*:-${KINOITE_AIO_RUN:-}}"; combined=${combined//%3B/,}
  BANNER
  run_list "$combined"
  exit 0
fi

MENU
