# Migration checklist: WSL lab → bare-metal Kinoite

**This file** also includes **Phase B / C** [Kinoite guest VM with the official ISO (snapshots)](#kinoite-guest-vm-with-the-official-iso-phase-b-or-c), then **short Phase C** notes: [atomic updates / rollback](#atomic-updates-and-rollback), [firmware and Secure Boot](#firmware-and-secure-boot), [power and battery](#power-and-battery), [swap and zram](#swap-and-zram), [backup and sync](#backup-and-sync), and [filesystems and external drives](#filesystems-and-external-drives). Older one-topic stubs were merged here or removed; the former `virtualbox-kinoite-fallback.md` is § below.

- [ ] Export **Flatpak** list: `flatpak list --app --columns=application`
- [ ] Save **SSH keys** and **GPG** stubs (not private material in cloud).
- [ ] Document **`rpm-ostree` layers** you actually used on real ostree (not applicable if `rpm-ostree` never worked in WSL).
- [ ] Re-create **Podman** volumes / quadlets from compose files kept in this workspace.
- [ ] Verify **firmware** updates (`fwupd`) on the laptop/desktop before go-live.

## Windows 11 guest VM on Linux (QEMU and KVM)

When Linux-native tools are insufficient, run **Windows 11** as a **VM** on a Linux host with **GPU passthrough** (advanced) or accept software rendering for light tasks.

- **virt-manager** for QEMU/KVM on Fedora Workstation/Kinoite (may require layering `libvirt` / `virt-manager` per your `layers.list`).
- **Looking Glass** + VFIO is expert territory — validate against your motherboard and IOMMU groups.

This is **not** Phase A WSL work; it is a **parallel** capability on a future **bare-metal** Kinoite machine (e.g. **3ds Max** and other **Windows-only DCC** — see also [app-mapping — 3D and Autodesk (DCC)](app-mapping.md#3d-and-autodesk-dcc) and [app-mapping — keep Windows/VM](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads)).

## Kinoite guest VM with the official ISO (Phase B or C)

Use when **Kinoite-in-WSL2** is insufficient (GPU, full Plasma session, stable `rpm-ostree` upgrades) or as a **parallel** reference environment. *(Merged from the former `virtualbox-kinoite-fallback.md`.)*

1. Download the [official Kinoite ISO](https://fedoraproject.org/atomic-desktops/kinoite/download/).
2. Create a VM: **EFI**, **8 GB RAM** (minimum comfortable), **60+ GB** disk.
3. After install: `sudo rpm-ostree upgrade` → reboot; add **RPM Fusion** per Fedora Atomic docs if you need codecs (see [app-mapping — Steam, Proton, anti-cheat](app-mapping.md#steam-proton-heroic-and-anti-cheat) / [LLM + media — homelab](llm-and-dev-ai.md#media-and-homelab-jellyfin-plex-and-arr)).
4. **Snapshots** before experimental `rpm-ostree install` / Plasma changes — see [Snapshots workflow (VirtualBox)](#snapshots-workflow-virtualbox) below.

Guest additions on atomic hosts require layering the correct package set for your hypervisor — follow current Fedora docs for the release year.

## Snapshots workflow (VirtualBox)

1. **Power off** the VM cleanly (`sudo systemctl poweroff` inside the guest).
2. **Snapshot** in the VirtualBox UI before `rpm-ostree install` or risky Plasma experiments.
3. **Restore** the snapshot if the guest fails to boot.

## Atomic updates and rollback

On **real** ostree-booted systems:

- `sudo rpm-ostree upgrade` then reboot.
- `sudo rpm-ostree rollback` to return to the previous deployment.

In **WSL** with a **container-exported** rootfs, `rpm-ostree` may be **unavailable** — treat rollback as **restore WSL from backup tar** or re-import. See [kinoite-wsl2.md](kinoite-wsl2.md).

## Firmware and secure boot

- **`fwupd`** applies on **physical** Fedora installs; not meaningful inside WSL.
- **Secure Boot** + **third-party drivers** (NVIDIA): follow Fedora and vendor docs for the specific release.

## Power and battery

- **Powerdevil** (Plasma) profiles for AC vs battery.
- **TLP** / **auto-cpufreq** are optional; test stability on your hardware before layering on atomic hosts.

## Swap and zram

Fedora often enables **zram** by default. For heavy builds, consider a **swap file** on a fast disk on **bare metal**.

Inside **WSL2**, memory policy is dominated by **Windows host RAM** — tune **`.wslconfig`** on Windows if you OOM during large exports (see [config/wsl2/README.md](../config/wsl2/README.md)).

## Backup and sync

- **Deja Dup** / **Pika Backup** (borg) for user data.
- **Syncthing** Flatpak for peer sync.
- **restic** / **rclone** in **toolbox** for scripted backups.
- OSTree hosts: remember **`rpm-ostree` rollback** is **system** state, not a substitute for **user data** backups.

*Merged from the former `docs/backup-and-sync.md` — that file **removed**.*

## Filesystems and external drives

- **NTFS** on USB: `ntfs-3g` / kernel driver depending on Fedora version; **exFAT** widely used for cross-OS sticks.
- **BitLocker** volumes: may require **dislocker** or unlock in Windows first.
- **Windows partitions** from dual-boot: mount read-only until you understand fast startup/hibernation risks.

*Merged from the former `docs/filesystems-and-external.md` — that file **removed**.*
