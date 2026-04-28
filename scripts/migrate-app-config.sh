#!/usr/bin/env bash
# Seed or migrate cross-platform app configs into the login user's XDG / Flatpak dirs.
# Run as that user (not root), or via sudo -E with SUDO_USER after flatpaks are installed.
#
# Apps: qBittorrent (Flatpak), Firefox / Thunderbird (Flatpak Mozilla paths), VS Code (Flatpak),
# Syncthing (config.xml → ~/.local/state or ~/.config).
#
# Env:
#   KINOITE_REPO_ROOT       — repo root (default: parent of scripts/)
#   KINOITE_WIN_USER        — Windows profile name under /mnt/c/Users (default: $USER)
#   KINOITE_QBIT_WINDOWS_ROOT — explicit AppData parent for qBittorrent-only overrides
#   KINOITE_RESET_*         — per-app: KINOITE_RESET_QBIT, KINOITE_RESET_FIREFOX, etc. =1 removes stamp
#   KINOITE_SKIP_APP_CONFIG — provision.d: skip all (handled upstream)

set -euo pipefail

REPO_ROOT="${KINOITE_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STAMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kinoite-provision"
mkdir -p "$STAMP_DIR"

WIN_USER="${KINOITE_WIN_USER:-${USER:-}}"
_appdata() { printf '/mnt/c/Users/%s/AppData' "$WIN_USER"; }

QBIT_APP_ID="org.qbittorrent.qBittorrent"
QBIT_VAR="$HOME/.var/app/$QBIT_APP_ID"
QBIT_CFG="$QBIT_VAR/config/qBittorrent"
QBIT_DATA="$QBIT_VAR/data/qBittorrent"

FF_APP_ID="org.mozilla.firefox"
FF_BASE="$HOME/.var/app/$FF_APP_ID"
# Flathub Firefox uses data/.mozilla/firefox; some versions use .mozilla under the app prefix.
FF_CANDIDATES=("$FF_BASE/data/.mozilla/firefox" "$FF_BASE/.mozilla/firefox")

TB_APP_ID="org.mozilla.Thunderbird"
TB_BASE="$HOME/.var/app/$TB_APP_ID"
TB_CANDIDATES=("$TB_BASE/data/.thunderbird" "$TB_BASE/.thunderbird")

CODE_APP_ID="com.visualstudio.code"
CODE_USER_FLAT="$HOME/.var/app/$CODE_APP_ID/config/Code/User"
VSCODE_APP_ID="org.vscodium.VSCodium"
VSCODE_USER_FLAT="$HOME/.var/app/$VSCODE_APP_ID/config/VSCodium/User"

_stamp() { touch "$STAMP_DIR/$1"; }
_have_stamp() { [[ -f "$STAMP_DIR/$1" ]]; }

