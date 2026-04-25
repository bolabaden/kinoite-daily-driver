# Primary-source digest: WSL2, systemd, OSTree/Kinoite, custom distro import

Produced for this workspace to complement **Tavily/Firecrawl** digests. (Subagent: docs-researcher, 2026-04-25 session.)

**systemd in WSL:** set `[boot] systemd=true` in `/etc/wsl.conf` per [Use systemd to manage Linux services with WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd); broader boot options: [Advanced settings configuration in WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config). After editing, a **full** WSL shutdown is what Microsoft documents for the setting to apply.

**Fedora Kinoite (atomic / `rpm-ostree`):** [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/) — Atomic Desktop, Plasma, rollback-friendly model; `rpm-ostree` is the package/image hybrid used on that stack.

**Custom WSL from a rootfs tar:** [Import a custom Linux distribution](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro) — `wsl --import` from a **tar** of a root file system, commonly produced from a **container** export. Container side: e.g. [docker container export](https://docs.docker.com/reference/cli/docker/container/export/) (or Podman equivalent).

**Fallback hub:** [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/) (documentation hub).
