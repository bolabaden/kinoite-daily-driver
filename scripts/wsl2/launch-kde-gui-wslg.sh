#!/usr/bin/env bash
# WSL2 + WSLg / VcXsrv: KDE Plasma on Windows-hosted Linux. Single entrypoint for GUI launch paths.
# Repository scripts do not call other repo scripts; OS use: wsl.exe, optional Task Scheduler (see
# Kinoite-WindowsPlasmaLogon.ps1 on Windows). Start Plasma as your normal user, not root.
#
# Subcommands (first argument):
#   (none)|launch|start  — full GUI (default) or TUI if KINOITE_INTERACTIVE=1
#   menu|tui             — interactive text menu (dialog, whiptail, or bash select)
#   plasma               — plasmashell only (START_KDE_APPS=0)
#   smoke                — kdialog WSLg visibility test
#   verify|runtime       — DISPLAY/WAYLAND + plasmashell; exit 0/1
#   hints|help|-h        — tuning notes
#   install-check        — plasmashell on PATH; hints for rpm-ostree / Kinoite layers
#   sddm-note            — when SDDM applies (bare metal vs WSL)
#   vcxsrv-hints         — VcXsrv on Windows + DISPLAY in WSL
#   wslg-config          — print effective WSLg-related env (non-destructive)
#
# Environment (non-interactive; also used after TUI selection):
#   WSLG_GUI_BACKEND=x11|wayland|vcxsrv
#   KINOITE_INTERACTIVE=0|1  — with no subcommand, if 1 and TTY, run menu before launch
#   KINOITE_MENU_BACKEND=auto|dialog|whiptail|readline
#   START_PLASMASHELL, START_KDE_APPS, DISPLAY (vcxsrv: set automatically if backend=vcxsrv)
#   CI=1 — never open interactive TUI
#   KINOITE_INSTALL_PLASMA=0|1  — with install-check: if 1, print sudo rpm-ostree suggestion (read-only)
#
# Microsoft’s X server on :0 (WSLg) is the default. VcXsrv: set WSLG_GUI_BACKEND=vcxsrv, start
# VcXsrv on Windows, DISPLAY becomes nameserver:0.0 in WSL.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="/tmp/kinoite-wsl2-gui"

_is_wsl() { [ -e /proc/version ] && grep -qi microsoft /proc/version; }

# --- VcXsrv: WSL1/WSL2 host IP from resolv (Windows 11 WSL2)
_vcxsrv_display() {
  local ns
  ns=$(grep -m1 '^nameserver' /etc/resolv.conf 2>/dev/null | awk '{print $2}') || true
  if [ -z "$ns" ]; then
    echo "error: vcxsrv: no nameserver in /etc/resolv.conf" >&2
    return 1
  fi
  echo "${ns}:0.0"
}

_cmd_wslg_config() {
  echo "=== WSLg / X11 config (read-only) ==="
  echo "WSLG_GUI_BACKEND=${WSLG_GUI_BACKEND:-x11}"
  _is_wsl && echo "WSL: yes" || echo "WSL: no"
  echo "DISPLAY=${DISPLAY-}"
  echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY-}"
  echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR-}"
  echo "QT_QPA_PLATFORM=${QT_QPA_PLATFORM-}"
  if _is_wsl; then
    if [ -d /mnt/wslg ]; then
      echo "WSLg: /mnt/wslg present"
    else
      echo "WSLg: /mnt/wslg not found (WSL1 or older?)"
    fi
  fi
  echo "REPO_ROOT=$REPO_ROOT"
}

_cmd_sddm_note() {
  cat <<'EOF'
=== SDDM vs WSL2 ===
- Bare-metal / VM Kinoite: use SDDM (or GDM) as shipped — log in at the display manager; Plasma starts
  from the system session. Use: sudo systemctl enable --now sddm (or your spin’s default).
- WSL2: there is usually no local framebuffer session like SDDM. This repo’s GUI path is WSLg or VcXsrv
  and launching plasmashell (this script) as your WSL user — not a full display-manager stack inside WSL.
- Do not install an SDDM package inside WSL for “Plasma in WSL” unless you know you need a nested DM;
  the supported path is plasmashell + dbus-run-session (see: hints).
EOF
}

