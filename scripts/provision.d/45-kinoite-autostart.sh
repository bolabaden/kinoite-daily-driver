#!/usr/bin/env bash
# Plasma autostart from imports/run-keys.txt for mapped Flatpaks (native-first).
# Requires KINOITE_APPLY_AUTOSTART=1.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GEN="$REPO_ROOT/scripts/generate-plasma-autostart-from-imports.sh"

if [[ "${KINOITE_APPLY_AUTOSTART:-0}" != 1 ]]; then
  echo "==> provision.d: skip autostart (set KINOITE_APPLY_AUTOSTART=1 to generate from imports/run-keys.txt)"
  exit 0
fi

if [[ ! -x "$GEN" ]]; then
  echo "==> provision.d: $GEN not executable" >&2
  exit 0
fi

_run_as_user() {
  local u="${SUDO_USER:-}"
  if [[ -z "$u" ]] || [[ "$u" == root ]]; then
    u="$(awk -F: '($3 >= 1000 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
  fi
  if [[ -z "$u" ]] || ! id -u "$u" &>/dev/null; then
    echo "==> provision.d: no target user for autostart" >&2
    return 0
  fi
  if [[ "${EUID:-0}" -eq 0 ]] && command -v runuser &>/dev/null; then
    runuser -u "$u" -- env KINOITE_REPO_ROOT="$REPO_ROOT" bash "$GEN"
  else
    env KINOITE_REPO_ROOT="$REPO_ROOT" bash "$GEN"
  fi
}

_run_as_user
