# Optional: extra KDE tuning inside WSL

Use when **Plasma** under WSLg is **partial** (e.g. only `plasmashell` works).

- Disable expensive desktop effects.
- Prefer **XWayland** fallback if a specific app fails on pure Wayland.
- Do **not** expect **SDDM** login flow — start components manually from a login shell.

See `../scripts/bootstrap-kde-wsl.sh`.
