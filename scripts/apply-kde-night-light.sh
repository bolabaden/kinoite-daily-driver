#!/usr/bin/env bash
# Night Light (KWin) + day/night schedule: enabled, DarkLight, 6500K day / 4500K night, location-based
# schedule with Automatic=true (GeoClue2 when available). Writes kwinrc [NightColor] + knighttimerc.
# Upstream: kwin nightlightsettings.kcfg; plasma-workspace nighttimesettings.kcfg.
# GeoClue / WSL caveats: see docs/kde-daily-driver-recommendations.md#provisional-kde-config-in-repo-user-scope
# Run as the desktop user — not sudo (unless KINOITE_KDE_CONFIG_HOME points at another user’s ~/.config).
# Optional: KINOITE_KDE_CONFIG_HOME=/path/to/.config ./scripts/apply-kde-night-light.sh
set -euo pipefail

_cfg_home() {
  if [ -n "${KINOITE_KDE_CONFIG_HOME:-}" ]; then
    printf '%s' "$KINOITE_KDE_CONFIG_HOME"
  elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
    printf '%s' "$XDG_CONFIG_HOME"
  else
    printf '%s' "$HOME/.config"
  fi
}

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  echo "apply-kde-night-light: kwriteconfig6 not found (install Plasma / kwin)." >&2
  exit 1
fi

CFG="$(_cfg_home)"
mkdir -p "$CFG"

echo "==> Night Light (kwinrc [NightColor]) + schedule (knighttimerc) -> $CFG"

kwriteconfig6 --file "$CFG/kwinrc" --group NightColor --key Active true
kwriteconfig6 --file "$CFG/kwinrc" --group NightColor --key Mode DarkLight
kwriteconfig6 --file "$CFG/kwinrc" --group NightColor --key DayTemperature 6500
kwriteconfig6 --file "$CFG/kwinrc" --group NightColor --key NightTemperature 4500

kwriteconfig6 --file "$CFG/knighttimerc" --group General --key Source Location
kwriteconfig6 --file "$CFG/knighttimerc" --group Location --key Automatic true

echo "==> Done. Log out/in or restart KWin for all effects to apply."
