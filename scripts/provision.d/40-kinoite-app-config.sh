#!/usr/bin/env bash
# Run user-level app config migration after Flatpaks (migrate-app-config.sh).
# Skipped when KINOITE_SKIP_APP_CONFIG=1 or KINOITE_SKIP_PROVISION_HOOKS=1 (handled by parent).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MIG="$REPO_ROOT/scripts/migrate-app-config.sh"

if [[ "${KINOITE_SKIP_APP_CONFIG:-0}" == 1 ]]; then
  echo "==> provision.d: skip app config (KINOITE_SKIP_APP_CONFIG=1)"
  exit 0
fi

if [[ ! -x "$MIG" ]]; then
  echo "==> provision.d: migrate-app-config.sh not executable; chmod +x $MIG" >&2
  exit 0
fi

_run_as_user() {
  local u="${SUDO_USER:-}"
  if [[ -z "$u" ]] || [[ "$u" == root ]]; then
    u="$(awk -F: '($3 >= 1000 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
  fi
  if [[ -z "$u" ]] || ! id -u "$u" &>/dev/null; then
    echo "==> provision.d: no target user for migrate-app-config" >&2
    return 0
  fi
  if [[ "${EUID:-0}" -eq 0 ]] && command -v runuser &>/dev/null; then
    runuser -u "$u" -- env KINOITE_REPO_ROOT="$REPO_ROOT" bash "$MIG" run
  else
    env KINOITE_REPO_ROOT="$REPO_ROOT" bash "$MIG" run
  fi
}

_run_as_user
