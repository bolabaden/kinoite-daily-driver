# Flatpak overrides

- Use **Flatseal** or `flatpak override` to grant filesystem access, GPU devices, or Wayland/X11 sockets.
- Prefer **least privilege** — widen permissions only when an app breaks (IDEs, Steam library paths).

Example:

```bash
flatpak override --user --filesystem=host com.valvesoftware.Steam
```

(Only if you understand the security tradeoff.)
