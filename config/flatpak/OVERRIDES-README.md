# Flatpak `override` list

[`overrides.list`](overrides.list) drives **`flatpak override --user`** for the **login user** the provision script targets (same as Flathub installs). Each non-comment line is:

```text
<app_ref> <override-args...>
```

Example (Steam host library access — **broad** filesystem access; use only if you understand the risk):

```text
com.valvesoftware.Steam --filesystem=host
```

The apply script runs overrides **after** `flatpak install` / `update` in the same pass. Overrides are idempotent: re-running may reset repeated flags; prefer one line per app.

**Not a substitute for Flatseal** for fine-grained toggles; this file is for **reproducible, reviewable** overrides you want in git.

## Secrets and paths

Do not put credentials in this file. Read-only path grants (`--filesystem=/path`) are data; PSKs and API keys belong in app-specific storage or `host-local/`, not in override args.
