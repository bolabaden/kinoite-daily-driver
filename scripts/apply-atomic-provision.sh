#!/usr/bin/env bash
# Declarative provisional configuration for rpm-ostree (Kinoite) + user Flatpaks.
# Run INSIDE the Kinoite system (WSL2 import or bare metal) from repo root: sudo ./scripts/apply-atomic-provision.sh
# - Reads: config/flatpak/*.list (e.g. kinoite.list; excludes overrides.list) and config/rpm-ostree/layers.list (or /etc/kinoite-provision after install-service)
# - flatpak: config/flatpak/overrides.list → flatpak override --user (after install/update)
# - KDE: config/kde/night-color.list (see kde-night-light subcommand)
# - Runs optional executable scripts/provision.d/NN-*.sh unless KINOITE_SKIP_PROVISION_HOOKS=1
# - Idempotent: safe to re-run. rpm-ostree will no-op for already-layered packages.
# - WSL2: if rpm-ostree install fails, fix rootfs/upgrade per docs; Flatpaks still apply.
# - Root + sudo: Flatpaks target the **login user** with `flatpak --user` and `dbus-run-session`
#   when `/run/user/UID` is missing (typical non-interactive sudo / WSL).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

_subcmd_usage() {
  cat <<'EOF'
Optional first-argument subcommands (merged helpers):
  menu|tui                 interactive pick (not in CI; same as KINOITE_INTERACTIVE=1 with no subcmd)
  kde-night-light          KDE Night Color + schedule (desktop user; not sudo)
  appimage-check           FUSE / fuse3 hints for AppImages
  appimage-run <AppImage> [-- <app args...>]   extract-and-run (no FUSE mount)
  install-service [user] /etc/kinoite-provision + systemd unit (root)
  provision-locale         timedatectl/localectl from host-local/locale.env (root)
  help                     List subcommands

No arguments: normal Flatpak + rpm-ostree provision pass.
  KINOITE_INTERACTIVE=1 (and TTY, not CI) shows menu before main provision.
EOF
}

_cmd_menu() {
  if [ -n "${CI:-}" ] || [ ! -t 0 ]; then
    echo "apply-atomic-provision: menu requires a TTY; set subcommand or CI=0" >&2
    return 1
  fi
  echo "=== apply-atomic-provision (menu) ==="
  echo "1) main provision  2) kde-night-light  3) appimage-check  4) appimage-run (needs path)  5) install-service  6) provision-locale  7) help"
  read -r -p "Choice [1-7]: " n
  case "$n" in
  1) exec env KINOITE_INTERACTIVE=0 "$0" ;;
  2) exec env KINOITE_INTERACTIVE=0 "$0" kde-night-light ;;
  3) exec env KINOITE_INTERACTIVE=0 "$0" appimage-check ;;
  4) read -r -p "AppImage path: " ap; exec env KINOITE_INTERACTIVE=0 "$0" appimage-run "$ap" ;;
  5) read -r -p "User for install-service (optional): " u; exec env KINOITE_INTERACTIVE=0 "$0" install-service ${u:+"$u"} ;;
  6) exec env KINOITE_INTERACTIVE=0 "$0" provision-locale ;;
  7) _subcmd_usage; exit 0 ;;
  *) exec env KINOITE_INTERACTIVE=0 "$0" ;;
  esac
}

