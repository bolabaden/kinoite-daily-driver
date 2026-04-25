# WSL2 vs bare-metal atomic parity

**What matches well**

- Userland **Fedora** packages visible in the imported rootfs.
- **Flatpak** once user session and dbus exist (often needs **systemd** in `/etc/wsl.conf`).
- **toolbox** / **distrobox** for mutable `dnf` environments.

**What often does not match**

- **`rpm-ostree`**: may refuse to run if the environment was **not booted through libostree** (common when importing a **container export** as WSL rootfs). See `kinoite-wsl2.md` verified notes.
- **Firmware / secure boot / fwupd** — not applicable inside WSL.
- **Full Plasma session + SDDM** — use partial **`plasmashell`** experiments or move to **VM/bare metal**.

For **true** parity on upgrades and rollbacks, use the **Kinoite ISO** in a VM or bare metal.
