# Kinoite and other Fedora Atomic Desktops

| Variant | Desktop | Notes |
|---------|---------|--------|
| **Fedora Kinoite** | KDE Plasma | **This workspace’s target** — `rpm-ostree` + Flatpak, KDE by default. |
| **Fedora Atomic Desktop (GNOME)** | GNOME | Sister atomic edition: same upgrade and layering model, different default desktop and apps. |
| **Fedora Sway Atomic** | Sway | Tiling window-manager stack. |

Pick **one** atomic variant per machine or VM; rebasing between them is supported on **real** ostree deployments (`rpm-ostree rebase`).
