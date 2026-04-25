# VirtualBox (or KVM) + Kinoite ISO — Phase B / C

Use when **Kinoite-in-WSL2** is insufficient (GPU, full Plasma session, stable `rpm-ostree` upgrades) or as a **parallel** reference environment.

1. Download the [official Kinoite ISO](https://fedoraproject.org/atomic-desktops/kinoite/download/).
2. Create a VM: **EFI**, **8 GB RAM** (minimum comfortable), **60+ GB** disk.
3. After install: `sudo rpm-ostree upgrade` → reboot; add **RPM Fusion** per Fedora Atomic docs if you need codecs (see `gaming-steam-epic.md` / `media-and-homelab.md`).
4. **Snapshots** before experimental `rpm-ostree install` / Plasma changes.

Guest additions on atomic hosts require layering the correct package set for your hypervisor — follow current Fedora docs for the release year.
