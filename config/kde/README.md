# KDE declarative snippets

| File | Used by | Purpose |
|------|---------|---------|
| [night-color.list](night-color.list) | `apply-atomic-provision.sh kde-night-light` | `kwriteconfig6` directives (`configfile\|group\|key\|value` per line) |

Edit [night-color.list](night-color.list) and re-run **`./scripts/apply-atomic-provision.sh kde-night-light`** as the **desktop** user (not via root-only sudo without `SUDO_USER`).

**Resolve order for the list file:** `KINOITE_NIGHT_COLOR_LIST` (if set), else **`config/kde/night-color.list` in the repo** you run from, else `/etc/kinoite-provision/kde/night-color.list` (installed by **`install-service`**, which copies the whole `config/kde` tree to `/etc/kinoite-provision/kde/`).
