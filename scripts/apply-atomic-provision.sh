#!/usr/bin/env bash
# Declarative provisional configuration for rpm-ostree (Kinoite) + user Flatpaks.
# Run INSIDE the Kinoite system (WSL2 import or bare metal) with: sudo ./apply-atomic-provision.sh
# - Reads: config/flatpak/*.list and config/rpm-ostree/layers.list (or /etc/kinoite-provision after install-atomic-provision-service.sh)
# - Runs optional executable scripts/provision.d/NN-*.sh unless KINOITE_SKIP_PROVISION_HOOKS=1
# - Idempotent: safe to re-run. rpm-ostree will no-op for already-layered packages.
# - WSL2: if rpm-ostree install fails, fix rootfs/upgrade per docs; Flatpaks still apply.
# - Root + sudo: Flatpaks target the **login user** with `flatpak --user` and `dbus-run-session`
#   when `/run/user/UID` is missing (typical non-interactive sudo / WSL).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Config root: deployed copy (see install-atomic-provision-service.sh) or this repo’s config/
if [ -d /etc/kinoite-provision/flatpak ] && [ -d /etc/kinoite-provision/rpm-ostree ]; then
  CFG_ROOT=/etc/kinoite-provision
elif [ -n "${KINOITE_PROVISION_CONFIG:-}" ]; then
  CFG_ROOT="$KINOITE_PROVISION_CONFIG"
else
  CFG_ROOT="$REPO_ROOT/config"
fi

MARKER_DIR="${KINOITE_PROVISION_STATE:-/var/lib/kinoite-provision}"
mkdir -p "$MARKER_DIR" 2>/dev/null || true

