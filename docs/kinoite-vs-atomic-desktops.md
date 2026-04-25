# Kinoite vs Silverblue (and siblings)

| Variant | Desktop | Notes |
|---------|---------|--------|
| **Fedora Kinoite** | KDE Plasma | **This workspace’s target** — same `rpm-ostree` / Flatpak model as other atomic desktops. |
| **Fedora Silverblue** | GNOME | Same OSTree technology; different default apps and settings. |
| **Fedora Sway Atomic** | Sway | Tiling WM stack. |

Pick **one** atomic variant per machine or VM; rebasing between them is supported on **real** ostree deployments (`rpm-ostree rebase`).
