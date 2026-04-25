# Podman, toolbox, and Docker compatibility

- **Podman** is the default rootless container engine on Fedora; **Docker CLI** can talk to `podman.socket` if configured.
- **toolbox** / **distrobox**: create Fedora containers with mutable `dnf` for build dependencies without widening the **ostree** host layer.
- On **Windows**, **Podman Machine** is separate from **WSL Kinoite** — avoid confusing the two when debugging mounts.
