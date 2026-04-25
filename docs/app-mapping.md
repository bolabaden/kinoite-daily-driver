# Windows → Fedora Kinoite application mapping

This file is a **working** companion to your **Cursor plan** inventory. Expand rows from sanitized `imports/winget-export-*.json`.

| Windows category | Kinoite-first | Parity |
|------------------|---------------|--------|
| ShareX | Flameshot, Spectacle, OBS, Ksnip | No 1:1 automation |
| Steam | `com.valvesoftware.Steam` + Proton | Anti-cheat gaps |
| Discord | `com.discordapp.Discord` / Vesktop | ~ |
| Cloudflare WARP | `cloudflare-warp` + warp-cli | ~ |
| VPN mesh | Tailscale, NetworkManager | High |
| Dev IDEs | VS Code / Cursor / Windsurf Linux builds | ~ |
| 3ds Max | VM or Windows | No native |

**Rule:** prefer **Flathub**; use **toolbox** for compiler sprawl; **`rpm-ostree install`** only on **real** atomic hosts when `rpm-ostree` works.