_migrate_qbittorrent() {
  if ! command -v flatpak &>/dev/null; then
    echo "migrate-app-config: flatpak not found; skip qBittorrent"
    return 0
  fi
  if ! flatpak list --app 2>/dev/null | grep -q "$QBIT_APP_ID"; then
    echo "migrate-app-config: $QBIT_APP_ID not installed; skip qBittorrent"
    return 0
  fi

  if [[ "${KINOITE_RESET_QBIT:-0}" == 1 ]]; then
    rm -f "$STAMP_DIR/qbittorrent-flatpak.done"
  fi
  if _have_stamp "qbittorrent-flatpak.done" && [[ "${KINOITE_RESET_QBIT:-0}" != 1 ]]; then
    echo "migrate-app-config: qBittorrent stamp exists; skip (KINOITE_RESET_QBIT=1 to redo)"
    return 0
  fi

  local win_local win_roam
  win_local=""
  win_roam=""
  if [[ -n "${KINOITE_QBIT_WINDOWS_ROOT:-}" ]]; then
    win_local="${KINOITE_QBIT_WINDOWS_ROOT}/Local/qBittorrent"
    win_roam="${KINOITE_QBIT_WINDOWS_ROOT}/Roaming/qBittorrent"
  elif [[ -e /proc/version ]] && grep -qi microsoft /proc/version; then
    local u="$WIN_USER"
    if [[ -d "/mnt/c/Users/$u/AppData/Local/qBittorrent" ]]; then
      win_local="/mnt/c/Users/$u/AppData/Local/qBittorrent"
      win_roam="/mnt/c/Users/$u/AppData/Roaming/qBittorrent"
    fi
  fi

  if [[ -z "$win_local" ]] || [[ ! -d "$win_local/BT_backup" ]]; then
    echo "migrate-app-config: no Windows qBittorrent BT_backup found; seed templates if any"
    if [[ -d "$REPO_ROOT/config/user-templates/qbittorrent" ]] && [[ -n "$(ls -A "$REPO_ROOT/config/user-templates/qbittorrent" 2>/dev/null)" ]]; then
      mkdir -p "$QBIT_CFG" "$QBIT_DATA"
      cp -a "$REPO_ROOT/config/user-templates/qbittorrent/." "$QBIT_CFG/" 2>/dev/null || true
    fi
    _stamp "qbittorrent-flatpak.done"
    return 0
  fi

  mkdir -p "$QBIT_CFG" "$QBIT_DATA"
  if [[ -d "$win_local/BT_backup" ]]; then
    mkdir -p "$QBIT_DATA/BT_backup"
    cp -a "$win_local/BT_backup/." "$QBIT_DATA/BT_backup/"
  fi
  for f in qBittorrent.ini qBittorrent.conf; do
    if [[ -f "$win_local/$f" ]]; then
      cp -a "$win_local/$f" "$QBIT_CFG/qBittorrent.conf" 2>/dev/null || cp -a "$win_local/$f" "$QBIT_CFG/"
      break
    fi
  done
  if [[ -d "$win_roam" ]]; then
    for f in qBittorrent.ini qBittorrent.conf; do
      if [[ -f "$win_roam/$f" ]] && [[ ! -f "$QBIT_CFG/qBittorrent.conf" ]]; then
        cp -a "$win_roam/$f" "$QBIT_CFG/qBittorrent.conf" 2>/dev/null || true
      fi
    done
  fi

  echo "migrate-app-config: copied qBittorrent from Windows — verify download paths in UI."
  _stamp "qbittorrent-flatpak.done"
}

