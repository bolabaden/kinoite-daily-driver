# Windows 11 in QEMU/KVM (DCC / 3ds Max escape hatch)

When Linux-native tools are insufficient, run **Windows 11** as a **VM** on a Linux host with **GPU passthrough** (advanced) or accept software rendering for light tasks.

- **virt-manager** for QEMU/KVM on Fedora Workstation/Kinoite (may require layering).
- **Looking Glass** + VFIO is expert territory — validate against your motherboard/IOMMU groups.

This is **not** Phase A WSL work; it is a **parallel** capability on a future bare-metal Kinoite machine.