_cmd_kde_night_light() {
  if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "apply-atomic-provision kde-night-light: kwriteconfig6 not found (install Plasma / kwin)." >&2
    return 1
  fi
  _cfg_home() {
    if [ -n "${KINOITE_KDE_CONFIG_HOME:-}" ]; then
      printf '%s' "$KINOITE_KDE_CONFIG_HOME"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
      printf '%s' "$XDG_CONFIG_HOME"
    else
      printf '%s' "$HOME/.config"
    fi
  }
  local CFG LIST
  CFG="$(_cfg_home)"
  mkdir -p "$CFG"
  LIST="${KINOITE_NIGHT_COLOR_LIST:-}"
  if [ -z "$LIST" ] && [ -f "$REPO_ROOT/config/kde/night-color.list" ]; then
    LIST="$REPO_ROOT/config/kde/night-color.list"
  elif [ -z "$LIST" ] && [ -f /etc/kinoite-provision/kde/night-color.list ]; then
    LIST=/etc/kinoite-provision/kde/night-color.list
  fi
  if [ -z "$LIST" ] || [ ! -f "$LIST" ]; then
    echo "apply-atomic-provision: no night-color list (set KINOITE_NIGHT_COLOR_LIST or add config/kde/night-color.list)." >&2
    return 1
  fi
  echo "==> Night Color from $LIST -> $CFG"
  while IFS= read -r _line || [ -n "$_line" ]; do
    _line="${_line//$'\r'/}"
    [[ -z "${_line// }" || "$_line" =~ ^[[:space:]]*# ]] && continue
    IFS='|' read -r _fn _grp _key _val <<<"$_line"
    _fn="${_fn#"${_fn%%[![:space:]]*}"}"; _fn="${_fn%"${_fn##*[![:space:]]}"}"
    _grp="${_grp#"${_grp%%[![:space:]]*}"}"; _grp="${_grp%"${_grp##*[![:space:]]}"}"
    _key="${_key#"${_key%%[![:space:]]*}"}"; _key="${_key%"${_key##*[![:space:]]}"}"
    _val="${_val#"${_val%%[![:space:]]*}"}"; _val="${_val%"${_val##*[![:space:]]}"}"
    [ -z "$_fn" ] && continue
    kwriteconfig6 --file "$CFG/$_fn" --group "$_grp" --key "$_key" "$_val"
  done <"$LIST"
  echo "==> Done. Log out/in or restart KWin for all effects to apply."
}

_cmd_appimage_check() {
  echo "=== AppImage / FUSE quick check ==="
  if command -v fusermount3 &>/dev/null; then
    echo "OK: fusermount3 is on PATH."
  else
    echo "Note: fusermount3 not found — layer fuse3 (see config/rpm-ostree/layers.list) or use --appimage-extract-and-run."
  fi
  if command -v rpm-ostree &>/dev/null; then
    if rpm -q fuse3 &>/dev/null; then
      echo "OK: fuse3 RPM is installed in this deployment."
    else
      echo "Note: fuse3 RPM not installed — uncomment fuse3 in layers.list and apply + reboot if you need native AppImage mounts."
    fi
  else
    echo "Note: rpm-ostree not available (container?); extract-and-run still works."
  fi
  echo "Fallback run: path/to/App.AppImage --appimage-extract-and-run"
}

_cmd_appimage_run() {
  if [[ $# -lt 1 ]]; then
    echo "error: appimage-run: missing AppImage path" >&2
    exit 1
  fi
  local app="$1"
  shift
  if [[ ! -f "$app" ]]; then
    echo "error: not a file: $app" >&2
    exit 1
  fi
  if [[ ! -x "$app" ]]; then
    echo "warning: not marked executable — try: chmod +x $app" >&2
  fi
  if [[ ${1:-} == -- ]]; then shift; fi
  exec "$app" --appimage-extract-and-run "$@"
}

_cmd_install_service() {
  ROOT_UID=0
  if [ "${EUID:-0}" -ne "$ROOT_UID" ]; then
    echo "Run as root: sudo $0 install-service [default-linux-username]" >&2
    exit 1
  fi
  local TARGET_USER="${1:-}"
  install -d -m 0755 /etc/kinoite-provision
  cp -a "$REPO_ROOT/config/flatpak" /etc/kinoite-provision/
  if [ -d "$REPO_ROOT/config/kde" ]; then
    cp -a "$REPO_ROOT/config/kde" /etc/kinoite-provision/
  fi
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
    echo "==> Flatpaks: after login, or: sudo -u YOURUSER $REPO_ROOT/scripts/apply-atomic-provision.sh  (or sudo from your account so SUDO_USER is set)"
  else
    echo "==> No systemctl; copied files to /etc/kinoite-provision only."
  fi
}

_cmd_provision_locale() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root: sudo $0 provision-locale" >&2
    exit 1
  fi
  local ENV_FILE="${KINOITE_LOCALE_ENV:-$REPO_ROOT/host-local/locale.env}"
  if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    echo "==> Loaded $ENV_FILE"
  else
    echo "==> No env file at $ENV_FILE — set KINOITE_LOCALE_ENV or create host-local/locale.env (see config/README.md)" >&2
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
  local X_LAYOUT="${KINOITE_X11_LAYOUT:-${KINOITE_KEYMAP:-}}"
  if [ -n "$X_LAYOUT" ]; then
    echo "==> localectl set-x11-keymap $X_LAYOUT"
    localectl set-x11-keymap "$X_LAYOUT" || true
  fi
  echo "==> Locale pass done. timedatectl / localectl status:"
  timedatectl status 2>/dev/null || true
  localectl status 2>/dev/null || true
}

case "${1:-}" in
  menu|tui|interactive)
    shift || true
    _cmd_menu
    exit $?
    ;;
  kde-night-light | night-light)
    shift || true
    _cmd_kde_night_light "$@"
    exit $?
    ;;
  appimage-check)
    _cmd_appimage_check
    exit $?
    ;;
  appimage-run)
    shift || true
    _cmd_appimage_run "$@"
    ;;
  install-service | install-atomic-provision-service)
    shift || true
    _cmd_install_service "$@"
    exit $?
    ;;
  provision-locale | locale)
    shift || true
    _cmd_provision_locale "$@"
    exit $?
    ;;
  help | -h | --help)
    _subcmd_usage
    exit 0
    ;;
  "")
    if [ "${KINOITE_INTERACTIVE:-0}" = 1 ] && [ -z "${CI:-}" ] && [ -t 0 ]; then
      exec "$0" menu
    fi
    ;;
  *)
    echo "apply-atomic-provision: unknown command: $1" >&2
    _subcmd_usage >&2
    exit 2
    ;;
