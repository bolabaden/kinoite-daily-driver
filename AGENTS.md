# Kinoite workspace (agents)

- **Start here:** [GETTING_STARTED.md](GETTING_STARTED.md) — edit `config/rpm-ostree/layers.list` and `config/flatpak/*.list`, then apply provisioning.
- **Map of docs and order:** [WORKSPACE_STATUS.md](WORKSPACE_STATUS.md).
- **Declarative packages:** [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list), [config/flatpak/](config/flatpak/).
- **WSL2 / Plasma:** [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md), [config/wsl2/README.md](config/wsl2/README.md).

Do not commit raw exports under `imports/` (see `.gitignore`). Optional Windows workspace root: `KINOITE_WORKSPACE_ROOT` — see [kinoite-workspace-root.env.example](kinoite-workspace-root.env.example).