_cmd_vcxsrv_hints() {
  cat <<'EOF'
=== VcXsrv (Windows) + WSL ===
1. Install VcXsrv on Windows and run "XLaunch": disable access control; display 0; multiple clients.
2. In WSL before this script:
   export WSLG_GUI_BACKEND=vcxsrv
   export DISPLAY=…   # or let this script set it when you run: WSLG_GUI_BACKEND=vcxsrv ./launch-kde-gui-wslg.sh
3. This file computes DISPLAY=nameserver_from_etc_resolv:0.0 for WSL2 by default in vcxsrv mode.
4. WSL1: use the Windows host IP from the documentation for your WSL1 version; same DISPLAY pattern.
5. If WSLg and VcXsrv conflict, pick one backend for a session: either pure WSLg (default) or VcXsrv, not both.
EOF
}

_cmd_install_check() {
  echo "=== KDE Plasma / plasmashell check ==="
  if command -v plasmashell &>/dev/null; then
    echo "OK: plasmashell: $(command -v plasmashell)"
  else
    echo "FAIL: plasmashell not on PATH"
    if [ -x /usr/bin/rpm-ostree ] 2>/dev/null || command -v rpm-ostree &>/dev/null; then
      echo "Hint: add plasma-workspace (or your spin’s group) to config/rpm-ostree/layers.list then:"
      echo "  sudo $REPO_ROOT/scripts/apply-atomic-provision.sh"
      echo "Then: wsl --shutdown (WSL) or reboot (bare metal)"
    else
      echo "Hint: install the Plasma workspace group for your distribution (Kinoite ships Plasma by default on ISO)."
    fi
    if [ "${KINOITE_INSTALL_PLASMA:-0}" = 1 ] && [ "$(id -u)" -eq 0 ]; then
      echo "(KINOITE_INSTALL_PLASMA=1 and root) — edit layers and apply; this script does not run rpm-ostree for you here."
    fi
    return 1
  fi
  if command -v kdialog &>/dev/null; then
    echo "OK: kdialog: $(command -v kdialog)"
  else
    echo "Note: kdialog not found (optional; used by smoke test)"
  fi
  return 0
}

_cmd_verify() {
  local E=0
  if [[ $(id -u) -eq 0 ]]; then
    echo "FAIL: run as a normal user, not root (systemd --user and Plasma are not a root-desktop flow)." >&2
    exit 2
  fi
  if ! command -v plasmashell &>/dev/null; then
    echo "FAIL: plasmashell not on PATH (run: $0 install-check; see kinoite-wsl2.md)" >&2
    exit 2
  fi
  if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "WARN: DISPLAY and WAYLAND_DISPLAY unset — WSLg not active in this shell?"
    E=1
  fi
  if pgrep -x plasmashell &>/dev/null; then
    echo "OK: plasmashell is running (PID $(pgrep -x plasmashell | head -1))."
  else
    echo "FAIL: plasmashell is not running. From kinoite-wsl2.md, try: dbus-run-session plasmashell (under WSLg)"
    E=1
  fi
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    echo "OK: WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
  elif [[ -n "${DISPLAY:-}" ]]; then
    echo "OK: DISPLAY=$DISPLAY"
  fi
  exit "$E"
}

_cmd_hints() {
  cat <<'EOF'
Plasma tuning under WSLg (no full SDDM session in WSL):

- Prefer this launcher (X11/xcb on :0) over raw Wayland for Qt — avoids windows that never map.
  Override: WSLG_GUI_BACKEND=wayland ./scripts/wsl2/launch-kde-gui-wslg.sh launch

- Reduce load: plasmashell only — ./scripts/wsl2/launch-kde-gui-wslg.sh plasma

- WSLG_GUI_BACKEND=vcxsrv for VcXsrv with DISPLAY from Windows host — see: vcxsrv-hints

- WSLg env: config/wsl2/README.md + bootstrap: KINOITE_INSTALL_WSLG_PROFILE=1 ./scripts/bootstrap-kinoite-wsl2.sh

- SDDM on bare metal: ./scripts/wsl2/launch-kde-gui-wslg.sh sddm-note

- If GUI never appears: smoke, then Show-Kinoite-Gui.ps1 -Action Focus (Windows; uses wsl.exe only).

- Repository policy: this script does not call other .sh in the repo; from Windows, Show-Kinoite-Gui.ps1 invokes wsl.exe to run this file.
EOF
}