esac

# Config root: deployed copy (see install-service) or this repo’s config/
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

# flatpak with --user (override, etc.) using same runuser / dbus as install path
_flatpak_user_cmd() {
  if [ "${EUID:-0}" -eq 0 ] && command -v runuser &>/dev/null; then
    u="$(_provision_user || true)"
    if [ -n "$u" ] && id -u "$u" &>/dev/null; then
      local uid rtdir
      uid=$(id -u "$u")
      rtdir="/run/user/${uid}"
      if [ ! -d "$rtdir" ]; then
        if command -v dbus-run-session &>/dev/null; then
          runuser -u "$u" -- dbus-run-session -- /usr/bin/flatpak --user "$@"
          return
        fi
        echo "==> (flatpak) $rtdir missing; log in once or: loginctl enable-linger $u" >&2
        return 1
      fi
      runuser -u "$u" -- env "XDG_RUNTIME_DIR=$rtdir" /usr/bin/flatpak --user "$@"
      return
    fi
  fi
  if [ "${EUID:-0}" -ne 0 ]; then
    /usr/bin/flatpak --user "$@"
  else
    echo "==> (flatpak) no target user; cannot run override" >&2
    return 1
  fi
}

_apply_flatpak_overrides() {
  local ovf line ref
  ovf="$CFG_ROOT/flatpak/overrides.list"
  if [ ! -f "$ovf" ]; then
    return 0
  fi
  echo "==> Flatpak overrides: $ovf"
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line//$'\r'/}"
    [[ -z "${line// }" || "$line" =~ ^[[:space:]]*# ]] && continue
    # shellcheck disable=SC2206
    read -r -a toks <<<"$line"
    ((${#toks[@]} < 2)) && continue
    ref="${toks[0]}"
    unset "toks[0]"
    echo "  -> flatpak override $ref${toks[*]:+ ${toks[*]}}"
    if _flatpak_user_cmd override "$ref" "${toks[@]}"; then
      : ok
    else
      echo "  (override skip or error: $ref)" >&2
    fi
  done <"$ovf"
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
      if [[ "$(basename "$list")" == "overrides.list" ]]; then
        continue
      fi
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
  _apply_flatpak_overrides
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

# --- Optional provision.d hooks (documented extension point: runs sibling NN-*.sh; not a call into other top-level repo scripts) ---
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
