# Getting started

This is a **single path** through this repository: you run **Fedora Kinoite** somewhere, then use the same declarative lists and the same apply script. Installation medium (installer ISO, VM, dual-boot, imported rootfs, etc.) only changes a **few** concrete actions — those appear in **`CAUTION`** at the end of a step, not in the main instructions.

**Useful background from Fedora and upstream** (open in a browser if anything here is new):

- [Fedora Kinoite — Atomic Desktops overview](https://fedoraproject.org/atomic-desktops/kinoite/) — what Kinoite is and why Flatpak + `rpm-ostree`.
- [Download Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download/) — ISO and image hints.
- [Fedora Kinoite documentation](https://docs.fedoraproject.org/en-US/fedora-kinoite/) — installation, post-install, desktop topics, **Toolbx**, updates, and atomic-desktop workflows.
- [`rpm-ostree` documentation](https://coreos.github.io/rpm-ostree/) — how atomic updates and package layering work.
- [Flatpak — Fedora setup](https://flatpak.org/setup/Fedora/) — enabling Flatpak on Fedora.
- [Flathub](https://flathub.org/) — application catalog and remote URL users expect.

---

## What you are building toward

Kinoite ships **KDE Plasma** and expects most desktop apps as **Flatpaks**. The OS image itself is updated atomically; extra RPMs are **layered** with `rpm-ostree` when you need them.

![KDE Plasma desktop (illustrative screenshot: Konsole and Firefox under Wayland / XWayland).](https://upload.wikimedia.org/wikipedia/commons/0/0c/XWayland_KDE_Plasma_screenshot.png)

*Source: [Wikimedia Commons — XWayland KDE Plasma screenshot](https://commons.wikimedia.org/wiki/File:XWayland_KDE_Plasma_screenshot.png) (Mozilla Public License 2.0; KDE / screenshot composite).*

---

## All paths converge here

Whatever you did to **get** Kinoite, the **maintenance path in this repo** is the same:

```mermaid
flowchart LR
  subgraph inputs [How you run Kinoite]
    A[Installer / bare metal]
    B[VM guest]
    C[Dual-boot]
    D[Imported rootfs]
  end
  inputs --> E[Booted Kinoite + network + admin access]
  E --> F[Clone this repo]
  F --> G[Edit layers + Flatpak lists]
  G --> H["sudo ./scripts/apply-atomic-provision.sh"]
  H --> I[Restart so deployments apply]
  I --> J[Use Plasma + Flatpaks]
```

Differences are **only** in how you complete **first boot**, **users**, **restarts**, and sometimes **GUI** — spelled out in **`CAUTION`** where it matters.

---

## Step 1 — Finish installing Kinoite until you can log in and open a terminal

1. Complete your install using the **official** Kinoite images and guides linked in the introduction (partitioning, user creation, and first login are part of that process, not this repo).
2. Boot into Kinoite, log in to a desktop session (or a text console with network), and confirm you can run a terminal with **`sudo`** when needed.

> **CAUTION — imported rootfs (common when Linux was created from a container export)**  
> You may have **no normal user** yet or **no graphical login** as you would on a metal install. Fix **user**, **`/etc/wsl.conf`**, **systemd**, and **WSLg** using the **single** WSL-focused doc: [config/wsl2/README.md](config/wsl2/README.md), with more narrative in [docs/kinoite-wsl2.md](docs/kinoite-wsl2.md). Until that is sorted, treat this step as **not done**.

> **CAUTION — VM guest**  
> “Reboot” later in this guide means **reboot the machine that is running Kinoite** (the **guest**), not necessarily the physical host.

---

## Step 2 — Clone this repository on the Kinoite system

1. Install **`git`** if it is not present (on atomic desktops you often layer it with `rpm-ostree install git` once, or use a **toolbox** container — see [Toolbx in the Kinoite docs](https://docs.fedoraproject.org/en-US/fedora-kinoite/toolbox/)).
2. Clone wherever you keep workspaces, for example:

   ```bash
   git clone <URL-of-this-repository>
   cd Kinoite
   ```

> **CAUTION — Windows filesystem vs Linux filesystem**  
> If the clone lives under **`/mnt/...`** from a hybrid host, expect lower performance and permission quirks. Prefer the Linux-native filesystem (e.g. under your home directory on the Kinoite side) for daily work.

---

## Step 3 — Edit the declarative lists

*A former root-level `PROVISION` file only pointed here; it was **removed** to avoid an extra file—this step is the canonical “atomic lists” entry.*

This repository defines **declarative** `rpm-ostree` layers and **Flatpak** apps as editable lists, plus scripts that apply them. **WSL2 does not change that edit-and-apply workflow** — only how you **restart** afterward; see the **WSL2** `CAUTION` in **Step 5** below. **Windows / WSL2 / WSLg-only** material (host `.wslconfig`, guest `wsl.conf`, WSLg env, PowerShell helpers) is not documented here. It lives in one file: **[config/wsl2/README.md](config/wsl2/README.md)**. If you are not using WSL2, you never need that file.

### What to edit

- **`config/rpm-ostree/layers.list`** — package names to layer onto the image. **Bare metal:** the default file includes a **daily-driver** block (print/scan, fonts, VPN helpers, FUSE, peripherals, Tailscale, Bluetooth **`blueman`**, optional **`NetworkManager-openconnect`** comment). **WSL2:** comment out that block if `rpm-ostree install` fails; keep **`distrobox`** (and optionally **`fuse3`**) per [kinoite-wsl2 — systemd / rpm-ostree honesty](docs/kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty).
- **`config/flatpak/*.list`** — Flatpak application IDs.
- **`config/network/`** + **`config/secrets/README.md`** — Wi-Fi / VPN **templates**; real keys live in **gitignored** `host-local/` (never commit PSKs).
- **`scripts/provision-locale.sh`** + **`config/locale.env.example`** — one-shot timezone/keyboard (copy the example to `host-local/locale.env`).

### Checklist (same files in order)

1. Open **`config/rpm-ostree/layers.list`** and **uncomment** (or add) RPM package names you want **layered** on the base image.
2. Open **`config/flatpak/*.list`** and add **Flatpak application IDs** (as used on Flathub).
3. **(Bare metal / VM with Wi-Fi)** Copy [config/network/wifi.example.nmconnection](config/network/wifi.example.nmconnection) to a **gitignored** path such as `host-local/` (see [config/secrets/README.md](config/secrets/README.md)), set SSID/PSK only on the machine, then import with `nmcli` or place under `/etc/NetworkManager/system-connections/` (mode `0600`).
4. **(Optional)** Timezone and keyboard: copy [config/locale.env.example](config/locale.env.example) → `host-local/locale.env`, edit, then run `sudo ./scripts/provision-locale.sh` once.

**Conceptual background:** [rpm-ostree: package layering](https://coreos.github.io/rpm-ostree/) and the [Fedora Kinoite documentation](https://docs.fedoraproject.org/en-US/fedora-kinoite/) in the introduction.

**Optional boot-time** `rpm-ostree` (systemd, layers only — no Flatpaks in that pass) is covered in [Step 7](#step-7--optional-apply-only-layered-rpms-at-boot). **Immutability** (where changes land on disk) is under [Step 5 — Immutability](#immutability).

---

## Step 4 — Apply provisioning

From the **repository root** on **Kinoite**:

```bash
sudo ./scripts/apply-atomic-provision.sh
```

- Re-run after you change the lists; the script is intended to be **idempotent**.
- **`sudo`** uses your login user for Flatpak installs with **`--user`** when there is a resolvable target user, and may run Flatpak under **`dbus-run-session`** when no user D-Bus session is present (see [scripts/apply-atomic-provision.sh](scripts/apply-atomic-provision.sh)).

---

## Step 5 — Restart so `rpm-ostree` deployments can take effect

After **new** layered packages, `rpm-ostree` applies them on the **next boot** of the environment that runs Kinoite. On **bare metal** or a **normal VM**, that means a normal **reboot** of the machine (or the guest). Under **WSL2**, use **`wsl --shutdown`** from **Windows** instead of a hardware-style reboot (see **`CAUTION`** below).

1. Save work and **restart** the environment the way that matches your install type.

> **CAUTION — Linux running under Windows’ WSL2**  
> From **Windows**, run **`wsl --shutdown`** (or reboot Windows). That replaces a traditional “hardware” reboot for the WSL2 VM. More detail: [config/wsl2/README.md](config/wsl2/README.md).

### Immutability

`rpm-ostree` stages changes into the **next** deployment; **`layers.list`** is the source of truth until you rebase or reset. **User Flatpaks** live under **`~/.var/app/`** and are not part of the base OSTree image.

---

## Step 6 — Confirm Flatpak and Flathub

If **`apply-atomic-provision.sh`** already configured remotes and installed apps from your lists, **Discover** or **`flatpak list`** should show them.

Otherwise, align with upstream guidance:

- [Flatpak — Fedora](https://flatpak.org/setup/Fedora/)
- [Flathub quick setup — Fedora](https://flathub.org/setup/Fedora) (adds the Flathub remote users expect)

### Flatpak overrides (optional, per app)

When a Flatpak needs **extra** filesystem, GPU device, or Wayland/X11 socket access, use **Flatseal** or `flatpak override` — **least privilege**; widen permissions only when an app breaks (IDEs, Steam library paths, etc.).

```bash
flatpak override --user --filesystem=host com.valvesoftware.Steam
```

(Only if you understand the security tradeoff.) *Former stand-alone `docs/flatpak-overrides.md` — merged into this step.*

---

## Step 7 — (Optional) Apply only layered RPMs at boot

To stage **`rpm-ostree`** layers at boot **without** driving Flatpaks in that systemd path:

```bash
sudo ./scripts/install-atomic-provision-service.sh YOUR_LINUX_USER
```

This installs under `/etc/kinoite-provision` and enables **`kinoite-atomic-ostree.service`**. See [config/systemd/kinoite-atomic-ostree.service](config/systemd/kinoite-atomic-ostree.service), [What to edit](#what-to-edit) in Step 3, and [Immutability](#immutability) in Step 5.

---

## Step 8 — Updates, status, and rollback (ongoing)

Use the same habits as any **atomic** Fedora desktop:

- Update the base: **`rpm-ostree update`** (or the graphical updater — see Fedora atomic-desktop docs).
- Inspect deployments: **`rpm-ostree status`**.
- If a boot breaks, boot the previous entry in the boot menu or use **`rpm-ostree rollback`** as documented in [rpm-ostree administration](https://coreos.github.io/rpm-ostree/) and the [Fedora Kinoite documentation](https://docs.fedoraproject.org/en-US/fedora-kinoite/) (updates / atomic upgrades sections).

The Kinoite docs (and other Fedora Atomic Desktop guides) illustrate **atomic updates** with diagrams; open [Fedora Kinoite documentation](https://docs.fedoraproject.org/en-US/fedora-kinoite/) in a browser if you want the official figures (some hosts use strict front-end checks for static assets). Roughly, the model looks like this:

```mermaid
flowchart TB
  d1[Deployment 0 — previous] --> d2[Deployment 1 — current]
  d2 --> d3[Deployment 2 — after next update]
  d3 -.->|rollback| d2
  d3 -.->|GRUB / boot menu| d1
```

For the official illustrated explanation, search the Kinoite docs for **atomic** / **rollback** / **updates**. Application installs: [Flathub](https://flathub.org/) and [Flatpak on Fedora](https://flatpak.org/setup/Fedora/).

---

## Where WSL2-only material lives

Everything **Windows-host**, **WSLg**, and **import-specific** is intentionally **not** duplicated here. Use **[config/wsl2/README.md](config/wsl2/README.md)** only when **`CAUTION`** in this guide points you there.

---

## More documentation (if you are browsing the whole repo)

**[docs/README.md](docs/README.md)** is a single **index**: topic → provisioning table and A–Z topic list. **[scripts/README.md](scripts/README.md)** lists what every script does. For VM and bare-metal phases, use **[docs/migration-baremetal-checklist.md](docs/migration-baremetal-checklist.md)**. You do not need to open every file in `docs/` or `scripts/` at random.

## Optional: gitleaks

If you `git init` in this clone and commit only **sanitized** exports, you can run **`gitleaks detect --source . -v`** after installing [gitleaks](https://github.com/gitleaks/gitleaks) per upstream. The root **`.gitignore`** already ignores typical `imports/` noise.

---

## Research note

Automated search via **Tavily** was unavailable (API quota) while this file was written; links were chosen from **Fedora**, **`rpm-ostree`**, **Flatpak**, **Flathub**, and **Wikimedia Commons** as stable, citable sources. Re-run your preferred research tool if you need version-specific release notes or a newer install walkthrough.
