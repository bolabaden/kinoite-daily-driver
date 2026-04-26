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
  README_WSL2="$REPO_ROOT/config/wsl2/README.md"
  DEST=/etc/profile.d/00-kinoite-wslg-env.sh
  TMP="$(mktemp)"
  tr -d '\r' <"$README_WSL2" | sed -n '/^```sh/,/^```$/p' | sed '1d;$d' >"$TMP"
  if [ ! -s "$TMP" ]; then
    echo "Failed to extract WSLg profile block from $README_WSL2 (need fenced \`\`\`sh ... \`\`\`)." >&2
    rm -f "$TMP"
    exit 1
  fi
  sudo install -m 0644 "$TMP" "$DEST"
  rm -f "$TMP"
  echo "Installed $DEST (new logins will source it)."
fi

echo "==> Declarative provision (edit lists, then run):"
echo "    sudo $REPO_ROOT/scripts/apply-atomic-provision.sh"
echo "    (config: $REPO_ROOT/config/rpm-ostree/layers.list  and  $REPO_ROOT/config/flatpak/kinoite.list  [+ optional extra *.list] )"
echo "    See $REPO_ROOT/README.md#step-3--edit-the-declarative-lists (Step 3 — declarative lists)"
echo "==> Or one-off: flatpak install -y com.valvesoftware.Steam  (see config/flatpak/kinoite.list)"
