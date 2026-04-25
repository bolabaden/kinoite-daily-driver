#!/usr/bin/env bash
set -euo pipefail
flatpak remote-list
flatpak remote-info flathub org.flathub.Flathub 2>/dev/null || flatpak update --appstream
