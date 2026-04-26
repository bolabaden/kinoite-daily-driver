#!/usr/bin/env bash
# Run inside WSL, as the non-root default user, AFTER starting a Plasma/WSLg session
# (e.g. interactive terminal, DISPLAY/WAYLAND from WSLg, plasmashell launched as in kinoite-wsl2.md).
set -euo pipefail
E=0
if [[ $(id -u) -eq 0 ]]; then
  echo "FAIL: run as a normal user, not root (systemd --user and Plasma are not a root-desktop flow)."
  exit 2
fi
if ! command -v plasmashell &>/dev/null; then
  echo "FAIL: plasmashell not on PATH (install plasma workspace / see kinoite-wsl2.md)"
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
