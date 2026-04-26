#!/usr/bin/env bash
# Non-destructive Flatpak maintenance (no third-party updater required).
# Run as your desktop user, or: sudo -u YOURUSER ./scripts/flatpak-maintain.sh
# Optional: KINOITE_FLATPAK_PRUNE_UNUSED=1 also removes unused runtimes (review first).
set -euo pipefail

if ! command -v flatpak &>/dev/null; then
  echo "flatpak not installed." >&2
  exit 1
fi

echo "==> flatpak repair"
flatpak repair --user 2>/dev/null || flatpak repair 2>/dev/null || true

echo "==> flatpak update"
flatpak update -y

if [ "${KINOITE_FLATPAK_PRUNE_UNUSED:-0}" = 1 ]; then
  echo "==> flatpak uninstall --unused -y"
  flatpak uninstall --unused -y || true
fi

echo "==> Done."
