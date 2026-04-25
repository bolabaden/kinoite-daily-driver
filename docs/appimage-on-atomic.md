# AppImage on atomic / OSTree

- Install **`fuse`** / **libfuse** support per Fedora release notes; some AppImages require **`--appimage-extract-and-run`** on FUSE-less setups.
- Prefer **Flatpak** when an official Flatpak exists — fewer FUSE edge cases on read-only `/usr`.

See `../scripts/appimage-fuse-atomic.sh` for hints.
