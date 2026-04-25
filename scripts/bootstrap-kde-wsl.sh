#!/usr/bin/env bash
# Optional: after a successful Plasma package install on WSL, try launching plasmashell under WSLg.
set -euo pipefail
echo "Attempt: dbus-run-session plasmashell (may fail without full session)"
echo "Run manually when dbus and display are available:"
echo "  dbus-run-session plasmashell"
