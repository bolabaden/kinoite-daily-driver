# Networking and VPN

- **NetworkManager** + **nm-connection-editor** (or KDE applet) for Wi-Fi/Ethernet on laptops.
- **Tailscale** / **WireGuard** / **Cloudflare WARP**: prefer **one** primary tunnel; document **split routing** if you must combine (see upstream docs for each product).
- **Firewall:** `firewalld` on Fedora; atomic hosts still benefit from explicit zone rules for servers you run in **Podman**.

## Secrets, SSH, and GPG

- Store SSH keys under `~/.ssh` with correct permissions (`chmod 600`).
- **gpg-agent** + **KWallet** integration via Plasma crypto settings.
- **Hardware tokens:** `pcscd` may require layering on **real** atomic hosts.
- Never commit **private keys** into this workspace; use `ssh-agent` forwarding thoughtfully.

*Merged from the former `docs/secrets-ssh-gpg.md` — that file **removed**.*
