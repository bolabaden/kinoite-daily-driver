#!/usr/bin/env bash
# Run on a stable Kinoite install (typically bare metal / VM), not necessarily WSL.
set -euo pipefail
echo "1) flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
echo "2) flatpak install -y <ids from ../config/flatpak/*.list>"
echo "3) toolbox create || distrobox (optional)"
echo "4) rpm-ostree upgrade (only on real ostree-booted systems)"
