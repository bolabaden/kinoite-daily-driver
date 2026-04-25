# Secrets, SSH, and GPG

- Store SSH keys under `~/.ssh` with correct permissions (`chmod 600`).
- **gpg-agent** + **KWallet** integration via Plasma crypto settings.
- **Hardware tokens:** `pcscd` may require layering on **real** atomic hosts.
- Never commit **private keys** into this workspace; use `ssh-agent` forwarding thoughtfully.
