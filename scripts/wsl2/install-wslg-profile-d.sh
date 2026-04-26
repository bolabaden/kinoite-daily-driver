#!/usr/bin/env bash
# Install config/wsl2/profile.d-00-kinoite-wslg-env.sh.example -> /etc/profile.d/00-kinoite-wslg-env.sh
# Run inside WSL: sudo ./scripts/wsl2/install-wslg-profile-d.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo." >&2
  exit 1
fi

if [ ! -e /proc/version ] || ! grep -qi microsoft /proc/version; then
  echo "This host does not look like WSL2; refusing to install WSLg profile.d snippet." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC="$REPO_ROOT/config/wsl2/profile.d-00-kinoite-wslg-env.sh.example"
DEST=/etc/profile.d/00-kinoite-wslg-env.sh

if [ ! -f "$SRC" ]; then
  echo "Missing $SRC" >&2
  exit 1
fi

install -m 0644 "$SRC" "$DEST"
echo "Installed $DEST (new logins will source it)."
