#!/usr/bin/env bash
# Optional KDE / Plasma under WSL2 + WSLg when the session is partial (no SDDM).
# Defaults match scripts/wsl2/launch-kde-gui-wslg.sh: X11 (xcb) on :0 for reliable WSLg windows.
#
# Usage:
#   ./scripts/bootstrap-kde-wsl.sh hints     — tuning notes (effects, Wayland vs X11)
#   ./scripts/bootstrap-kde-wsl.sh plasma   — plasmashell only (START_KDE_APPS=0)
#   ./scripts/bootstrap-kde-wsl.sh launch   — full launcher (plasmashell + sample apps); default
#
# Run as your normal WSL user (not root). See config/wsl2/README.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LAUNCH="$ROOT/scripts/wsl2/launch-kde-gui-wslg.sh"

usage() {
  cat <<'EOF'
bootstrap-kde-wsl.sh — Plasma helpers for WSL2/WSLg

  hints              Print tuning notes (effects, X11 vs Wayland).
  plasma             Start plasmashell only (via launch-kde-gui-wslg.sh, START_KDE_APPS=0).
  launch | start     Full GUI launch (default): plasmashell + konsole/dolphin/systemsettings.

See config/wsl2/README.md. Run as normal user, not root.
EOF
}

cmd_hints() {
  cat <<'EOF'
Optional Plasma tuning under WSLg (no full SDDM session):

- Prefer the repo launcher (X11/xcb on :0) over raw Wayland for Qt — avoids windows that never map.
  Override: WSLG_GUI_BACKEND=wayland ./scripts/bootstrap-kde-wsl.sh launch

- Reduce load: plasmashell only — ./scripts/bootstrap-kde-wsl.sh plasma

- Desktop effects: in System Settings (if installed) or edit kwin / compositor settings to disable
  blur/transparency if the session is sluggish.

- WSLg env shims: see config/wsl2/profile.d-00-kinoite-wslg-env.sh.example

- If GUI never appears: smoke-wslg-gui.sh, then Focus-Kinoite-WslgWindow.ps1 (Windows).
EOF
}

cmd_plasma() {
  if [[ ! -f "$LAUNCH" ]]; then
    echo "error: missing $LAUNCH" >&2
    exit 1
  fi
  export START_KDE_APPS=0
  exec bash "$LAUNCH"
}

cmd_launch() {
  if [[ ! -f "$LAUNCH" ]]; then
    echo "error: missing $LAUNCH" >&2
    exit 1
  fi
  exec bash "$LAUNCH"
}

main() {
  case "${1:-launch}" in
    -h|--help|help) usage ;;
    hints) cmd_hints ;;
    plasma) cmd_plasma ;;
    launch|start) cmd_launch ;;
    *)
      echo "error: unknown command: ${1:-}" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