# --- TUI: same actions as non-interactive env vars ---------------------------------
_tui_run() {
  local choice be="${KINOITE_MENU_BACKEND:-auto}" title="Kinoite WSL2 / Plasma"
  if [ -n "${CI:-}" ] || [ ! -t 0 ]; then
    echo "Non-interactive or CI: set WSLG_GUI_BACKEND, or run: $0 help" >&2
    return 1
  fi
  if [ "$be" = "auto" ]; then
    if command -v dialog &>/dev/null; then
      be=dialog
    elif command -v whiptail &>/dev/null; then
      be=whiptail
    else
      be=readline
    fi
  fi
  case "$be" in
  dialog)
    if choice=$(dialog --stdout --menu "$title" 20 60 10 \
      launch "Full Plasma + apps" \
      plasma "plasmashell only" \
      smoke "WSLg smoke (kdialog)" \
      verify "Check runtime" \
      install-check "Check plasmashell install" \
      wslg-config "Print WSLg env" \
      vcxsrv-hints "VcXsrv help" \
      sddm-note "SDDM vs WSL" \
      hints "Full help text" 2>&1); then
      :
    else
      echo "cancelled" >&2
      return 1
    fi
    clear 2>/dev/null || true
    ;;
  whiptail)
    if choice=$(whiptail --title "$title" --menu "Choose" 20 60 10 \
      launch "Full Plasma + apps" \
      plasma "plasmashell only" \
      smoke "WSLg smoke" \
      verify "Check runtime" \
      install-check "Check plasmashell" \
      wslg-config "Print env" \
      vcxsrv-hints "VcXsrv" \
      sddm-note "SDDM" \
      hints "Help" 2>&1); then
      :
    else
      return 1
    fi
    ;;
  readline|*)
    echo "=== $title (bash select) ==="
    PS3="Action (number): "
    select choice in launch plasma smoke verify install-check wslg-config vcxsrv-hints sddm-note hints "quit"; do
      [ "$choice" = "quit" ] && return 0
      [ -n "$choice" ] && break
    done
    ;;
  esac
  case "$choice" in
  launch|plasma|smoke|verify|install-check|wslg-config|vcxsrv-hints|sddm-note|hints)
    set +e
    exec "$0" "$choice"
    ;;
  *)
    echo "unknown: $choice" >&2
    return 1
    ;;
  esac
}

# First-argument dispatch (no set -u yet for optional env)
sub="${1:-}"
# Non-interactive env mirrors TUI: KINOITE_TUI_CHOICE
if [ -n "${KINOITE_TUI_CHOICE:-}" ] && [ -z "$sub" ]; then
  set -- "$KINOITE_TUI_CHOICE" "${@:2}"
  sub="${1:-}"
fi

case "$sub" in
hints|help|-h|--help) _cmd_hints; exit 0 ;;
verify|runtime) _cmd_verify ;;
smoke) ;;
plasma) ;;
launch|start) ;;
menu|tui) shift; _tui_run "$@"; exit $? ;;
wslg-config) _cmd_wslg_config; exit 0 ;;
sddm-note) _cmd_sddm_note; exit 0 ;;
vcxsrv-hints) _cmd_vcxsrv_hints; exit 0 ;;
install-check) _cmd_install_check; exit $? ;;
"")
  if [ "${KINOITE_INTERACTIVE:-0}" = 1 ] && [ -z "${CI:-}" ] && [ -t 0 ]; then
    _tui_run || { echo "Falling through to default launch…" >&2; }
  fi
  ;;
*)
  if [ -n "$sub" ]; then
    echo "error: unknown argument: $1 (try: help, menu, launch, plasma, smoke, verify, install-check)" >&2
    _cmd_hints >&2
    exit 1
  fi
  ;;
esac

# --- smoke (needs non-root) ---
if [ "${1:-}" = "smoke" ]; then
  if [[ $(id -u) -eq 0 ]]; then
    echo "Run as your normal user (not root)." >&2
    exit 2
  fi
  export DISPLAY="${DISPLAY:-:0}"
  export QT_QPA_PLATFORM=xcb
  unset WAYLAND_DISPLAY || true
  exec kdialog --msgbox "WSLg GUI smoke test: if you see this, X11 + KDE can paint on Windows. Close to exit."
fi

# plasma / launch: strip optional first token
if [ "${1:-}" = "plasma" ]; then
  export START_KDE_APPS=0
  shift
elif [ "${1:-}" = "launch" ] || [ "${1:-}" = "start" ]; then
  shift
fi

if [[ -n "${1:-}" ]]; then
  echo "error: unexpected argument: $1" >&2
  _cmd_hints >&2
  exit 1
fi

set -u

if [[ $(id -u) -eq 0 ]]; then
  echo "Run as your normal user (not root) for KDE apps." >&2
  exit 2
fi

