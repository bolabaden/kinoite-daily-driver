# Media and homelab (*arr, Jellyfin, Plex)

- Run **Jellyfin** / **Plex** / **\*arr** as **Podman** quadlets or Flatpak where available.
- Bind mounts: place libraries on a dedicated **XFS/ext4** data disk on bare metal; in WSL use **Linux filesystem** paths under `/home`, not `/mnt/c` heavy churn for databases.
