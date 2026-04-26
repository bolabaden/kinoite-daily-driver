# Optional `provision.d` hooks

Scripts here run **after** Flatpak and `rpm-ostree` layering in `apply-atomic-provision.sh`, in **sorted** order.

## Rules

- Name hooks **`NN-descriptive-name.sh`** with a two-digit prefix (`10-`, `20-`, …).
- Mark them **executable** (`chmod +x`); non-executable files are skipped.
- Hooks must be **idempotent** — safe to run on every `apply-atomic-provision.sh` invocation.
- Skip all hooks: `KINOITE_SKIP_PROVISION_HOOKS=1 sudo ./scripts/apply-atomic-provision.sh`

## WSL vs bare metal

Use `grep -qi microsoft /proc/version` inside a hook if a step only applies on one environment. Do not assume Wi‑Fi or `fwupd` exist under WSL.

## First-boot gating (optional)

To run a hook only until a marker exists:

```bash
MARK=/var/lib/kinoite-provision/hook-10-example.done
[ -f "$MARK" ] && exit 0
# ... work ...
touch "$MARK"
```
