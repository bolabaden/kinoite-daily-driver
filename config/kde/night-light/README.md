# Night Light (KWin) + day/night schedule (Knight Time)

This matches **Display & Monitor → Night Light** and **Day–Night Cycle / location** as in Plasma 6: **enabled**, **sunrise/sunset** schedule, **6500K day / 4500K night**, **location from device** with **automatic** detection (GeoClue2 when available).

## What gets written

| File | Purpose |
|------|---------|
| `kwinrc` → `[NightColor]` | Night Light on, `DarkLight` mode, temperatures |
| `knighttimerc` → `[General]` + `[Location]` | Schedule source = location; automatic location |

Schema references (upstream):

- [KWin `nightlightsettings.kcfg`](https://github.com/KDE/kwin/blob/master/src/plugins/nightlight/nightlightsettings.kcfg) — group `NightColor`
- [Plasma Workspace `nighttimesettings.kcfg`](https://github.com/KDE/plasma-workspace/blob/master/kcms/nighttime/nighttimesettings.kcfg) — file `knighttimerc`

## Apply

From a clone of this repo **inside Kinoite** (WSL2 or bare metal), as your normal user:

```bash
./scripts/apply-kde-night-light.sh
```

Optional: write to a specific config dir (e.g. when scripting for another user):

```bash
KINOITE_KDE_CONFIG_HOME=/var/home/someuser/.config ./scripts/apply-kde-night-light.sh
```

Then **log out and back in**, or restart KWin (`kwin_wayland --replace` / `kwin_x11 --replace` depending on session).

## Automatic location (GeoClue)

“Automatically detect location” expects **GeoClue** (and usually **xdg-desktop-portal**) to be working. On minimal installs, ensure `geoclue2` is installed and the location agent is allowed in **System Settings → Privacy → Location**. In **WSL2**, GeoIP-based location can be coarse or surprising; for a fixed site you can instead set manual coordinates in **Day–Night Cycle** (then `Automatic=false` and latitude/longitude in `knighttimerc` — extend the apply script if you need that).

## Packages

Plasma pulls in **knighttime** / **knighttimed** for the schedule API. This repo does not layer extra RPMs for basic Night Light; add `geoclue2` via `config/rpm-ostree/layers.list` only if your image lacks it.
