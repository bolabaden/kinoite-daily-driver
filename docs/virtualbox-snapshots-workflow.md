# VirtualBox snapshots (Kinoite VM)

1. **Power off** VM cleanly (`sudo systemctl poweroff` inside guest).
2. **Snapshot** in VirtualBox UI before `rpm-ostree install` experiments.
3. **Restore** snapshot if the guest fails to boot.

This duplicates concepts in `virtualbox-kinoite-fallback.md` with an operations focus.
