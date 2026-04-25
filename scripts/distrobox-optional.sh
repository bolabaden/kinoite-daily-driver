#!/usr/bin/env bash
set -euo pipefail
echo "Optional: dnf install distrobox (when available) then:"
echo "  distrobox create -n dev -i quay.io/fedora/fedora:latest"
echo "  distrobox enter dev"
