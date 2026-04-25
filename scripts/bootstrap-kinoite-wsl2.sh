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
echo "==> Declarative provision (edit lists, then run):"
echo "    sudo $REPO_ROOT/scripts/apply-atomic-provision.sh"
echo "    (config: $REPO_ROOT/config/rpm-ostree/layers.list  and  $REPO_ROOT/config/flatpak/*.list )"
echo "    See $REPO_ROOT/PROVISION"
echo "==> Or one-off: flatpak install -y com.valvesoftware.Steam  (see config/flatpak/*.list)"
