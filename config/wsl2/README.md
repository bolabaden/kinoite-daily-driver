# WSL2 and WSLg — Windows-only Kinoite notes

**If you are not using WSL2** (bare-metal install, a normal VM, dual-boot, or anything that is not “Linux distro imported/running under Windows Subsystem for Linux”), **this whole file does not apply.** Close it and follow **[README — Step 3](../../README.md#step-3--edit-the-declarative-lists)**: edit `config/rpm-ostree/layers.list` and `config/flatpak/kinoite.list`, run `sudo ./scripts/apply-atomic-provision.sh` inside Kinoite, then **reboot the machine** (or your VM) after new `rpm-ostree` layers. Log in with your real display manager (e.g. SDDM) and use Plasma like any other desktop. Do **not** copy `config/wsl2/*` examples onto that system as “Linux config.”

**If you are using WSL2**, everything Windows- or WSLg-specific for this repo is meant to live **here** — templates **embedded in this README** (the fenced **`sh`** block under **Optional `/etc/profile.d` fragment** is what **`bootstrap-kinoite-wsl2.sh`** installs to `/etc/profile.d` when **`KINOITE_INSTALL_WSLG_PROFILE=1`**), plus helpers under `scripts/wsl2/`.

---

## Provisioning (same lists as everyone else)

WSL2 does **not** change how atomic provisioning works. You still edit the same lists and run the same apply script as bare metal:

- Edit **`config/rpm-ostree/layers.list`** and **`config/flatpak/kinoite.list`** (optional extra **`*.list`** in that directory).
- Inside the distro: **`sudo ./scripts/apply-atomic-provision.sh`** (from your clone path).
- After new **rpm-ostree** layers, from **Windows** run **`wsl --shutdown`** (or reboot Windows) so the next WSL start picks up the new deployment — **instead of** a full hardware reboot.

Optional boot-time layers-only service: **`sudo ./scripts/apply-atomic-provision.sh install-service YOUR_LINUX_USER`** — see [README — Step 7](../../README.md#step-7--optional-apply-only-layered-rpms-at-boot).

**If you are not using WSL2:** use a normal **reboot** of the physical machine or VM after layering, not `wsl --shutdown`.

---

## Host side: `%UserProfile%\.wslconfig` (Windows)

**WSL2:** copy the **example block below** into **`%UserProfile%\.wslconfig`** (this controls the WSL2 VM: memory, swap, processors, GUI, networking knobs). Run `wsl --shutdown` after changes.

**If you are not using WSL2:** there is **no** `.wslconfig`. Tune RAM, CPU, and power the usual way: firmware, hypervisor settings for VMs, or OS power profiles — not this repo’s WSL templates.

---

## Guest side: `/etc/wsl.conf` inside the WSL distro

**WSL2:** use the **example block below**. Typical goals: turn on **`systemd`** and set the **default WSL user**. Write into **`/etc/wsl.conf`** only inside the imported distro.

**If you are not using WSL2:** **`/etc/wsl.conf` is not a thing** for your setup. Use the installer and a real local user; use **SDDM**, **GDM**, or whatever display manager your spin ships — not WSL’s default-user mechanism.

---

## Optional: WSLg environment shim (`profile.d`)

**WSL2:** if Qt/Plasma under WSLg misbehaves, install a script from the **example block below** as e.g. `/etc/profile.d/00-kinoite-wslg-env.sh` to normalize **`USER`**, **`HOME`**, **`XDG_RUNTIME_DIR`**, **`QT_QPA_PLATFORM`**, etc. Optional WSLg glue.

**If you are not using WSL2:** **do not** install this shim. A normal Plasma session sets those for you; adding WSLg-oriented env is at best pointless and at worst confusing.

---

## Helper scripts under `scripts/wsl2/`

**Single catalog (no `README` inside `scripts/wsl2/`):** [scripts/README.md — WSL2 and WSLg](../../scripts/README.md#wsl2-and-wslg).

These exist **only** for the Windows + WSL2 + WSLg combo. They are **not** the primary path on bare metal.

**WSLg and “where did my window go?”** Linux GUIs often show up in a **Remote Desktop** (`msrdc`) window whose title may mention your distro (e.g. `… (Kinoite-WS2)`). It can sit minimized or behind other windows — try **Alt+Tab**, or from Windows run **`scripts/wsl2/Show-Kinoite-Gui.ps1 -Focus`** to bring that window forward.

**[`../../scripts/wsl2/launch-kde-gui-wslg.sh`](../../scripts/wsl2/launch-kde-gui-wslg.sh)** — Plasma (WSLg, optional **VcXsrv** `WSLG_GUI_BACKEND=vcxsrv`); first argument: **`menu`**, **`hints`**, **`plasma`**, **`launch`**, **`smoke`**, **`verify`**, **`install-check`**, **`sddm-note`**, **`wslg-config`**, **`vcxsrv-hints`**. TTY + **`KINOITE_INTERACTIVE=1`** (no first arg) opens a menu. Defaults to **X11 (`:0`, `xcb`)**.

**[`../../scripts/wsl2/Show-Kinoite-Gui.ps1`](../../scripts/wsl2/Show-Kinoite-Gui.ps1)** — **`wsl.exe`** from the desktop session; **`-Focus`**, **`-Action` Menu\|Focus\|Launch**; `KINOITE_WSL_BASH_INIT` for env passed into WSL. Does not call other **`.ps1`**.

**[`../../scripts/wsl2/Kinoite-WindowsPlasmaLogon.ps1`](../../scripts/wsl2/Kinoite-WindowsPlasmaLogon.ps1)** — Task Scheduler **`-Register`** / **`-RunSession`**; optional **`-StopExplorer`** (admin; risky). **Native KDE cannot replace the Windows shell**; this only starts the WSL GUI session after logon.

If **`[interop] appendWindowsPath=false`** is set in `wsl.conf`, **`cmd.exe` is not on PATH inside WSL** — that is intentional, not a sign that GUI failed.

**Why a naive one-liner fails:** `wsl … sh -lc "cmd & cmd & cmd &"` often exits immediately; background jobs may never attach cleanly to WSLg. The launch script uses **`nohup`**, spacing, and logs under **`/tmp/kinoite-wsl2-gui/`**.

**If GUI never appears from Cursor’s integrated terminal:** WSLg sometimes only binds GUI when **`wsl.exe`** runs from your **interactive Windows session**. From PowerShell you can do:

```powershell
Start-Process wsl -ArgumentList @("-d","YourDistroName","--","bash","/path/in/wsl/to/scripts/wsl2/launch-kde-gui-wslg.sh")
```

Or use **Windows Terminal** → `wsl -d YourDistroName` → run the same `bash` line there.

**If you are not using WSL2:** ignore this entire subsection. On metal you **log in at the display manager** and run KDE normally; you do not need PowerShell launchers or WSLg focus scripts.

---

## Example file contents (previously sidecar `.example` files; consolidated here)

### `windows.wslconfig` (place as `%UserProfile%\.wslconfig`)

```ini
# WSL2 HOST ONLY — not used on bare-metal Kinoite.
# After edits:  wsl --shutdown  then reopen the distro.
# https://learn.microsoft.com/en-us/windows/wsl/wsl-config#configuration-setting-for-wsl-2

[wsl2]
# memory=8GB
# processors=6
# swap=8GB
# networkingMode=Mirrored
guiApplications=true

# [experimental]
# autoMemoryReclaim=Gradual
```

### `/etc/wsl.conf` (inside the WSL guest)

```ini
# WSL2 GUEST ONLY — not read by bare-metal boot.
# After edits: from Windows:  wsl --shutdown  then  wsl -d YourDistro

[boot]
systemd=true

[user]
default=CHANGE_ME_LINUX_USER

[interop]
enabled=true
appendWindowsPath=false

[automount]
enabled=true
mountFsTab=true
options=metadata,umask=022,fmask=011
```

### Optional `/etc/profile.d` fragment (WSLg + Qt; do not use on metal)

```sh
#!/usr/bin/env sh
# WSL2 + WSLg — install to /etc/profile.d/ so all login shells get a stable GUI stack.
#   KINOITE_INSTALL_WSLG_PROFILE=1 ./scripts/bootstrap-kinoite-wsl2.sh
# (from repo root, inside the distro). On bare-metal Kinoite, do not install this file.
#
# Covers: X11/WSLg display, Wayland socket selection, Pulse on WSLg, Qt/GTK backends,
# optional HiDPI (set KINOITE_HIDPI_SCALE=1.25 or 2 in ~/.profile before this runs, or
# export in /etc/profile.d/zz-local.sh).

[ -n "${USER:-}" ] || export USER="$(id -un 2>/dev/null || echo CHANGE_ME)"
[ -n "${HOME:-}" ] || export HOME="$(getent passwd "$USER" | cut -d: -f6)"
[ -n "${SHELL:-}" ] || export SHELL="$(getent passwd "$USER" | cut -d: -f7)"

case "$(uname -r 2>/dev/null)" in
*Microsoft*|*microsoft*) ;;
*)
  return 0 2>/dev/null || exit 0
  ;;
esac

[ -n "${WSL_DISTRO_NAME:-}" ] || return 0 2>/dev/null || exit 0

_uid="$(id -u)"
_way="${WAYLAND_DISPLAY:-wayland-0}"

# Writable runtime + Wayland socket (WSLg vs normal user session)
if [ -S "/run/user/${_uid}/${_way}" ]; then
  export XDG_RUNTIME_DIR="/run/user/${_uid}"
elif [ -d /mnt/wslg/runtime-dir ]; then
  export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
  [ -S "/mnt/wslg/runtime-dir/${_way}" ] && export WAYLAND_DISPLAY="${_way}"
fi

# WSLg X server — clipboard is integrated; DISPLAY must be set for X11 clients
export DISPLAY="${DISPLAY:-:0}"

# Audio on WSLg (PipeWire/Pulse bridge)
if [ -S /mnt/wslg/PulseServer ] || [ -e /mnt/wslg/PulseServer ]; then
  export PULSE_SERVER="${PULSE_SERVER:-unix:/mnt/wslg/PulseServer}"
fi

# Session hints for KDE apps under WSLg
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-KDE}"
export DESKTOP_SESSION="${DESKTOP_SESSION:-plasma}"
export KDE_FULL_SESSION="${KDE_FULL_SESSION:-true}"

# Prefer Wayland-capable GTK; Qt defaults to xcb for broader WSLg compatibility (match launch-kde-gui-wslg.sh)
export GDK_BACKEND="${GDK_BACKEND:-wayland,x11}"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"

# Optional HiDPI: export KINOITE_HIDPI_SCALE=1.25 (or 1.5, 2) in zz-local.sh or ~/.profile
if [ -n "${KINOITE_HIDPI_SCALE:-}" ]; then
  export GDK_SCALE="${GDK_SCALE:-$KINOITE_HIDPI_SCALE}"
  export QT_SCALE_FACTOR="${QT_SCALE_FACTOR:-$KINOITE_HIDPI_SCALE}"
fi

# Firefox / Mozilla on Wayland when user forces Wayland session
export MOZ_ENABLE_WAYLAND="${MOZ_ENABLE_WAYLAND:-1}"
```

**Files in this folder** — this **`README.md` only** (WSL2 narrative; examples are embedded above).

Other bootstrap/import scripts may still live under **`scripts/`** at repo root (e.g. import rootfs, first-boot hints). Those are WSL2 **workflow** scripts; when in doubt, this README’s rule stands: **if you are not on WSL2, use [README — Step 3](../../README.md#step-3--edit-the-declarative-lists) and normal desktop login only.**
