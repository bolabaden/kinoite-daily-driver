# Networking and VPN

- **NetworkManager** + **nm-connection-editor** (or KDE applet) for Wi‑Fi/Ethernet on laptops.
- **Tailscale** / **WireGuard** / **Cloudflare WARP**: prefer **one** primary tunnel; document **split routing** if you must combine (see upstream docs for each product).
- **Firewall:** `firewalld` on Fedora; atomic hosts still benefit from explicit zone rules for servers you run in **Podman**.
