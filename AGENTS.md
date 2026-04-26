## Learned User Preferences

- Keep Windows/WSL2/WSLg-only explanation in the single canonical doc `config/wsl2/README.md`; keep root `PROVISION` universal (no WSL-only sections or environment comparison tables).
- Onboarding (`GETTING_STARTED.md`): one shared step sequence for every install path; mention WSL2, VM, or imported-rootfs differences only in short per-step CAUTION blocks when behavior actually changes.
- Prefer Kinoite-first naming and Fedora Kinoite documentation links; do not treat Silverblue as the default parallel reference when Kinoite docs cover the same workflow.
- Avoid duplicating the WSL story across many files; one obvious funnel plus short pointers from other docs.

## Learned Workspace Facts

- Fedora Kinoite is provisioned declaratively via `config/rpm-ostree/layers.list`, `config/flatpak/*.list`, and `scripts/apply-atomic-provision.sh` (see root `PROVISION`).
- `config/wsl2/README.md` and `scripts/wsl2/` are the home for WSL2/WSLg host, guest, and GUI-helper material; non-WSL setups follow `PROVISION` and normal desktop login.
- Cross-repo plan references may use KotOR.js `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`; local coverage/verify scripts are written for that plan name.
- The repo uses `.gitattributes` with `* text=auto eol=lf` so text files stay LF in the index.
- **Secrets plane:** Wi‑Fi/VPN/credentials never belong in git — templates under `config/network/`, docs in `config/secrets/README.md`, real files in gitignored `host-local/` (see `GETTING_STARTED.md` step 3).
