# Strategy: Phase A = Kinoite in WSL2 only

**Phase A** is **Fedora Kinoite** (OSTree / `rpm-ostree` + KDE-oriented atomic desktop bits) inside **WSL2**, with **systemd** and **WSLg** for GUI experiments.

**Not Phase A:** “Fedora for WSL” from the Store as a **dnf** substitute for the same goals. That path is **optional** and must be **explicitly** chosen; see `fedora-dnf-fallback-optional.md`.

**Why WSL2 first:** Same **Flatpak**, **toolbox/distrobox**, and **`rpm-ostree` mental model** as bare-metal Kinoite, with faster iteration — accepting WSL-specific fragility documented in `kinoite-wsl2.md`.
