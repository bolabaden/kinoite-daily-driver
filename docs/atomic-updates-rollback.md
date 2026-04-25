# Atomic updates and rollback (`rpm-ostree`)

On **real** ostree-booted systems:

- `sudo rpm-ostree upgrade` then reboot.
- `sudo rpm-ostree rollback` to return to the previous deployment.

In **WSL** with a **container-exported** rootfs, `rpm-ostree` may be **unavailable** — treat rollback as **restore WSL from backup tar** or re-import. See `kinoite-wsl2.md`.
