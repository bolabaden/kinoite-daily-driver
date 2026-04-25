# Fedora Kinoite in WSL2 — authoritative Phase A guide

This document is the **single source of truth** for importing and running **Fedora Kinoite** (atomic desktop, KDE-oriented) inside **WSL2** with **systemd** where supported, and **honest** limits for **`rpm-ostree`**.

> **Hard reality (read first):** **`systemd` and full `rpm-ostree` are not the same ask in WSL2.** See [**`systemd-rpm-ostree-wsl2-claims.md`**](systemd-rpm-ostree-wsl2-claims.md) for what can be *fully* true vs what requires a **VM/bare metal** OSTree boot.

## Spec and the KotOR.js repository

- **Cursor plan** (in a **KotOR.js** checkout, not in this path): **`.cursor/plans/silverblue_wsl_workspace_ec9c3c8b.plan.md`**. It points at **`G:\workspaces\Kinoite`** in **## Status**; a **line-by-line plan vs files** table for this tree is [plan-stipulated-file-tree.md](plan-stipulated-file-tree.md).
- **Agent / IDE** notes: [KotOR.js `AGENTS.md` (upstream)](https://github.com/KobaltBlu/KotOR.js/blob/master/AGENTS.md).
- **“Done in this tree” vs the plan (Phase A):** [phases-definition-of-done.md](phases-definition-of-done.md) — and **KotOR ↔ on-disk** rows in [plan-alignment.md](plan-alignment.md) (Phase **A**) and [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md).

## Goals

- A WSL2 distro whose root filesystem comes from the **same OCI lineage** as [Fedora Atomic Desktops / Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/), not “Fedora for WSL” classic **dnf** images as a Phase A substitute.
- **systemd** enabled and verified after `wsl --shutdown` (see [Microsoft: systemd in WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd)) — *this is achievable* on current WSL2.
- **`rpm-ostree`**: on a **container `podman export` → `wsl --import`** tree, expect **`rpm-ostree` to refuse** a full status — that is a **structural** limitation, not something this workspace can “patch” without a different boot path. Use **Kinoite in a VM/ISO** for *no-caveat* `rpm-ostree`.
- **Flatpak** + **Flathub** for most GUI apps; **`toolbox`/`distrobox`** for mutable `dnf` in WSL when `rpm-ostree` is not the driver.
- **Plasma** usable under **WSLg** (often **`plasmashell`** or a partial session — **SDDM** in WSL is usually skipped).

## VPN and overlay network stack (plan note)

A **Windows 11** daily driver often has **Cloudflare WARP**, **Tailscale**, **PIA**, **OpenVPN**, and other clients **active together**. That stack is a **troubleshooting risk** (MTU, routing loops, **DNS** surprises). On **Fedora Kinoite**—whether in **WSL2** (mostly **development/experiment**) or **bare metal** (your eventual target)—prefer **one primary tunnel** for “general” connectivity and add **split routing** or **per-app** policy when a tool supports it. Re-implementing **four simultaneous full-tunnel** clients the way they often sit on Windows is rarely desirable.

- **WARP (Linux / atomic):** [Get started (Linux)](https://developers.cloudflare.com/warp-client/get-started/linux/), [packages](https://pkg.cloudflareclient.com/) — on **rpm-ostree** hosts, install the system package, **reboot**, then **`systemctl enable --now warp-svc`** and `warp-cli …`.  
- **Tailscale / PIA / OpenVPN:** see [`networking.md`](networking.md) for **NetworkManager**, vendor UIs, and “pick one **primary** VPN” guidance.

## Verified import (this workspace, 2026-04-25)

| Step | Result |
|------|--------|
| `podman pull quay.io/fedora-ostree-desktops/kinoite:43` | Success |
| `podman export` → `scratch/kinoite-wsl-rootfs.tar` | Success |
| `wsl --import Kinoite-WS2 G:\WSL\Kinoite-WS2 …tar --version 2` | Success |
| `cat /etc/os-release` inside distro | **Fedora Linux 43 (Kinoite)**, `VARIANT_ID=kinoite` |
| `rpm-ostree status` | **Fails:** `This system was not booted via libostree` — the **OCI container rootfs** is not the same as a **disk image deployed through ostree-prepare-root**. Treat this WSL instance as **Kinoite-flavored userland** for **Flatpak/dnf in toolbox** experiments until a **full ostree** path is validated (VM/ISO, or a future community recipe). |

**WSL interop noise:** launching from Windows with a huge `PATH` can print `Failed to translate …` for many entries; use a **clean** shell profile for WSL-only work or set `appendWindowsPath=false` under `[interop]` in `/etc/wsl.conf` after you are sure you do not need Windows tools on `PATH` inside Linux.

## Pinned reference image (verify before use)

| Registry | Image | Tag |
|----------|-------|-----|
| `quay.io` | `fedora-ostree-desktops/kinoite` | **`43`** (example; check [Quay tags](https://quay.io/repository/fedora-ostree-desktops/kinoite?tab=tags) for current) |

Bootable-container images are large; expect **multi-GB** pull and export.

## Windows host prerequisites

- **WSL2** enabled, **Windows 11** (or Win10 21H2+ with WSL2).
- **Podman** (or Docker) on Windows to **pull** OCI and **export** a rootfs tarball.
- **Disk:** free space for image layers + **one** `.tar` export + WSL install directory (plan for **40 GB+** to be safe).
- **PowerShell**; **`wsl --import`** may need an elevated shell depending on target path.

## Import pipeline (high level)

1. `podman pull quay.io/fedora-ostree-desktops/kinoite:<TAG>`
2. `podman create --name kinoite-wsl-export quay.io/fedora-ostree-desktops/kinoite:<TAG>`
3. `podman export kinoite-wsl-export -o $env:TEMP\kinoite-wsl-rootfs.tar` (or a path on `G:\`)
4. `podman rm kinoite-wsl-export`
5. `wsl --unregister <OldName>` only if replacing; then  
   `wsl --import Kinoite-WS2 G:\WSL\Kinoite-WS2 G:\path\to\kinoite-wsl-rootfs.tar --version 2`
6. Delete or archive the `.tar` after successful import to reclaim space.

**Automated script:** `..\scripts\import-kinoite-rootfs-to-wsl.ps1` (read parameters inside).

### Caveats (OSTree + WSL)

- OSTree assumes a **real Linux boot** path (`ostree-prepare-root`, BLS, initrd). WSL2’s init is **not** a PC firmware stack. Some **`rpm-ostree rebase` / upgrade** paths can fail or require workarounds.
- **`/run/ostree-booted`**, **`ostree-finalize-staged`**, and kernel pinning **do not** mirror bare metal. Treat WSL2 Kinoite as a **lab** for tooling and configs; validate the same `rpm-ostree` + Flatpak flows on **bare metal** or **VM** before relying on it for production.
- If **`rpm-ostree upgrade`** breaks the deployment: **`rpm-ostree rollback`** (from previous entry) or restore from **tar backup** + `wsl --import`.

## `/etc/wsl.conf` (systemd + default user)

After import, before relying on services:

```ini
[boot]
systemd=true

[user]
default=YOUR_LINUX_USERNAME
```

Copy from `../config/wsl.conf.example`, adjust `default=`, place in `/etc/wsl.conf` **inside** the distro, then **`wsl --shutdown`** from Windows and start the distro again.

Verify:

```bash
systemctl is-system-running
# On container-import WSL, expect: rpm-ostree status → "not booted via libostree" — see systemd-rpm-ostree-wsl2-claims.md
```

## First steps inside the distro

```bash
sudo rpm-ostree upgrade
# reboot WSL from Windows: wsl --shutdown ; wsl -d Kinoite-WS2

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update -y
```

Use **`../scripts/bootstrap-kinoite-wsl2.sh`** for a guided sequence.

## Declarative `rpm-ostree` + Flatpak (provisional config, this repo)

Edit **`config/rpm-ostree/layers.list`** (package names, one per line) and **`config/flatpak/*.list`** (Flathub app IDs), then from the repo root on the **Linux** side run:

`sudo ./scripts/apply-atomic-provision.sh`

**`rpm-ostree`** layers are staged to the next boot; **Flatpaks** install to the user’s `~/.var/app/`. For **systemd** to apply only **layers** at boot (no Flatpaks; those need a user D-Bus session), run **`sudo ./scripts/install-atomic-provision-service.sh`**. See **`../PROVISION`**.

## Plasma / WSLg

There is no single guaranteed recipe; common patterns:

- Install or layer KDE workspace packages if missing from the container rootfs (may require **`rpm-ostree install`** of package groups — check Fedora Kinoite package set for your tag).
- Launch **`dbus-run-session plasmashell`** or start a **Plasma Bigscreen** / minimal shell experiment under WSLg.
- If **Wayland** socket issues appear, document whether **X11** fallback via WSLg worked.

Record the **exact** command sequence that worked in **`WORKSPACE_STATUS.md`** or a PR to this workspace.

## Rollback

- **`rpm-ostree rollback`** then exit WSL and `wsl --shutdown` before re-entering.
- **Windows side:** keep a **copy** of the last known-good `kinoite-wsl-rootfs.tar` before risky `rpm-ostree` experiments.

## When to escalate (Phase B/C)

- **VirtualBox / KVM** with the [official Kinoite ISO](https://fedoraproject.org/atomic-desktops/kinoite/download/) when WSL2 cannot provide acceptable **GPU**, **Plasma session**, or **rpm-ostree** stability — see `virtualbox-kinoite-fallback.md`.

## Optional: classic Fedora in WSL

**Not Phase A.** Only if you **explicitly** choose a dnf-based Fedora WSL for a side task; document that it is **not** a replacement for Kinoite/OSTree workflows. See `fedora-dnf-fallback-optional.md`.