_ff_dest() {
  for d in "${FF_CANDIDATES[@]}"; do
    if [[ -d "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  # Prefer data tree for new profiles
  echo "$FF_BASE/data/.mozilla/firefox"
}

_migrate_firefox() {
  if ! command -v flatpak &>/dev/null || ! flatpak list --app 2>/dev/null | grep -q "$FF_APP_ID"; then
    return 0
  fi
  if [[ "${KINOITE_RESET_FIREFOX:-0}" == 1 ]]; then
    rm -f "$STAMP_DIR/firefox-flatpak.done"
  fi
  if _have_stamp "firefox-flatpak.done" && [[ "${KINOITE_RESET_FIREFOX:-0}" != 1 ]]; then
    echo "migrate-app-config: Firefox stamp exists; skip (KINOITE_RESET_FIREFOX=1 to redo)"
    return 0
  fi
  local src="/mnt/c/Users/$WIN_USER/AppData/Roaming/Mozilla/Firefox"
  [[ ! -d "$src" ]] && return 0
  local dest
  dest="$(_ff_dest)"
  mkdir -p "$(dirname "$dest")"
  echo "migrate-app-config: copy Firefox profile from Windows -> $dest"
  if command -v rsync &>/dev/null; then
    rsync -a --delete "$src/" "$dest/" || cp -a "$src/." "$dest/"
  else
    mkdir -p "$dest"
    cp -a "$src/." "$dest/"
  fi
  _stamp "firefox-flatpak.done"
}

_tb_dest() {
  for d in "${TB_CANDIDATES[@]}"; do
    if [[ -d "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  echo "$TB_BASE/data/.thunderbird"
}

_migrate_thunderbird() {
  if ! command -v flatpak &>/dev/null || ! flatpak list --app 2>/dev/null | grep -q "$TB_APP_ID"; then
    return 0
  fi
  if [[ "${KINOITE_RESET_THUNDERBIRD:-0}" == 1 ]]; then
    rm -f "$STAMP_DIR/thunderbird-flatpak.done"
  fi
  if _have_stamp "thunderbird-flatpak.done" && [[ "${KINOITE_RESET_THUNDERBIRD:-0}" != 1 ]]; then
    echo "migrate-app-config: Thunderbird stamp exists; skip"
    return 0
  fi
  local src="/mnt/c/Users/$WIN_USER/AppData/Roaming/Thunderbird"
  [[ ! -d "$src" ]] && return 0
  local dest
  dest="$(_tb_dest)"
  mkdir -p "$(dirname "$dest")"
  if command -v rsync &>/dev/null; then
    rsync -a --delete "$src/" "$dest/" || cp -a "$src/." "$dest/"
  else
    mkdir -p "$dest"
    cp -a "$src/." "$dest/"
  fi
  echo "migrate-app-config: Thunderbird profile copied — verify accounts."
  _stamp "thunderbird-flatpak.done"
}

_migrate_vscode() {
  if [[ "${KINOITE_RESET_VSCODE:-0}" == 1 ]]; then
    rm -f "$STAMP_DIR/vscode-flatpak.done"
  fi
  if _have_stamp "vscode-flatpak.done" && [[ "${KINOITE_RESET_VSCODE:-0}" != 1 ]]; then
    echo "migrate-app-config: VS Code/VSCodium stamp exists; skip"
    return 0
  fi
  local src="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User"
  [[ ! -d "$src" ]] && src="/mnt/c/Users/$WIN_USER/AppData/Code/User"
  [[ ! -d "$src" ]] && return 0

  if flatpak list --app 2>/dev/null | grep -q "$CODE_APP_ID"; then
    mkdir -p "$CODE_USER_FLAT"
    if command -v rsync &>/dev/null; then
      rsync -a "$src/" "$CODE_USER_FLAT/" || cp -a "$src/." "$CODE_USER_FLAT/"
    else
      cp -a "$src/." "$CODE_USER_FLAT/"
    fi
    echo "migrate-app-config: VS Code User settings -> Flatpak $CODE_APP_ID"
    _stamp "vscode-flatpak.done"
    return 0
  fi
  if flatpak list --app 2>/dev/null | grep -q "$VSCODE_APP_ID"; then
    mkdir -p "$VSCODE_USER_FLAT"
    if command -v rsync &>/dev/null; then
      rsync -a "$src/" "$VSCODE_USER_FLAT/" || cp -a "$src/." "$VSCODE_USER_FLAT/"
    else
      cp -a "$src/." "$VSCODE_USER_FLAT/"
    fi
    echo "migrate-app-config: VS Code User settings copied to VSCodium layout — merge keys if needed."
    _stamp "vscode-flatpak.done"
    return 0
  fi
}

_migrate_syncthing() {
  if [[ "${KINOITE_RESET_SYNCTHING:-0}" == 1 ]]; then
    rm -f "$STAMP_DIR/syncthing-config.done"
  fi
  if _have_stamp "syncthing-config.done" && [[ "${KINOITE_RESET_SYNCTHING:-0}" != 1 ]]; then
    return 0
  fi
  local src="/mnt/c/Users/$WIN_USER/AppData/Local/Syncthing"
  [[ ! -f "$src/config.xml" ]] && return 0
  local dest="${XDG_STATE_HOME:-$HOME/.local/state}/syncthing"
  mkdir -p "$dest"
  cp -a "$src/config.xml" "$dest/config.xml"
  echo "migrate-app-config: Syncthing config.xml -> $dest — verify paths/device IDs."
  _stamp "syncthing-config.done"
}

_main() {
  case "${1:-run}" in
  run)
    _migrate_qbittorrent
    if [[ -e /proc/version ]] && grep -qi microsoft /proc/version; then
      _migrate_firefox
      _migrate_thunderbird
      _migrate_vscode
      _migrate_syncthing
    else
      echo "migrate-app-config: Firefox/Thunderbird/VS Code/Syncthing Windows paths skipped (not WSL); run under WSL with /mnt/c Users mounted or copy manually."
    fi
    ;;
  help|-h) sed -n '1,35p' "$0" ;;
  *) echo "usage: $0 [run|help]" >&2; exit 2 ;;
  esac
}

_main "$@"
