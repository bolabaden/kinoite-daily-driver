# Fedora Kinoite in WSL2 — authoritative Phase A guide

This document is the **single source of truth** for importing and running **Fedora Kinoite** (atomic desktop, KDE-oriented) inside **WSL2** with **systemd** where supported, and **honest** limits for **`rpm-ostree`**.

> **Hard reality (read first):** **`systemd` and full `rpm-ostree` are not the same ask in WSL2.** See **§ [Systemd and `rpm-ostree` in WSL2 (honesty)](#systemd-and-rpm-ostree-in-wsl2-honesty)** below for what can be *fully* true vs what requires a **VM/bare metal** OSTree boot.

## Systemd and `rpm-ostree` in WSL2 (honesty)

This answers: **can systemd and `rpm-ostree` be FULLY functional with *no* caveats in WSL2?**  
**Short answer:** **systemd** can be in good shape on modern WSL; **full `rpm-ostree` parity (no caveats)** in WSL2 is **not** what you get from the common **“podman pull → `podman export` → `wsl --import`”** path.

### 1) systemd in WSL2 (realistic to get “fully working”)

WSL2 can run **systemd** as the Linux init. Microsoft’s docs: [Use systemd to manage Linux services with WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd).

**What to do (already in this workspace):**

- Put this in `/etc/wsl.conf` in the distro:

  ```ini
  [boot]
  systemd=true
  ```

- From **Windows** (PowerShell or `cmd`):

  ```text
  wsl --shutdown
  ```

- Start the distro again, then (inside WSL, from `bash` with a working cwd, e.g. `cd /` first):

  ```bash
  systemctl is-system-running
  # often "running" or "degraded" — "degraded" is still a live systemd, inspect units if needed
  ```

**Optional quality-of-life (reduces the huge `Failed to translate …` noise when launching from Windows with a long `PATH`):**

```ini
[interop]
appendWindowsPath=false
```

(Only if you are fine losing automatic Windows-executable discovery on the Linux `PATH` inside WSL.)

**Bottom line for systemd:** with a current **WSL2** build, **`[boot] systemd=true` + `wsl --shutdown`** is the **supported** path. Remaining “caveats” are usually **distro** / **package** / **WSLg**-specific, not “systemd cannot work.”

### 2) `rpm-ostree` + libostree in WSL2 (the hard limit)

`rpm-ostree` is designed to manage **ostree** deployments on a system that has **booted** through the **ostree** stack (e.g. `ostree-prepare-root`, deploy roots under `/ostree`, BLS, initramfs on real hardware, etc.). OSTree’s own deployment model is documented in the OSTree manual: [Deployments | ostree](https://ostreedev.github.io/ostree/deployment/).

When you import a **container** rootfs produced from **`podman export`**, you are **not** importing a **bit-for-bit** booted OSTree deployment. In practice, **`rpm-ostree` checks fail** with messages like **“This system was not booted via libostree”** (what we observed on `Kinoite-WS2` in this workspace’s **2026-04-25** import). That is **not** a random bug: it is **`rpm-ostree` being honest** that the **running** root is not an **active ostree boot**.

**Therefore:**

- You **cannot** honestly promise **“`rpm-ostree` is fully functional with no caveats in WSL2”** for this **import style** without changing the *definition* to something non-standard (e.g. pretending a container is a real atomic host).
- **Research consensus** in public sources: there is **no** widely documented, first-party **Fedora** procedure that **guarantees** a **full** OSTree boot inside **WSL2** exactly like bare metal, using only **`wsl --import` of a flat rootfs** from a container. Related `rpm-ostree` and `ostree` issues (e.g. `rpm-ostree` failures when **not** on an ostree host, `/run/ostree-booted` / remount edge cases) are in upstream trackers such as [coreos/rpm-ostree](https://github.com/coreos/rpm-ostree) and [ostreedev/ostree](https://github.com/ostreedev/ostree), but they **do not** add a WSL2 magic switch.

**What *is* a “no caveats” environment for `rpm-ostree`?**

- **Real hardware** Fedora Kinoite, or
- A **VM** (QEMU/KVM, VirtualBox, …) installed from the **Kinoite ISO** / an installer that actually deploys an **ostree** image.

This workspace already points there in **[`migration-baremetal-checklist.md` — Kinoite guest VM](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c)** and this file.

### 3) Practical split-brain strategy (what we recommend)

| Goal | Where to do it |
|------|----------------|
| **KDE/Flatpak/dev/CLI** in WSL | `Kinoite-WS2` (or a classic Fedora WSL) — fast iteration |
| **True `rpm-ostree` / rollbacks / layering** the way Atomic docs intend | **VM or bare metal Kinoite** |
| **Honest** CI for atomic workflows | run jobs on **KVM** / **Vagrant** / `virt-install` with an ISO, not in WSL2 if you need **guaranteed** `rpm-ostree` semantics |

### 4) “Research / tools” note (this session)

- **Tavily / `tvly` / deep research** — not run here (CLI not on PATH; use when installed per Tavily’s docs).
- **Firecrawl** — attempted; **credits** blocked (`Insufficient credits` from the hosted service). A stub filename was **not** written as if it were real research output.
- **Context7** — for library-style API docs, use the Context7 flow on **`rpm-ostree` / `ostree` package docs** in your editor when you need *exact* subcommands for a *supported* host; it does not change WSL’s **boot** model.
- **Cursor `brainstorm` command** is **deprecated** in your workspace rules — prefer the **“superpowers brainstorming”** skill for product/brainstorm work, not for OS physics.

### 5) If upstream ever adds a “real OSTree in WSL” path

Re-validate against **Fedora Atomic Desktop** release notes and `rpm-ostree`’s own requirements. Until then, treat this **section** as **ground truth** for **expectations** on the **2026-04-25** **container-export → WSL** import.

## Repo scope

This repository is **self-contained documentation and scripts** for provisioning Fedora Kinoite (WSL2 and bare metal). **Markdown completeness** does not prove a working desktop; validate with the steps in [runtime completion bar](#runtime-completion-bar-kde-and-wslg) and [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) reminders.

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

### WSL2 vs bare-metal atomic parity

**What matches well**

- Userland **Fedora** packages visible in the imported rootfs.
- **Flatpak** once user session and D-Bus exist (often needs **systemd** in `/etc/wsl.conf`).
- **toolbox** / **distrobox** for mutable `dnf` environments.

**What often does not match**

- **`rpm-ostree`:** may refuse to run if the environment was **not booted through libostree** (common when importing a **container export** as WSL rootfs) — see **Verified import** and [§ Systemd and `rpm-ostree` in WSL2 (honesty)](#systemd-and-rpm-ostree-in-wsl2-honesty).
- **Firmware / secure boot / fwupd** — not applicable inside WSL.
- **Full Plasma session + SDDM** — use partial **`plasmashell`** experiments or move to **VM/bare metal**.

For **true** parity on upgrades and rollbacks, use the **Kinoite ISO** in a VM or bare metal.

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
# On container-import WSL, expect: rpm-ostree status → "not booted via libostree" (see kinoite-wsl2 "Systemd and rpm-ostree" honesty section)
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

**`rpm-ostree`** layers are staged to the next boot; **Flatpaks** install to the user’s `~/.var/app/`. For **systemd** to apply only **layers** at boot (no Flatpaks; those need a user D-Bus session), run **`sudo ./scripts/install-atomic-provision-service.sh`**. See **[../GETTING_STARTED.md](../GETTING_STARTED.md#step-7--optional-apply-only-layered-rpms-at-boot)**.

Windows / WSL2 / WSLg-only setup (`.wslconfig`, `/etc/wsl.conf`, WSLg env, PowerShell helpers) is consolidated in **`../config/wsl2/README.md`**, including what to do **instead** on bare metal.

## Plasma / WSLg

**Before** expecting a full “desktop session,” ensure you are **not** stuck on **root** only: a container `wsl --import` may ship **without** a normal user; WSL’s default can remain **`root`**, and `loginctl` will show **no** user sessions. See [bootstrap-wsl-default-user.sh](../scripts/bootstrap-wsl-default-user.sh) and **§ [Runtime completion bar (KDE and WSLg)](#runtime-completion-bar-kde-and-wslg)** below for the **default user + `[user] default=…` + `wsl --shutdown`** path. A **systemd --user** warning for **root** on login is a symptom of the same mismatch.

There is no single guaranteed recipe; common patterns:

- Install or layer KDE workspace packages if missing from the container rootfs (may require **`rpm-ostree install`** of package groups — check Fedora Kinoite package set for your tag).
- Launch Plasma under WSLg with **[`scripts/bootstrap-kde-wsl.sh`](../scripts/bootstrap-kde-wsl.sh)** (`launch` or `plasma`) or the underlying **[`scripts/wsl2/launch-kde-gui-wslg.sh`](../scripts/wsl2/launch-kde-gui-wslg.sh)** (defaults to **X11/xcb** on `:0` for reliable windows). For manual one-offs: **`dbus-run-session plasmashell`** from a login shell.
- If **Wayland** socket issues appear, prefer **X11** (default in the launch script) or set **`WSLG_GUI_BACKEND=wayland`** only when you have verified it maps windows.

Record the **exact** command sequence that worked in your own notes or a PR to this workspace.

### Runtime completion bar (KDE and WSLg)

This subsection defines **“done”** for an *interactive* desktop, not for markdown or plan-coverage checklists.

- Having **KDE/Plasma RPMs** and `plasmashell` on disk is **necessary** and **not sufficient**.
- **Documentation-only** checklists in this repo do **not** prove: boot → login user → WSLg → working Plasma.

#### What a coding agent in Cursor can and cannot do

- **In scope from a shell:** `wsl -d Kinoite-WS2` probes, `rpm -q`, `ps`, `loginctl`, checking `/etc/wsl.conf`, running [`scripts/verify-kde-wsl2-runtime.sh`](../scripts/verify-kde-wsl2-runtime.sh) *after* you have a default user and a graphical session.
- **Out of scope unless you wire them in your IDE:** `windows-mcp`, **desktop-commander**, or any MCP that automates a **Windows desktop** or **WSLg window** was **not** available in the session that last edited this file. Treat any claim of “fully verified with those tools” as **user-provided** until attached to logs.

#### Evidence run (2026-04-26) — what was actually true on the host

| Check | Result |
|-------|--------|
| `wsl -d Kinoite-WS2` | Starts; `Fedora 43` **Kinoite** userland, Plasma **6.6.4**-era packages present |
| `wsl: Failed to start the systemd user session for 'root'.` | Observed on entry — **root**-oriented WSL + systemd user do not match typical desktop flow |
| `wsl -d Kinoite-WS2 -e whoami` | **`root`** (default user for this import) |
| `loginctl list-sessions` | **No sessions.** (expected if only root, no GUI session) |
| `DISPLAY` / `WAYLAND_DISPLAY` in non-interactive `wsl -e bash -lc` | **Empty** (no WSLg client session in that path) |
| `command -v plasmashell` | **`/usr/sbin/plasmashell`** — binary present |
| `pgrep plasmashell` / full Plasma stack | **Not running** in that probe (no session started) |
| `getent passwd` (human login) | **No unprivileged “human” user** in the file — only **root** and system accounts |

**Conclusion:** the machine is **not** at “KDE fully configured and confirmed functional out of the box” until a **default non-root user** exists, **`/etc/wsl.conf`** has `[user] default=…` (see [wsl.conf.example](../config/wsl.conf.example)), you **`wsl --shutdown`** and re-enter, then start Plasma under WSLg in this section (e.g. `dbus-run-session plasmashell`).

#### Required steps (order)

1. **Create a normal user** (WSL is not “fully configured” for KDE while default login is `root` only). Use [`scripts/bootstrap-wsl-default-user.sh`](../scripts/bootstrap-wsl-default-user.sh) **inside** the distro as root, or: `useradd -m -s /bin/bash -G wheel <name>` and `passwd <name>`.
2. **Set** `/etc/wsl.conf` `[user] default=<name>` (and keep `[boot] systemd=true`), then from **Windows:** `wsl --shutdown` → `wsl -d Kinoite-WS2` and confirm `whoami` is **not** `root`.
3. **WSLg:** from an interactive logon shell, `echo $DISPLAY` / `$WAYLAND_DISPLAY` should usually be set (WSLg). If not, see Microsoft WSLg troubleshooting.
4. **Plasma:** use the bullets above; then run [`scripts/verify-kde-wsl2-runtime.sh`](../scripts/verify-kde-wsl2-runtime.sh).
5. **Record** the exact working command(s) in [`WORKSPACE_STATUS.md`](../WORKSPACE_STATUS.md) and, if you use external MCP tools, keep **command logs** or **screenshots** in `imports/` (sanitized) *if* you choose to commit evidence.

#### Exit criteria (copy into WORKSPACE_STATUS when true)

- [ ] Default WSL user is **not** `root` (`/etc/wsl.conf` + `wsl` opens as your user).
- [ ] `loginctl` shows a **user** session (or you document WSLg-only session where `loginctl` stays empty, with evidence).
- [ ] `plasmashell` (or your chosen Plasma surface) is **running** and usable under WSLg.
- [ ] [`scripts/verify-kde-wsl2-runtime.sh`](../scripts/verify-kde-wsl2-runtime.sh) **exit 0** in that context.

When all are checked, the **KDE runtime** line in [`WORKSPACE_STATUS.md`](../WORKSPACE_STATUS.md) can move from **Not done** to **Done** with a **date** and the evidence pointer.

## Rollback

- **`rpm-ostree rollback`** then exit WSL and `wsl --shutdown` before re-entering.
- **Windows side:** keep a **copy** of the last known-good `kinoite-wsl-rootfs.tar` before risky `rpm-ostree` experiments.

## When to escalate (Phase B/C)

- **VirtualBox / KVM** with the [official Kinoite ISO](https://fedoraproject.org/atomic-desktops/kinoite/download/) when WSL2 cannot provide acceptable **GPU**, **Plasma session**, or **rpm-ostree** stability — see [migration-baremetal-checklist — Kinoite guest VM + snapshots](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) (includes [snapshots workflow](migration-baremetal-checklist.md#snapshots-workflow-virtualbox)).

## Optional: classic Fedora in WSL

**Not Phase A.** Use **only** when you **explicitly** accept that this does **not** replace Kinoite/OSTree Phase A goals (e.g. a one-off container host, or Kinoite-in-WSL2 is blocked). Label any docs or automation so it cannot be confused with this file’s Phase A path.

- Microsoft Store **Fedora** / `wsl --install` **dnf** images: fine for **general Linux** work when you are not claiming atomic-desktop parity.
- **No** script in this repo is the **default** path; see [`scripts/fedora-dnf-fallback.sh`](../scripts/fedora-dnf-fallback.sh) (stub) only with explicit approval.

## Strategy: Phase A (Kinoite in WSL2 only)

**Phase A** is **Fedora Kinoite** (OSTree / `rpm-ostree` + KDE-oriented atomic desktop bits) inside **WSL2**, with **systemd** and **WSLg** for GUI experiments.

**Not Phase A:** “Fedora for WSL” from the Store as a **dnf** substitute for the same goals. That path is **optional** and must be **explicitly** chosen; see [§ Optional: classic Fedora in WSL](#optional-classic-fedora-in-wsl) above.

**Why WSL2 first:** same **Flatpak**, **toolbox/distrobox**, and **`rpm-ostree` mental model** as bare-metal Kinoite, with faster iteration — accepting WSL-specific fragility documented in this file.

## Kinoite and other Atomic Desktops

| Variant | Desktop | Notes |
|---------|---------|--------|
| **Fedora Kinoite** | KDE Plasma | **This workspace’s target** — `rpm-ostree` + Flatpak, KDE by default. |
| **Fedora Atomic Desktop (GNOME)** | GNOME | Sister atomic edition: same upgrade and layering model, different default desktop and apps. |
| **Fedora Sway Atomic** | Sway | Tiling window-manager stack. |

Pick **one** atomic variant per machine or VM; rebasing between them is supported on **real** ostree deployments (`rpm-ostree rebase`).

## Community pointers (non-authoritative)

Forums and hubs to read **with** (not instead of) this file:

- Fedora KDE SIG issues: [pagure.io/fedora-kde/SIG](https://pagure.io/fedora-kde/SIG/issues)
- Ask Fedora: [ask.fedoraproject.org](https://ask.fedoraproject.org/) — tag **kinoite** / **atomic**
- Atomic desktops hub: [fedoraproject.org/atomic-desktops](https://fedoraproject.org/atomic-desktops/)
- Kinoite OCI on Quay: `quay.io/fedora-ostree-desktops/kinoite`

**Note (2026-04-25):** importing a **container** rootfs into WSL can leave a system where the **`rpm-ostree` CLI reports it is not booted via libostree** — i.e. not a full OSTree boot. Treat community “WSL + ostree” write-ups with skepticism; verify on your build (see [honesty section](#systemd-and-rpm-ostree-in-wsl2-honesty) above).

## Primary sources digest: WSL, systemd, and OSTree

Compact list of first-party pages that back the narrative above:

- **systemd in WSL:** `[boot] systemd=true` in `/etc/wsl.conf` — [Use systemd to manage Linux services with WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd); other boot options: [Advanced settings configuration in WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config). A **full** WSL shutdown is the documented way to apply changes.
- **Fedora Kinoite:** [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/) — atomic desktop, Plasma, rollback model; `rpm-ostree` on that stack.
- **Custom WSL from a rootfs tar:** [Import a custom Linux distribution](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro) — `wsl --import` from a **tar** (often from [container export](https://docs.docker.com/reference/cli/docker/container/export/) or the Podman equivalent).
- **WSL hub:** [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/) (documentation home).