# Optional pre-flight
if [ "${KINOITE_PREFLIGHT_CHECK:-0}" = 1 ]; then
  _cmd_install_check || true
fi

mkdir -p "$LOG_DIR"
USER_BACKEND="${WSLG_GUI_BACKEND:-x11}"
# vcxsrv: DISPLAY to Windows X server; then treat as X11 for Qt
if [ "$USER_BACKEND" = "vcxsrv" ]; then
  export DISPLAY="${DISPLAY:-$(_vcxsrv_display)}"
  export WSLG_GUI_BACKEND=x11
  export XDG_SESSION_TYPE=x11
  export QT_QPA_PLATFORM=xcb
  export GDK_BACKEND=x11
  unset WAYLAND_DISPLAY || true
  USER_BACKEND=x11
fi
_eff="${WSLG_GUI_BACKEND:-x11}"
_uid="$(id -u)"
_way="${WAYLAND_DISPLAY:-wayland-0}"

if [[ -S "/mnt/wslg/runtime-dir/${_way}" ]] || [[ -d /mnt/wslg/runtime-dir ]]; then
  export XDG_RUNTIME_DIR="/mnt/wslg/runtime-dir"
elif [[ -S "/run/user/${_uid}/${_way}" ]]; then
  export XDG_RUNTIME_DIR="/run/user/${_uid}"
fi

if [ "$_eff" = "wayland" ]; then
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}"
  export GDK_BACKEND="${GDK_BACKEND:-wayland}"
else
  export DISPLAY="${DISPLAY:-:0}"
  export XDG_SESSION_TYPE=x11
  export QT_QPA_PLATFORM=xcb
  export GDK_BACKEND=x11
  unset WAYLAND_DISPLAY || true
fi

run_gui() {
  local name="$1"
  shift
  if [[ "$_eff" = "wayland" ]]; then
    nohup env DISPLAY="${DISPLAY:-}" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
      XDG_SESSION_TYPE=wayland QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}" GDK_BACKEND="${GDK_BACKEND:-wayland}" \
      bash -c 'exec "$@"' bash "$@" >>"$LOG_DIR/${name}.log" 2>&1 &
  else
    nohup env DISPLAY="${DISPLAY:-}" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" XDG_SESSION_TYPE=x11 \
      QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 \
      bash -c 'unset WAYLAND_DISPLAY 2>/dev/null; exec "$@"' bash "$@" \
      >>"$LOG_DIR/${name}.log" 2>&1 &
  fi
  echo "started ${name} (log: $LOG_DIR/${name}.log)"
  sleep 1
}

echo "WSLG_GUI_BACKEND=${WSLG_GUI_BACKEND:-x11} (effective session backend)"
echo "DISPLAY=${DISPLAY-} XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>}"

if [[ "${START_PLASMASHELL:-1}" == "1" ]]; then
  if [[ "$_eff" = "wayland" ]]; then
    nohup env DISPLAY="${DISPLAY:-}" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
      XDG_SESSION_TYPE=wayland QT_QPA_PLATFORM=wayland GDK_BACKEND=wayland \
      dbus-run-session -- plasmashell >>"$LOG_DIR/plasmashell.log" 2>&1 &
  else
    nohup env DISPLAY="${DISPLAY:-}" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" XDG_SESSION_TYPE=x11 \
      QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 \
      bash -c 'unset WAYLAND_DISPLAY 2>/dev/null; exec dbus-run-session -- plasmashell' \
      >>"$LOG_DIR/plasmashell.log" 2>&1 &
  fi
  echo "started plasmashell (log: $LOG_DIR/plasmashell.log)"
  sleep 3
fi

if [[ "${START_KDE_APPS:-1}" == "1" ]]; then
  if command -v kde-app &>/dev/null; then
    run_gui konsole kde-app konsole
    run_gui dolphin kde-app dolphin
    run_gui systemsettings kde-app systemsettings
  else
    run_gui konsole konsole
    run_gui dolphin dolphin
    run_gui systemsettings systemsettings
  fi
else
  echo "START_KDE_APPS=0 — skipping konsole/dolphin/systemsettings"
fi

sleep 2
echo "--- processes (best-effort) ---"
pgrep -a plasmashell 2>/dev/null || true
if [[ "${START_KDE_APPS:-1}" == "1" ]]; then
  pgrep -a konsole 2>/dev/null || true
  pgrep -a dolphin 2>/dev/null || true
  pgrep -a systemsettings 2>/dev/null || true
fi

echo ""
echo "Logs: $LOG_DIR/*.log"
