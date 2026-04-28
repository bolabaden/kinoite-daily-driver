## Learned User Preferences

- Prefers minimal configuration surface: fewer knobs and files over exhaustive documentation.
- Wants aggressive repo consolidation: merge or delete redundant scripts and docs; during cleanup passes, expects a large reduction in peripheral file count (merge or remove roughly half of thin/redundant pieces).
- When following an attached implementation plan, do not edit the plan file itself; use existing todos and mark them in progress until all are completed.
- Wants WSL2 versus bare-metal guidance in one obvious place (ideally a single doc), with non-WSL2 steps clearly contrasted—not scattered across many small markdown files or heavy tables.
- Favors executable artifacts over prose: avoid piling on markdown; prefer removing thin `.md` files and replacing them with working `config/` and `scripts/` that fully implement the behavior; in consolidation passes, avoid iteratively growing or editing markdown unless the user explicitly asked for doc changes.
- Use Kinoite naming throughout the repo (not Silverblue) when describing the Atomic KDE variant.
- PowerShell flows that need admin (e.g. DISM) should spawn an elevated process when the caller is not elevated, capture output, and return it to the original script—run until the automation actually works end-to-end.
- Repo text files should use LF in Git (root `.gitattributes` with `* text=auto eol=lf`).
- On Windows, run `npm`/`npx` as separate commands (do not concatenate `npm … cache verify` and `npx` on one line); after cache corruption, rebuild or point `npx` at a clean `--cache` path before retrying.
- Prefers each `.sh`/`.ps1` to be a single-purpose entrypoint; disfavors scripts whose only job is to invoke other scripts (keep orchestration in one obvious top-level tool, e.g. a UV app or a clearly named driver script).

## Learned Workspace Facts

- Primary working copy on Windows is `G:\workspaces\Kinoite`; from WSL it is commonly `/mnt/g/workspaces/Kinoite`.
- This repo documents WSL2 Kinoite with example distro name `Kinoite-WS2`, `systemd=true` and default user in `/etc/wsl.conf`, Plasma/WSLg via `scripts/wsl2/launch-kde-gui-wslg.sh`, and optional WSLg env when `scripts/bootstrap-kinoite-wsl2.sh` runs with `KINOITE_INSTALL_WSLG_PROFILE=1` (installs `/etc/profile.d/00-kinoite-wslg-env.sh` from the fenced `sh` block in `config/wsl2/README.md`).
- Project direction includes exhaustively capturing Windows 11-side settings, apps, and configuration into this tree and mapping them to Linux/Kinoite equivalents (host capture treated as in-scope for migration work); user-installed and OEM-bundled Windows software and settings are capture targets, not out-of-scope “exceptions” by default.
