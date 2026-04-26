# WSL2 and WSLg — Windows-only Kinoite notes

**If you are not using WSL2** (bare-metal install, a normal VM, dual-boot, or anything that is not “Linux distro imported/running under Windows Subsystem for Linux”), **this whole file does not apply.** Close it and follow **[GETTING_STARTED.md](../../GETTING_STARTED.md#step-3--edit-the-declarative-lists)**: edit `config/rpm-ostree/layers.list` and `config/flatpak/*.list`, run `sudo ./scripts/apply-atomic-provision.sh` inside Kinoite, then **reboot the machine** (or your VM) after new `rpm-ostree` layers. Log in with your real display manager (e.g. SDDM) and use Plasma like any other desktop. Do **not** copy `config/wsl2/*` examples onto that system as “Linux config.”

**If you are using WSL2**, everything Windows- or WSLg-specific for this repo is meant to live **here** — host templates under `config/wsl2/`, helpers under `scripts/wsl2/`. Stubs at `config/.wslconfig.example` and `config/wsl.conf.example` only redirect you back to this folder.

---

## Provisioning (same lists as everyone else)

WSL2 does **not** change how atomic provisioning works. You still edit the same lists and run the same apply script as bare metal:

- Edit **`config/rpm-ostree/layers.list`** and **`config/flatpak/*.list`**.
- Inside the distro: **`sudo ./scripts/apply-atomic-provision.sh`** (from your clone path).
- After new **rpm-ostree** layers, from **Windows** run **`wsl --shutdown`** (or reboot Windows) so the next WSL start picks up the new deployment — **instead of** a full hardware reboot.

Optional boot-time layers-only service: **`sudo ./scripts/install-atomic-provision-service.sh YOUR_LINUX_USER`** — see [GETTING_STARTED.md — Step 7](../../GETTING_STARTED.md#step-7--optional-apply-only-layered-rpms-at-boot).

**If you are not using WSL2:** use a normal **reboot** of the physical machine or VM after layering, not `wsl --shutdown`.

---

## Host side: `%UserProfile%\.wslconfig` (Windows)

**WSL2:** Start from **`windows.wslconfig.example`** in this directory. Copy the content you need into **`%UserProfile%\.wslconfig`** on Windows (this controls the WSL2 VM: memory, swap, processors, GUI integration, optional networking knobs). Restart WSL or run `wsl --shutdown` after changes.

**If you are not using WSL2:** there is **no** `.wslconfig`. Tune RAM, CPU, and power the usual way: firmware, hypervisor settings for VMs, or OS power profiles — not this repo’s WSL templates.

---

## Guest side: `/etc/wsl.conf` inside the WSL distro

**WSL2:** Start from **`distro.wsl.conf.example`** in this directory. Typical goals: turn on **`systemd`** in the WSL guest and set the **default WSL user**. Merge into **`/etc/wsl.conf`** only inside that imported distro.

**If you are not using WSL2:** **`/etc/wsl.conf` is not a thing** for your setup. Use the installer and a real local user; use **SDDM**, **GDM**, or whatever display manager your spin ships — not WSL’s default-user mechanism.

---

## Optional: WSLg environment shim (`profile.d`)

**WSL2:** If Qt/Plasma under WSLg misbehaves, you may install something derived from **`profile.d-00-kinoite-wslg-env.sh.example`** (e.g. under `/etc/profile.d/`) to normalize **`USER`**, **`HOME`**, **`XDG_RUNTIME_DIR`**, **`QT_QPA_PLATFORM`**, etc. Treat it as optional glue for WSLg.

**If you are not using WSL2:** **do not** install this shim. A normal Plasma session sets those for you; adding WSLg-oriented env is at best pointless and at worst confusing.

---

## Helper scripts under `scripts/wsl2/`

**Single catalog (no `README` inside `scripts/wsl2/`):** [scripts/README.md — WSL2 and WSLg](../../scripts/README.md#wsl2-and-wslg).

These exist **only** for the Windows + WSL2 + WSLg combo. They are **not** the primary path on bare metal.

**WSLg and “where did my window go?”** Linux GUIs often show up in a **Remote Desktop** (`msrdc`) window whose title may mention your distro (e.g. `… (Kinoite-WS2)`). It can sit minimized or behind other windows — try **Alt+Tab**, or from Windows run **`scripts/wsl2/Focus-Kinoite-WslgWindow.ps1`** to bring that window forward.

**[`../../scripts/bootstrap-kde-wsl.sh`](../../scripts/bootstrap-kde-wsl.sh)** — Entry point for optional Plasma on WSLg: `hints`, `plasma` (shell only), or `launch` (full). Wraps **`launch-kde-gui-wslg.sh`**.

**`launch-kde-gui-wslg.sh`** — Starts Plasma shell and KDE-oriented apps; defaults to **X11 (`:0`, `xcb`)** so Qt windows map reliably on WSLg.

**`smoke-wslg-gui.sh`** — Minimal **`kdialog`** test. If this never appears, fix Windows/WSLg/session first, not Plasma packaging.

**`Show-Kinoite-Gui.ps1`** — PowerShell wrapper that **`Start-Process`**’es `wsl.exe` from the desktop session (helps when GUI only attaches from an interactive Windows session).

**`Focus-Kinoite-WslgWindow.ps1`** — Brings the **msrdc** WSLg window to the foreground.

If **`[interop] appendWindowsPath=false`** is set in `wsl.conf`, **`cmd.exe` is not on PATH inside WSL** — that is intentional, not a sign that GUI failed.

**Why a naive one-liner fails:** `wsl … sh -lc "cmd & cmd & cmd &"` often exits immediately; background jobs may never attach cleanly to WSLg. The launch script uses **`nohup`**, spacing, and logs under **`/tmp/kinoite-wsl2-gui/`**.

**If GUI never appears from Cursor’s integrated terminal:** WSLg sometimes only binds GUI when **`wsl.exe`** runs from your **interactive Windows session**. From PowerShell you can do:

```powershell
Start-Process wsl -ArgumentList @("-d","YourDistroName","--","bash","/path/in/wsl/to/scripts/wsl2/launch-kde-gui-wslg.sh")
```

Or use **Windows Terminal** → `wsl -d YourDistroName` → run the same `bash` line there.

**If you are not using WSL2:** ignore this entire subsection. On metal you **log in at the display manager** and run KDE normally; you do not need PowerShell launchers or WSLg focus scripts.

---

## Files in `config/wsl2/`

- **`windows.wslconfig.example`** — Template for the **Windows** file **`%UserProfile%\.wslconfig`**.
- **`distro.wsl.conf.example`** — Template for the **guest** file **`/etc/wsl.conf`** (systemd, default user, optional interop).
- **`profile.d-00-kinoite-wslg-env.sh.example`** — Optional **`/etc/profile.d`** fragment for WSLg/Qt env.
- **`README.md`** — This file (single place for WSL2-specific explanation in this repo).

Other bootstrap/import scripts may still live under **`scripts/`** at repo root (e.g. import rootfs, first-boot hints). Those are WSL2 **workflow** scripts; when in doubt, this README’s rule stands: **if you are not on WSL2, use [GETTING_STARTED.md](../../GETTING_STARTED.md#step-3--edit-the-declarative-lists) and normal desktop login only.**
