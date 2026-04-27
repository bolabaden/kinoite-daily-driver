#!/usr/bin/env bash
# Run INSIDE the Kinoite WSL distro after first login (not on Windows).
# Does not call other repository .sh scripts. TUI: ./bootstrap-kinoite-wsl2.sh menu
# Non-interactive: KINOITE_INSTALL_WSLG_PROFILE=1, KINOITE_INTERACTIVE=0, CI=1
#
# Args: (none) | run | menu | tui | help
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

_cmd_help() {
  cat <<EOF
Usage: $0 [run|menu|help]
  run   — default: Flathub, flatpak update, optional WSLg profile (KINOITE_INSTALL_WSLG_PROFILE=1)
  menu  — interactive: set WSLg install and run
  Env: KINOITE_INSTALL_WSLG_PROFILE, KINOITE_INTERACTIVE, CI
EOF
}

_run_core() {
  set -euo pipefail
  echo "==> rpm-ostree status (baseline)"
  rpm-ostree status || true
  echo "==> Optionally upgrade: sudo rpm-ostree upgrade  (not run here)"
  if ! flatpak remote-list | grep -q flathub; then
    echo "==> Adding Flathub"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
  echo "==> flatpak update (user)"
  flatpak update -y || true
  if [ -e /proc/version ] && grep -qi microsoft /proc/version && [ "${KINOITE_INSTALL_WSLG_PROFILE:-0}" = 1 ]; then
    echo "==> Installing /etc/profile.d WSLg env (KINOITE_INSTALL_WSLG_PROFILE=1)"
    README_WSL2="$REPO_ROOT/config/wsl2/README.md"
    DEST=/etc/profile.d/00-kinoite-wslg-env.sh
    TMP="$(mktemp)"
    tr -d '\r' <"$README_WSL2" | sed -n '/^```sh/,/^```$/p' | sed '1d;$d' >"$TMP"
    if [ ! -s "$TMP" ]; then
      echo "Failed to extract WSLg profile from $README_WSL2" >&2
      rm -f "$TMP"
      exit 1
    fi
    sudo install -m 0644 "$TMP" "$DEST"
    rm -f "$TMP"
    echo "Installed $DEST (new logins will source it)."
  fi
  echo "==> Next: sudo $REPO_ROOT/scripts/apply-atomic-provision.sh"
  echo "    config: $REPO_ROOT/config/rpm-ostree/layers.list  and  $REPO_ROOT/config/flatpak/kinoite.list"
}

_tui() {
  if [ -n "${CI:-}" ] || [ ! -t 0 ]; then
    echo "Non-interactive: set KINOITE_INSTALL_WSLG_PROFILE=1 $0 run" >&2
    return 1
  fi
  echo "=== Kinoite WSL2 bootstrap (menu) ==="
  if [ -e /proc/version ] && grep -qi microsoft /proc/version; then
    read -r -p "Install WSLg profile.d from config/wsl2/README? [y/N] " a
    case "$a" in
    y|Y) export KINOITE_INSTALL_WSLG_PROFILE=1 ;;
    *) export KINOITE_INSTALL_WSLG_PROFILE=0 ;;
    esac
  else
    echo "Not WSL; WSLg profile step skipped."
    export KINOITE_INSTALL_WSLG_PROFILE=0
  fi
  _run_core
}

if [ -n "${KINOITE_TUI_CHOICE:-}" ] && [ $# -eq 0 ]; then
  set -- "${KINOITE_TUI_CHOICE}"
fi
if [ $# -eq 0 ]; then
  if [ "${KINOITE_INTERACTIVE:-0}" = 1 ] && [ -z "${CI:-}" ] && [ -t 0 ]; then
    _tui; exit $?
  fi
  _run_core; exit 0
fi
sub="$1"
shift
case "$sub" in
help|-h|--help) _cmd_help; exit 0 ;;
menu|tui) _tui; exit $? ;;
run) _run_core; exit 0 ;;
*) echo "error: unknown: $sub" >&2; _cmd_help >&2; exit 1 ;;
esac
