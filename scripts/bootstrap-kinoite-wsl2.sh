#!/usr/bin/env bash
# Run INSIDE the Kinoite WSL distro after first login (not on Windows).
set -euo pipefail

echo "==> rpm-ostree status (baseline)"
rpm-ostree status || true

echo "==> Optionally upgrade (may require reboot via wsl --shutdown)"
echo "    sudo rpm-ostree upgrade"
echo "    Skip automatic upgrade in script to avoid unintended long operations."

if ! flatpak remote-list | grep -q flathub; then
  echo "==> Adding Flathub"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

echo "==> flatpak update (user)"
flatpak update -y || true

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -e /proc/version ] && grep -qi microsoft /proc/version && [ "${KINOITE_INSTALL_WSLG_PROFILE:-0}" = 1 ]; then
  echo "==> Installing /etc/profile.d WSLg env (KINOITE_INSTALL_WSLG_PROFILE=1)"
  SRC="$REPO_ROOT/config/wsl2/profile.d-00-kinoite-wslg-env.sh.example"
  DEST=/etc/profile.d/00-kinoite-wslg-env.sh
  if [ ! -f "$SRC" ]; then
    echo "Missing $SRC" >&2
    exit 1
  fi
  sudo install -m 0644 "$SRC" "$DEST"
  echo "Installed $DEST (new logins will source it)."
fi

echo "==> Declarative provision (edit lists, then run):"
echo "    sudo $REPO_ROOT/scripts/apply-atomic-provision.sh"
echo "    (config: $REPO_ROOT/config/rpm-ostree/layers.list  and  $REPO_ROOT/config/flatpak/*.list )"
echo "    See $REPO_ROOT/GETTING_STARTED.md (Step 3 — atomic provisioning)"
echo "==> Or one-off: flatpak install -y com.valvesoftware.Steam  (see config/flatpak/*.list)"
