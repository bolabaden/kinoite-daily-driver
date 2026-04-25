# Research digest — WSL2 + systemd + OSTree/Kinoite (2026-04-25)

**Tools:** `tvly` / Tavily CLI was **not** available on this host `PATH` during workspace refresh; this file uses **web-backed** primary sources instead. For automated Tavily→extract workflow, see `../docs/research-workflow-tavily-firecrawl.md`.

## systemd in WSL2

- **Microsoft Learn — Use systemd to manage Linux services with WSL:** https://learn.microsoft.com/en-us/windows/wsl/systemd  
- **Advanced WSL settings (`.wslconfig`, `[wsl2]`)** — https://learn.microsoft.com/en-us/windows/wsl/wsl-config  
- Enabling: `/etc/wsl.conf` with `[boot]` + `systemd=true`, then a **full** WSL restart via **`wsl --shutdown`** (not merely closing a terminal).  
- **Troubleshooting / edge cases** — e.g. slow boot, `systemctl is-system-running` = `starting` — see community threads such as [WSL#11681](https://github.com/microsoft/WSL/issues) for “systemd not booting” reports; mask slow units (e.g. `systemd-networkd-wait-online`) if they block your workflow.

**Workspace verification (this host, 2026-04-25):** with `G:\` on `PATH`, WSL printed many `Failed to translate` lines; with a **minimal** `Path`, `Kinoite-WS2` showed **`/run/systemd` absent** in one check and `systemctl is-system-running` → **`starting`** in another — **consistent with needing a clean shutdown** or **user session** not root. Treat **non-interactive** verification as **best-effort**; re-check after `wsl --shutdown`.

## Kinoite / OSTree rootfs in WSL

- **Import pattern:** OCI image → `podman export` tarball → `wsl --import` (see `docs/kinoite-wsl2.md`).  
- **General container→WSL caveats** (metadata / whiteout): e.g. discussion of layered exports in community write-ups (search: “import container as WSL distribution rootfs”).  
- **`rpm-ostree status` on a container-export tree** often reports **not booted via libostree** — matches our **Kinoite-WS2** observation; see `docs/systemd-rpm-ostree-wsl2-claims.md` for full **Kinoite-flavored userland** vs **true atomic host** split.

## Full parity targets

- **Rebase / atomic desktop** workflows: Fedora FAQ and Fedora Discussion for **rpm-ostree rebase** between **Silverblue/Kinoite** (when on **real** ostree boot).  
- For **no-caveat** `rpm-ostree` + upgrades: **bare metal** or **VM/ISO** install, not the Phase-A WSL import path.
