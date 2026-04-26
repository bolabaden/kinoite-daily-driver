# Local LLM and dev AI

- **Ollama** (upstream install docs) + **Plasma** “local AI” experiments.
- **LM Studio**-style workflows: compare **Ollama** + **Open WebUI** vs vendor AppImages — GPU stack (**ROCm/CUDA/NVIDIA**) must match your hardware.
- **AnythingLLM** in **Podman** mirrors common Windows deployment patterns.

## Media and homelab: Jellyfin, Plex, and Arr

- Run **Jellyfin** / **Plex** / **\*arr** as **Podman** quadlets or Flatpak where available.
- Bind mounts: place libraries on a dedicated **XFS/ext4** data disk on bare metal; in WSL use **Linux filesystem** paths under `/home`, not `/mnt/c` heavy churn for databases.

