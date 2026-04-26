# Workspace reminders (static)

This file lists a **suggested order** and pointers; it is **not** a live sync with any external plan.

| Step | Pointer |
|------|---------|
| Read the funnel | [GETTING_STARTED.md](GETTING_STARTED.md) |
| WSL2 / import / Plasma narrative | [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md), [config/wsl2/README.md](config/wsl2/README.md) |
| Declarative packages | [config/rpm-ostree/layers.list](config/rpm-ostree/layers.list), [config/flatpak/](config/flatpak/) |
| Apply on the distro | [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh) |
| Windows → Linux app notes | [docs/app-mapping.md](docs/app-mapping.md), [docs/win11-kinoite-parity-matrix.md](docs/win11-kinoite-parity-matrix.md) |
| Optional Windows inventory | [scripts/README.md — The imports directory](scripts/README.md#the-imports-directory) |
| Phases B/C (VM, bare metal) | [docs/migration-baremetal-checklist.md](docs/migration-baremetal-checklist.md) |
| Doc index | [docs/README.md](docs/README.md) |

**Optional checks:** [scripts/check-md-links.ps1](scripts/check-md-links.ps1) or [scripts/verify-repo-health.ps1](scripts/verify-repo-health.ps1) (same behavior). **CI:** [.github/workflows/markdown-link-check.yml](.github/workflows/markdown-link-check.yml).
