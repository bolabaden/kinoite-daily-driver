#!/usr/bin/env bash
# One-shot timezone + keyboard on bare metal (no secrets). Run: sudo ./scripts/provision-locale.sh
# Config: copy config/locale.env.example → host-local/locale.env (gitignored) or set KINOITE_LOCALE_ENV.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${KINOITE_LOCALE_ENV:-$REPO_ROOT/host-local/locale.env}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  echo "==> Loaded $ENV_FILE"
else
  echo "==> No env file at $ENV_FILE — set KINOITE_LOCALE_ENV or create host-local/locale.env from config/locale.env.example"
fi

if [ -n "${KINOITE_TIMEZONE:-}" ]; then
  echo "==> timedatectl set-timezone $KINOITE_TIMEZONE"
  timedatectl set-timezone "$KINOITE_TIMEZONE"
fi

if [ -n "${KINOITE_LANG:-}" ]; then
  echo "==> localectl set-locale LANG=$KINOITE_LANG"
  localectl set-locale "LANG=$KINOITE_LANG"
fi

if [ -n "${KINOITE_KEYMAP:-}" ]; then
  echo "==> localectl set-keymap $KINOITE_KEYMAP"
  localectl set-keymap "$KINOITE_KEYMAP"
fi

X_LAYOUT="${KINOITE_X11_LAYOUT:-${KINOITE_KEYMAP:-}}"
if [ -n "$X_LAYOUT" ]; then
  echo "==> localectl set-x11-keymap $X_LAYOUT"
  localectl set-x11-keymap "$X_LAYOUT" || true
fi

echo "==> Locale pass done. timedatectl / localectl status:"
timedatectl status 2>/dev/null || true
localectl status 2>/dev/null || true
