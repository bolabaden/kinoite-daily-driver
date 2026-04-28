#!/usr/bin/env bash
# Emit ~/.config/autostart/*.desktop for Windows Run entries that map to installed Flatpaks.
# Reads REPO/imports/run-keys.txt (from windows-inventory.ps1 -RunKeys).
# Idempotent: same desktop basename overwrites. Gate with KINOITE_APPLY_AUTOSTART=1 from provision.d.
set -euo pipefail

REPO_ROOT="${KINOITE_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
RUN_KEYS="$REPO_ROOT/imports/run-keys.txt"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$DEST"

if [[ ! -f "$RUN_KEYS" ]]; then
  echo "generate-plasma-autostart: no $RUN_KEYS — capture host with windows-inventory.ps1 -RunKeys" >&2
  exit 0
fi

_flatpak_installed() {
  command -v flatpak &>/dev/null && flatpak list --app 2>/dev/null | grep -q "^$1"
}

_emit() {
  local id="$1" name="$2" file="$3"
  if ! _flatpak_installed "$id"; then
    echo "generate-plasma-autostart: skip $name ($id not installed)"
    return 0
  fi
  cat >"$DEST/$file" <<EOF
[Desktop Entry]
Type=Application
Name=$name (from Windows Run)
Exec=flatpak run $id
X-Kinoite-Provision=imports/run-keys
EOF
  echo "generate-plasma-autostart: wrote $DEST/$file"
}

TEXT=$(tr '\r' '\n' <"$RUN_KEYS")
# Match exe / app names loosely (case-insensitive).
while IFS= read -r line || [[ -n "$line" ]]; do
  low="${line,,}"
  case "$low" in
    *discord*) _emit "com.discordapp.Discord" "Discord" "kinoite-import-discord.desktop" ;;
    *steam*) _emit "com.valvesoftware.Steam" "Steam" "kinoite-import-steam.desktop" ;;
    *qbittorrent*|*qbit*) _emit "org.qbittorrent.qBittorrent" "qBittorrent" "kinoite-import-qbittorrent.desktop" ;;
    *spotify*) _emit "com.spotify.Client" "Spotify" "kinoite-import-spotify.desktop" ;;
    *localsend*) _emit "org.localsend.localsend_app" "LocalSend" "kinoite-import-localsend.desktop" ;;
    *epic*) _emit "com.heroicgameslauncher.hgl" "Epic/Heroic" "kinoite-import-heroic.desktop" ;;
    *slack*) _emit "com.slack.Slack" "Slack" "kinoite-import-slack.desktop" ;;
  esac
done <<<"$TEXT"

exit 0
