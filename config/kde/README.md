# KDE / Plasma provisional config (user scope)

These files are **not** applied by `rpm-ostree`. They target **`$XDG_CONFIG_HOME`** (usually `~/.config`) on the logged-in Plasma user — the same idea as other dotfiles: version the desired state in git, run a small script once per user or after a fresh home directory.

| Topic | Location |
|-------|----------|
| Night Light + sunrise/sunset + automatic location | [night-light/](night-light/) |

Run the apply scripts **as the desktop user** (not `sudo`), unless you set `KINOITE_KDE_CONFIG_HOME` to another user’s config directory on purpose.
