#!/usr/bin/env bash
# Run on the Kinoite host as root: copies declarative config to /etc/kinoite-provision and
# wires systemd to apply rpm-ostree layers on boot. Flatpaks: run apply-atomic-provision.sh
# as your user after login (or sudo with SUDO_USER set).
set -euo pipefail
ROOT_UID=0
if [ "${EUID:-0}" -ne "$ROOT_UID" ]; then
  echo "Run as root: sudo $0 [default-linux-username]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_USER="${1:-}"

install -d -m 0755 /etc/kinoite-provision
cp -a "$REPO_ROOT/config/flatpak" /etc/kinoite-provision/
cp -a "$REPO_ROOT/config/rpm-ostree" /etc/kinoite-provision/
install -m 0755 "$REPO_ROOT/scripts/apply-atomic-provision.sh" /etc/kinoite-provision/apply-atomic-provision.sh

if [ -n "$TARGET_USER" ]; then
  printf '%s' "$TARGET_USER" >/etc/kinoite-provision/default-user
  chmod 0644 /etc/kinoite-provision/default-user
fi

if command -v systemctl &>/dev/null; then
  install -m 0644 "$REPO_ROOT/config/systemd/kinoite-atomic-ostree.service" /etc/systemd/system/kinoite-atomic-ostree.service
  systemctl daemon-reload
  systemctl enable kinoite-atomic-ostree.service
  echo "==> Enabled: kinoite-atomic-ostree.service (rpm-ostree layers on boot; reboot to apply if packages were added)."
  echo "==> Flatpaks: after login, run:  sudo -u YOURUSER env -i HOME=\$(getent passwd YOURUSER | cut -d: -f6) $REPO_ROOT/scripts/apply-atomic-provision.sh"
  echo "    (or)  sudo $REPO_ROOT/scripts/apply-atomic-provision.sh  # with SUDO_USER from sudo"
else
  echo "==> No systemctl; copied files to /etc/kinoite-provision only."
fi
exit 0
