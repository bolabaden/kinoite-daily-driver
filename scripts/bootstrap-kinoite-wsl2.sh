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

echo "==> Done. Suggested next installs (user chooses):"
echo "    flatpak install -y com.valvesoftware.Steam"
echo "    flatpak install -y org.mozilla.firefox"
echo "    flatpak install -y org.flameshot.Flameshot"
echo "See ../config/flatpak/*.list and ../docs/*.md"
