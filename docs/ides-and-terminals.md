# IDEs and terminals

- **Konsole** + **tmux** / **zsh** is the KDE-native baseline.
- **VS Code / VSCodium** Flatpak; **Cursor** / **Windsurf** follow vendor Linux packaging.
- **Devcontainers** work well with **Podman** socket on Fedora.

## Podman, toolbox, and Docker compatibility

- **Podman** is the default rootless container engine on Fedora; **Docker CLI** can talk to `podman.socket` if configured.
- **toolbox** / **distrobox**: create Fedora containers with mutable `dnf` for build dependencies without widening the **ostree** host layer.
- On **Windows**, **Podman Machine** is separate from **WSL Kinoite** — avoid confusing the two when debugging mounts.

## Quick: distrobox (mutable dnf in a box)

**Install (when you want it on the host or in your workflow):** `sudo rpm-ostree install distrobox` (uncomment/enable in `config/rpm-ostree/layers.list` on **bare metal** as needed) **or** install inside a throwaway context per your policy.

**Typical first run:**

```bash
distrobox create -n dev -i quay.io/fedora/fedora:latest
distrobox enter dev
```

*(Former `scripts/distrobox-optional.sh` only printed this — the commands live here now.)*

*The former stand-alone `docs/podman-and-toolbox.md` is **removed**; content merged above.*

## Optional shell skeleton

**Path in repo:** `config/shell/`. Copy optional snippet files from that folder to your **Linux** `~/.bashrc` / `~/.zshrc` in the WSL distro (or on bare metal) if you want (e.g. `alias ll='ls -la'`). Do not overwrite your shell config without reading. The directory may only contain `.gitkeep` in git — add files there if you like them versioned.

*Merged from the former `config/shell/README.md` — that file **removed**.*
