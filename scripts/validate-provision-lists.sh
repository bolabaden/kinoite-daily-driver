#!/usr/bin/env bash
# Non-network check: config/rpm-ostree/layers.list and config/flatpak/kinoite.list
# (one package / app id per non-comment line). Exits 1 on first invalid line batch.
# CI: .github/workflows/validate-provision-lists.yml
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
L="$ROOT/config/rpm-ostree/layers.list"
F="$ROOT/config/flatpak/kinoite.list"
err=0
if [ ! -f "$L" ]; then
  echo "validate-provision-lists: missing $L" >&2
  exit 1
fi
if [ ! -f "$F" ]; then
  echo "validate-provision-lists: missing $F" >&2
  exit 1
fi
while IFS= read -r line || [ -n "$line" ]; do
  line="${line//$'\r'/}"
  [[ -z "${line// }" || "$line" =~ ^[[:space:]]*# ]] && continue
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  # RPM NEVRA-ish token (layer name): no spaces; allow :epoch for version pins, @ for modules
  if [[ ! "$line" =~ ^[A-Za-z0-9:._+=@-]+$ ]]; then
    echo "layers.list: invalid package token: $line" >&2
    err=1
  fi
done <"$L"
while IFS= read -r line || [ -n "$line" ]; do
  line="${line//$'\r'/}"
  [[ -z "${line// }" || "$line" =~ ^[[:space:]]*# ]] && continue
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  # Flathub-style app id: reverse DNS; segments may include _ and digits (e.g. io.podman_desktop.PodmanDesktop)
  if [[ ! "$line" =~ ^[A-Za-z0-9]([A-Za-z0-9._-]*\.)+[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "kinoite.list: invalid application id: $line" >&2
    err=1
  fi
done <"$F"
exit "$err"
