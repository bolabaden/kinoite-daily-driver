#!/usr/bin/env bash
# Minimal WSLg visibility test: KDE dialog on Microsoft X server (:0).
# Run from Windows (adjust distro name):
#   wsl -d Kinoite-WS2 -- bash /mnt/g/workspaces/Kinoite/scripts/wsl2/smoke-wslg-gui.sh
set -euo pipefail
if [[ $(id -u) -eq 0 ]]; then
  echo "Run as a normal user, not root." >&2
  exit 2
fi
export DISPLAY="${DISPLAY:-:0}"
export QT_QPA_PLATFORM=xcb
unset WAYLAND_DISPLAY || true
exec kdialog --msgbox "WSLg GUI smoke test: if you see this, X11 + KDE can paint on Windows. Close to exit."
