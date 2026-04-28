# qBittorrent template seeds (optional)

Place files here only if you want **default** qBittorrent config copied into the Flatpak sandbox when no Windows `BT_backup` is found.

Target layout after install: `~/.var/app/org.qbittorrent.qBittorrent/config/qBittorrent/`

Migration from Windows is handled by `scripts/migrate-app-config.sh` (copies `AppData/Local/qBittorrent` under WSL).
