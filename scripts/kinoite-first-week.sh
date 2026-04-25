#!/usr/bin/env bash
# Run on a stable Kinoite install (typically bare metal / VM), not necessarily WSL.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "1) Declarative:  sudo $REPO_ROOT/scripts/apply-atomic-provision.sh  (and edit config/rpm-ostree/layers.list + config/flatpak/*.list first)"
echo "2) Or: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
echo "3) toolbox create || distrobox (optional)"
echo "4) rpm-ostree upgrade  (reboot to apply; only on real ostree-booted systems for full effect)"
echo "5) Optional boot-time layers:  sudo $REPO_ROOT/scripts/install-atomic-provision-service.sh YOURUSER"
