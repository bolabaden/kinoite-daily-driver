# systemd + `rpm-ostree` in WSL2: what can be “fully” functional?

This page answers: **can systemd and `rpm-ostree` be FULLY functional with *no* caveats in WSL2?**  
**Short answer:** **systemd** can be in good shape on modern WSL; **full `rpm-ostree` parity (no caveats)** in WSL2 is **not** what you get from the common **“podman pull → `podman export` → `wsl --import`”** path.

## 1) systemd in WSL2 (realistic to get “fully working”)

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

**Bottom line for systemd:** with a current **WSL2** build, **[boot] systemd=true` + `wsl --shutdown` is the** supported** path. Remaining “caveats” are usually **distro** / **package** / **WSLg**-specific, not “systemd cannot work.”

## 2) `rpm-ostree` + libostree in WSL2 (the hard limit)

`rpm-ostree` is designed to manage **ostree** deployments on a system that has **booted** through the **ostree** stack (e.g. `ostree-prepare-root`, deploy roots under `/ostree`, BLS, initramfs on real hardware, etc.). OSTree’s own deployment model is documented in the OSTree manual: [Deployments | ostree](https://ostreedev.github.io/ostree/deployment/).

When you import a **container** rootfs produced from **`podman export`**, you are **not** importing a **bit-for-bit** booted OSTree deployment. In practice, **`rpm-ostree` checks fail** with messages like **“This system was not booted via libostree”** (what we observed on `Kinoite-WS2` in this workspace’s **2026-04-25** import). That is **not** a random bug: it is **`rpm-ostree` being honest** that the **running** root is not an **active ostree boot**.

**Therefore:**

- You **cannot** honestly promise **“`rpm-ostree` is fully functional with no caveats in WSL2”** for this **import style** without changing the *definition* to something non-standard (e.g. pretending a container is a real atomic host).
- **Research consensus** in public sources: there is **no** widely documented, first-party **Fedora** procedure that **guarantees** a **full** OSTree boot inside **WSL2** exactly like bare metal, using only **`wsl --import` of a flat rootfs** from a container. Related `rpm-ostree` and `ostree` issues (e.g. `rpm-ostree` failures when **not** on an ostree host, `/run/ostree-booted` / remount edge cases) are in upstream trackers such as [coreos/rpm-ostree](https://github.com/coreos/rpm-ostree) and [ostreedev/ostree](https://github.com/ostreedev/ostree), but they **do not** add a WSL2 magic switch.

**What *is* a “no caveats” environment for `rpm-ostree`?**

- **Real hardware** Fedora Kinoite, or  
- A **VM** (QEMU/KVM, VirtualBox, …) installed from the **Kinoite ISO** / an installer that actually deploys an **ostree** image.

This workspace already points there in **`virtualbox-kinoite-fallback.md`** and **`kinoite-wsl2.md`**.

## 3) Practical split-brain strategy (what we recommend)

| Goal | Where to do it |
|------|----------------|
| **KDE/Flatpak/dev/CLI** in WSL | `Kinoite-WS2` (or a classic Fedora WSL) — fast iteration |
| **True `rpm-ostree` / rollbacks / layering** the way Atomic docs intend | **VM or bare metal Kinoite** |
| **Honest** CI for atomic workflows | run jobs on **KVM** / **Vagrant** / `virt-install` with an ISO, not in WSL2 if you need **guaranteed** `rpm-ostree` semantics |

## 4) “Research / tools” note (this session)

- **Tavily / `tvly` / deep research** — not run here (CLI not on PATH; use when installed per Tavily’s docs).
- **Firecrawl** — attempted; **credits** blocked (`Insufficient credits` from the hosted service). A stub filename was **not** written as if it were real research output.
- **Context7** — for library-style API docs, use the Context7 flow on **`rpm-ostree` / `ostree` package docs** in your editor when you need *exact* subcommands for a *supported* host; it does not change WSL’s **boot** model.
- **Cursor `brainstorm` command** is **deprecated** in your workspace rules — prefer the **“superpowers brainstorming”** skill for product/brainstorm work, not for OS physics.

## 5) If upstream ever adds a “real OSTree in WSL” path

Re-validate against **Fedora Atomic Desktop** release notes and `rpm-ostree`’s own requirements. Until then, treat this document as **ground truth** for **expectations** on the **2026-04-25** **container-export → WSL** import.
