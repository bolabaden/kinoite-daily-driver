# Network templates (Wi‑Fi / NM)

- **`wifi.example.nmconnection`** — rename/copy to **`host-local/`** (gitignored), fill **SSID**, add **PSK** only on the machine (`nmcli` or GUI). Do not commit the filled file.
- For **Ethernet** or **bond/bridge**, generate a profile with `nmcli connection add` once, then use it as a reference for future hosts.

After installing a connection file under `/etc/NetworkManager/system-connections/`:

```bash
sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
sudo nmcli connection reload
```

WSL2: Wi‑Fi is bridged from Windows; these flows target **bare metal** or **full VM** guests with a wireless NIC.
