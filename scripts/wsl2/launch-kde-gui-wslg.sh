#!/usr/bin/env bash
# WSL2 + WSLg: start Plasma shell + KDE apps so windows show on Windows 11.
#
# Optional first argument:
#   (none)|launch|start — full GUI (default)
#   plasma              — plasmashell only (START_KDE_APPS=0)
#   smoke               — kdialog-only WSLg visibility test, then exit
#   verify|runtime      — check DISPLAY/WAYLAND + plasmashell (non-root); exit 0/1 (replaces verify-kde-wsl2-runtime.sh)
#   hints|help|-h|--help — tuning notes, then exit
#
# Microsoft’s X server on :0 is the most reliable path here (xdpyinfo reports “Microsoft Corporation”).
# If WAYLAND_DISPLAY stays set, Qt may pick Wayland and some setups never paint a window — so this
# script defaults to pure X11 (xcb) unless WSLG_GUI_BACKEND=wayland.
#
# Windows (repo path in WSL matches KINOITE_WORKSPACE_ROOT, e.g. D: -> /mnt/d/...):
#   wsl --shutdown
#   wsl -d Kinoite-WS2 -- bash /mnt/<d>/<path>/Kinoite/scripts/wsl2/launch-kde-gui-wslg.sh
# Or:  .\scripts\wsl2\Show-Kinoite-Gui.ps1
#
# Env:
#   START_PLASMASHELL=0     — skip plasmashell (default 1)
#   START_KDE_APPS=0       — skip konsole/dolphin/systemsettings (default 1)
#   WSLG_GUI_BACKEND=wayland — use Wayland Qt backend (default x11)

_cmd_verify() {
  local E=0
  if [[ $(id -u) -eq 0 ]]; then
    echo "FAIL: run as a normal user, not root (systemd --user and Plasma are not a root-desktop flow)." >&2
    exit 2
  fi
  if ! command -v plasmashell &>/dev/null; then
    echo "FAIL: plasmashell not on PATH (install plasma workspace / see kinoite-wsl2.md)" >&2
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
Plasma tuning under WSLg (no full SDDM session):

- Prefer this launcher (X11/xcb on :0) over raw Wayland for Qt — avoids windows that never map.
  Override: WSLG_GUI_BACKEND=wayland ./scripts/wsl2/launch-kde-gui-wslg.sh launch

- Reduce load: plasmashell only — ./scripts/wsl2/launch-kde-gui-wslg.sh plasma

- Desktop effects: disable blur/transparency in compositor settings if sluggish.

- WSLg env shims: `config/wsl2/README.md` fenced profile + `bootstrap-kinoite-wsl2.sh` (`KINOITE_INSTALL_WSLG_PROFILE=1`)
  Install: KINOITE_INSTALL_WSLG_PROFILE=1 ./scripts/bootstrap-kinoite-wsl2.sh

- If GUI never appears: ./scripts/wsl2/launch-kde-gui-wslg.sh smoke, then Show-Kinoite-Gui.ps1 -Focus (Windows).
EOF
}

case "${1:-}" in
  hints|help|-h|--help)
    _cmd_hints
    exit 0
    ;;
  verify|runtime)
    _cmd_verify
    ;;
  smoke)
    if [[ $(id -u) -eq 0 ]]; then
      echo "Run as your normal user (not root)." >&2
      exit 2
    fi
    export DISPLAY="${DISPLAY:-:0}"
    export QT_QPA_PLATFORM=xcb
    unset WAYLAND_DISPLAY || true
    exec kdialog --msgbox "WSLg GUI smoke test: if you see this, X11 + KDE can paint on Windows. Close to exit."
    ;;
  plasma)
    export START_KDE_APPS=0
    shift
    ;;
  launch|start)
    shift
    ;;
esac

if [[ -n "${1:-}" ]]; then
  echo "error: unexpected argument: $1 (try: hints, plasma, launch, smoke, verify)" >&2
  _cmd_hints >&2
  exit 1
fi

set -u

if [[ $(id -u) -eq 0 ]]; then
  echo "Run as your normal user (not root) for KDE apps." >&2
  exit 2
fi

LOG_DIR="/tmp/kinoite-wsl2-gui"
mkdir -p "$LOG_DIR"

_backend="${WSLG_GUI_BACKEND:-x11}"
_uid="$(id -u)"
_way="${WAYLAND_DISPLAY:-wayland-0}"

# D-Bus and portals still want a writable runtime dir; WSLg uses this path.
if [[ -S "/mnt/wslg/runtime-dir/${_way}" ]] || [[ -d /mnt/wslg/runtime-dir ]]; then
  export XDG_RUNTIME_DIR="/mnt/wslg/runtime-dir"
elif [[ -S "/run/user/${_uid}/${_way}" ]]; then
  export XDG_RUNTIME_DIR="/run/user/${_uid}"
fi

export DISPLAY="${DISPLAY:-:0}"

if [[ "$_backend" == "wayland" ]]; then
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}"
  export GDK_BACKEND="${GDK_BACKEND:-wayland}"
else
  # Force X11 stack on WSLg — avoids Qt choosing Wayland and silently not mapping a window.
  export XDG_SESSION_TYPE=x11
  export QT_QPA_PLATFORM=xcb
  export GDK_BACKEND=x11
  unset WAYLAND_DISPLAY
fi

run_gui() {
  local name="$1"
  shift
  # Run in a subshell so unset WAYLAND_DISPLAY applies even if parent had it.
  if [[ "$_backend" != "wayland" ]]; then
    nohup env DISPLAY="$DISPLAY" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" XDG_SESSION_TYPE=x11 \
      QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 \
      bash -c 'unset WAYLAND_DISPLAY 2>/dev/null; exec "$@"' bash "$@" \
      >>"$LOG_DIR/${name}.log" 2>&1 &
  else
    nohup env DISPLAY="$DISPLAY" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
      XDG_SESSION_TYPE=wayland QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}" GDK_BACKEND="${GDK_BACKEND:-wayland}" \
      bash -c 'exec "$@"' bash "$@" >>"$LOG_DIR/${name}.log" 2>&1 &
  fi
  echo "started ${name} (log: $LOG_DIR/${name}.log)"
  sleep 1
}

echo "WSLG_GUI_BACKEND=${_backend}"
echo "DISPLAY=${DISPLAY} XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>}"

if [[ "${START_PLASMASHELL:-1}" == "1" ]]; then
  if [[ "$_backend" != "wayland" ]]; then
    nohup env DISPLAY="$DISPLAY" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" XDG_SESSION_TYPE=x11 \
      QT_QPA_PLATFORM=xcb GDK_BACKEND=x11 \
      bash -c 'unset WAYLAND_DISPLAY 2>/dev/null; exec dbus-run-session -- plasmashell' \
      >>"$LOG_DIR/plasmashell.log" 2>&1 &
  else
    nohup env DISPLAY="$DISPLAY" XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
      XDG_SESSION_TYPE=wayland QT_QPA_PLATFORM=wayland GDK_BACKEND=wayland \
      dbus-run-session -- plasmashell >>"$LOG_DIR/plasmashell.log" 2>&1 &
  fi
  echo "started plasmashell (log: $LOG_DIR/plasmashell.log)"
  sleep 3
fi

# Apps: prefer kde-app when present (usually xcb); run_gui still wraps for env consistency.
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
echo "Smoke test: ./scripts/wsl2/launch-kde-gui-wslg.sh smoke"
echo "Logs: $LOG_DIR/*.log"
