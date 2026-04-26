#!/usr/bin/env bash
# AppImage on Fedora Kinoite / rpm-ostree:
# - Prefer Flatpak when the app ships there (fewer FUSE edge cases on read-only /usr).
# - Native mount often needs FUSE in the image: uncomment fuse3 in config/rpm-ostree/layers.list, apply, reboot.
# - Works everywhere without layering: ./Your.AppImage --appimage-extract-and-run [app-args...]
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  appimage-fuse-atomic.sh check
      Print FUSE-related hints (fusermount, layered packages).

  appimage-fuse-atomic.sh run <AppImage> [-- <args for the bundled app...>]
      Run the AppImage with --appimage-extract-and-run (no FUSE mount required).

Layering: edit config/rpm-ostree/layers.list (FUSE tier), then ./scripts/apply-atomic-provision.sh
EOF
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

cmd_check() {
  echo "=== AppImage / FUSE quick check ==="
  if have_cmd fusermount3; then
    echo "OK: fusermount3 is on PATH."
  else
    echo "Note: fusermount3 not found — layer fuse3 (see config/rpm-ostree/layers.list) or use --appimage-extract-and-run."
  fi
  if have_cmd rpm-ostree; then
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

cmd_run() {
  if [[ $# -lt 1 ]]; then
    echo "error: missing AppImage path" >&2
    usage >&2
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

main() {
  case "${1:-}" in
    check) cmd_check ;;
    run) shift; cmd_run "$@" ;;
    -h|--help|help) usage ;;
    "")
      usage
      exit 1
      ;;
    *)
      echo "error: unknown command: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