if [ -e /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  WSL=1
  echo "==> Detected WSL2: rpm-ostree may report non-booted/libostree limits; Flathub/Flatpaks are still the main provision path."
else
  WSL=0
fi

# Flatpaks: use the real login user, not root’s. sudo → SUDO_USER; systemd/TTY root → /etc or first uid≥1000.
_provision_user() {
  if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    echo "$SUDO_USER"
  elif [ -f /etc/kinoite-provision/default-user ]; then
    awk 'NF && $0 !~ /^#/{gsub(/^[ \t]+|[ \t]+$/,""); print; exit}' /etc/kinoite-provision/default-user
  elif [ -n "${KINOITE_PROVISION_USER:-}" ]; then
    echo "$KINOITE_PROVISION_USER"
  else
    awk -F: '($3 >= 1000 && $1 != "nobody" && $1 !~ /^(nologin)$/) { print $1; exit }' /etc/passwd
  fi
}
_flatpak() {
  # When root provisions for a login user, target the per-user Flatpak installation (required on Atomic/WSL).
  local -a _u=( )
  if [ "${EUID:-0}" -eq 0 ] && command -v runuser &>/dev/null; then
    u="$(_provision_user || true)"
    if [ -n "$u" ] && id -u "$u" &>/dev/null; then
      _u=(--user)
      uid=$(id -u "$u")
      rtdir="/run/user/${uid}"
      if [ ! -d "$rtdir" ]; then
        # WSL / non-interactive sudo: no user session dir yet — still works with a private dbus session.
        if command -v dbus-run-session &>/dev/null; then
          runuser -u "$u" -- dbus-run-session -- /usr/bin/flatpak "${_u[@]}" "$@"
          return
        fi
        echo "==> (flatpak) $rtdir missing; install dbus-daemon or log in once, or: loginctl enable-linger $u" >&2
        return 1
      fi
      runuser -u "$u" -- env "XDG_RUNTIME_DIR=$rtdir" /usr/bin/flatpak "${_u[@]}" "$@"
      return
    fi
  fi
  if [ "${EUID:-0}" -ne 0 ]; then
    /usr/bin/flatpak "$@"
  else
    echo "==> (flatpak) no target user; set KINOITE_PROVISION_USER or /etc/kinoite-provision/default-user" >&2
    return 1
  fi
}

# --- Flathub + Flatpaks from all *.list files (use KINOITE_OSTREE_ONLY=1 to skip) ---
if [ "${KINOITE_OSTREE_ONLY:-0}" != 1 ] && [ "${KINOITE_SKIP_FLATPAK:-0}" != 1 ] && command -v flatpak &>/dev/null; then
  if ! _flatpak remote-list 2>/dev/null | grep -q flathub; then
    echo "==> Adding Flathub (user remotes)" || true
    _flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
  fi
  shopt -s nullglob
  _fp=("$CFG_ROOT/flatpak"/*.list)
  shopt -u nullglob
  readarray -t lists < <(printf '%s\n' "${_fp[@]:-}" | sort -u)
  if ((${#lists[@]} > 0)); then
    for list in "${lists[@]}"; do
      [ ! -f "$list" ] && continue
      echo "==> Flatpaks from $list"
      while IFS= read -r line || [ -n "$line" ]; do
        id="${line//[$'\r']/}"
        [[ -z "$id" || "$id" =~ ^[[:space:]]*# ]] && continue
        id="${id#"${id%%[![:space:]]*}"}"
        id="${id%"${id##*[![:space:]]}"}"
        [ -z "$id" ] && continue
        _flatpak install -y flathub "$id" 2>/dev/null || echo "  (skip or error: $id)" >&2
      done <"$list"
    done
  fi
  echo "==> flatpak repair (best-effort; fixes broken refs)"
  _flatpak repair 2>/dev/null || true
  echo "==> flatpak update"
  _flatpak update -y 2>/dev/null || true
elif [ "${KINOITE_OSTREE_ONLY:-0}" = 1 ]; then
  echo "==> KINOITE_OSTREE_ONLY=1: skipped Flatpaks (run this script from a user session without that env to apply lists)."
elif [ "${KINOITE_SKIP_FLATPAK:-0}" = 1 ]; then
  echo "==> KINOITE_SKIP_FLATPAK=1: skipped Flatpaks."
elif ! command -v flatpak &>/dev/null; then
  echo "==> flatpak not found; install it on the image or apply only rpm-ostree layers."
fi

# --- rpm-ostree: layered packages from layers.list ---
LAYERS_FILE="$CFG_ROOT/rpm-ostree/layers.list"
if [ ! -f "$LAYERS_FILE" ]; then
  echo "==> No $LAYERS_FILE; skipped rpm-ostree layers."
else
  mapfile -t pkgs < <(grep -v '^\s*#' "$LAYERS_FILE" 2>/dev/null | sed '/^\s*$/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' || true)
  if ((${#pkgs[@]})); then
    if ! command -v rpm-ostree &>/dev/null; then
      echo "==> rpm-ostree not available; cannot layer: ${pkgs[*]}"
    else
      echo "==> rpm-ostree install: ${pkgs[*]}"
      ROST=()
      if rpm-ostree install --help 2>&1 | grep -q -- '--assumeyes'; then
        ROST=(install --assumeyes --allow-inactive)
      else
        ROST=(install --allow-inactive)
      fi
      if rpm-ostree "${ROST[@]}" "${pkgs[@]}"; then
        touch "$MARKER_DIR/rpm-ostree-layers-applied" 2>/dev/null || true
        echo "==> rpm-ostree: layers staged. Reboot the deployment (on bare metal) or: wsl --shutdown (WSL) then re-enter."
      else
        echo "==> rpm-ostree install failed (expected on some WSL imports). Edit $LAYERS_FILE and retry after ostree is healthy per docs."
      fi
    fi
  else
    echo "==> No uncommented entries in $LAYERS_FILE; skipped layering."
  fi
fi

# Optional: use Fedora’s automatic check for image updates (does not add layers)
if command -v systemctl &>/dev/null; then
  systemctl enable --now rpm-ostreed.service 2>/dev/null || true
  if systemctl list-unit-files 2>/dev/null | grep -q rpm-ostreed-automatic.timer; then
    systemctl enable --now rpm-ostreed-automatic.timer 2>/dev/null || true
  fi
fi

# --- Optional provision.d hooks (executable NN-name.sh only; see scripts/README.md#post-provision-hooks) ---
if [ "${KINOITE_SKIP_PROVISION_HOOKS:-0}" != 1 ]; then
  HOOK_DIR="$SCRIPT_DIR/provision.d"
  if [ -d "$HOOK_DIR" ]; then
    shopt -s nullglob
    for h in "$HOOK_DIR"/[0-9][0-9]-*.sh; do
      [ -x "$h" ] || continue
      echo "==> provision.d: $(basename "$h")"
      bash "$h" || echo "  (hook failed: $h)" >&2
    done
    shopt -u nullglob
  fi
fi

echo "==> Provisioning pass complete. Config root was: $CFG_ROOT"
exit 0
