#!/usr/bin/env bash
# Run inside the Kinoite WSL distro, once, as root (e.g. wsl -d Kinoite-WS2 -u root).
# Container-import rootfs may have no unprivileged login user; KDE sessions expect a normal user.
set -euo pipefail
NAME="${1:-kinoiteuser}"
if id -u "$NAME" &>/dev/null; then
  echo "User already exists: $NAME (uid $(id -u "$NAME"))"
  exit 0
fi
useradd -m -s /bin/bash -G wheel "$NAME"
echo "Created user: $NAME"
echo "Set a password: passwd $NAME"
echo "Then add to /etc/wsl.conf under [user]:"
echo "  default=$NAME"
echo "On Windows: wsl --shutdown"
echo "Then: wsl -d Kinoite-WS2   # should not be root"
