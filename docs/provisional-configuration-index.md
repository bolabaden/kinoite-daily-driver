# Provisional configuration index (exhaustive vs plan)

**If this file looks long, read only this box first:** (1) **[KotOR plan and workspace matrix](#kotor-plan-and-workspace-coverage-matrix)** — plan `todos` ↔ files, (2) **[Phases: definition of done](#phases-definition-of-done)** — what “A/B/C complete” means in **git** vs on **metal**, (3) **[Plan-stipulated file tree](#plan-stipulated-file-tree)** — plan “Workspace path” line-by-line. For topic docs and `rpm-ostree`/Flatpak mapping, use **[docs/README](README.md)**. Live execution: **[`../WORKSPACE_STATUS`](../WORKSPACE_STATUS.md)**.

This file maps **phases** from `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md` to **concrete** artifacts in **`G:\workspaces\Kinoite`**. The **plan file itself** is the **spec**; this repo is the **executed** workspace (see `../WORKSPACE_STATUS.md` for live state).

| Phase / topic | Plan intent | This workspace |
|---------------|------------|----------------|
| **Primary path** | `G:\workspaces\Kinoite` + optional `KINOITE_WORKSPACE_ROOT` | `README.md`, [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) |
| **Win11 map ↔ plan** | same host, inventory scripts + category table | [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md) (includes former baseline / evidence content) |
| **Phase A — Kinoite in WSL2** | `podman` pull/export → `wsl --import`; systemd, Plasma, Flathub, **declarative** layers; KotOR plan+AGENTS in **sibling** clone | `docs/kinoite-wsl2.md` (incl. **## Spec and the KotOR.js repository**), [plan-stipulated file tree](#plan-stipulated-file-tree) (below), `scripts/import-kinoite-rootfs-to-wsl.ps1`, `scripts/bootstrap-kinoite-wsl2.sh`, `config/rpm-ostree/layers.list`, `scripts/apply-atomic-provision.sh`, `GETTING_STARTED.md` (atomic provisioning) |
| **OSTree / rpm-ostree honesty** | No false claims for container import | [kinoite-wsl2 — Systemd and `rpm-ostree` (honesty)](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) |
| **Win11 → Kinoite app map** | TSV + winget; named apps (ShareX, Steam, …) | `docs/app-mapping.md` + `imports/winget-export.json` (**gitignored**; re-run `scripts/run-full-plan-capture.ps1` or `export-winget.ps1`) |
| **Keep Windows** | 3ds, anti-cheat, Voicemod-grade, ShareX automation | [app-mapping — when to keep Windows/VM](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads) |
| **Host tuning** | `.wslconfig` memory/swap, PATH noise | **`config/wsl2/`** — [windows.wslconfig.example](../config/wsl2/windows.wslconfig.example), [distro.wsl.conf.example](../config/wsl2/distro.wsl.conf.example); stubs: `config/.wslconfig.example`, `config/wsl.conf.example` |
| **Phase B / VirtualBox** | Kinoite ISO, snapshots | [migration-baremetal-checklist — Kinoite guest VM](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) (incl. [VirtualBox snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox)) |
| **Phase C / bare metal** | Migration, firmware, rebase, power, swap | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) (checklist + **OSTree**, **firmware**, **power**, **swap** sections) |
| **Daily driver KDE** | Plasma, fonts, input, audio, print | [kde-daily-driver (incl. provisional `config/kde/`)](kde-daily-driver-recommendations.md#provisional-kde-config-in-repo-user-scope) and topic hubs (network, games, …); **Night Light:** [`config/kde/night-light/`](../config/kde/night-light/README.md), [`scripts/apply-kde-night-light.sh`](../scripts/apply-kde-night-light.sh) |
| **Secrets + Wi-Fi + locale** | NM templates, gitignored `host-local/`, no PSK in git | [`config/secrets/README.md`](../config/secrets/README.md) (incl. `config/network/` template notes), [`scripts/provision-locale.sh`](../scripts/provision-locale.sh), [`docs/win11-kinoite-parity-matrix.md`](win11-kinoite-parity-matrix.md) |
| **provision.d hooks** | Optional post-apply scripts | [scripts/README — post-provision hooks (`provision.d/`)](../scripts/README.md#post-provision-hooks) |
| **Research** | Tavily / Firecrawl / external | [docs/README — Research](README.md#research-tavily-firecrawl-and-the-web), `../research/`, `../.firecrawl/README` |
| **Thin topic stubs** | Many `docs/*.md` are short pointers; merge only with link updates | `scripts/list-thin-docs.ps1` (line-count report) |
| **Inventory** | winget, shortcuts, registry ARP, Appx, locale/net, Run keys, DISM/pnputil (optional) | `scripts/run-full-plan-capture.ps1` (one-shot + **CAPTURE-MANIFEST**), [`scripts/README` — The imports directory](../scripts/README.md#the-imports-directory); **Win → Linux row map:** [app-mapping — Linux-map template](app-mapping.md#linux-map-template-row-level-map), `config/capture/linux-map.template.csv` |
| **Removed / renamed topic docs** | Single redirect table | **§ [Removed topic docs](#removed-topic-docs-replaced-by-repo-paths)** below |
| **Plan ↔ files** | Crosswalk | **§ [KotOR plan and workspace](#kotor-plan-and-workspace-coverage-matrix)** below |
| **Doc hub + topic → ostree/flatpak** | One page lists “read first,” full provision table, A–Z topic list | [`README.md`](README.md) — [Topic docs and provisioning](README.md#topic-docs-and-provisioning-plane) |
| **A/B/C “done”** | What repo vs machine means | **§ [Phases: definition of done](#phases-definition-of-done)** below |
| **All plan YAML ids (75)** | `todos` + **A** / **B** / **C** (ordered `id` list) | `docs/plan-frontmatter-coverage.md` |
| **Plan § file tree** | `Kinoite/ README, docs/…, config/, …` | [§ below](#plan-stipulated-file-tree) |
| **Tavily (agents)** | RAG / research params | [README — Tavily digest](README.md#tavily-agent-rag-and-cli-digest) |

---

## Removed topic docs (replaced by repo paths)

Bookmarked paths that **no longer exist** as `docs/*.md` — use these instead:

| Old path (removed) | Use instead |
|--------------------|-------------|
| `docs/appimage-on-atomic.md` | [`scripts/appimage-fuse-atomic.sh`](../scripts/appimage-fuse-atomic.sh), `fuse3` in [`config/rpm-ostree/layers.list`](../config/rpm-ostree/layers.list) (bare-metal tier; comment out on WSL if needed), [docs README — Topic docs and provisioning](README.md#topic-docs-and-provisioning-plane) |
| `docs/gear-lever.md` | [`config/flatpak/README`](../config/flatpak/README), [`scripts/flatpak-maintain.sh`](../scripts/flatpak-maintain.sh); [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) `doc-gear-lever` |
| `docs/optional-kde-wsl.md` | [`config/wsl2/README.md`](../config/wsl2/README.md), [`scripts/bootstrap-kde-wsl.sh`](../scripts/bootstrap-kde-wsl.sh), [`scripts/wsl2` helpers](../scripts/README.md#wsl2-and-wslg) |
| `docs/wslg-clipboard-gui.md` | [`config/wsl2/README.md`](../config/wsl2/README.md), `config/wsl2/profile.d-00-kinoite-wslg-env.sh.example` |
| *Stub files removed* | [kinoite-wsl2 — parity](kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity) · [kinoite-wsl2 — other Atomic](kinoite-wsl2.md#kinoite-and-other-atomic-desktops) · [GETTING_STARTED — gitleaks](../GETTING_STARTED.md#optional-gitleaks) — *former* `wsl-atomic-parity.md`, `kinoite-vs-atomic-desktops.md`, `gitleaks-optional.md` **deleted**. |
| *More `docs/*` stubs removed* | [kinoite-wsl2 — honesty](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty) · [KDE+WSLg runtime bar](kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg) · [optional dnf in WSL](kinoite-wsl2.md#optional-classic-fedora-in-wsl) · [VirtualBox snapshots (migration)](migration-baremetal-checklist.md#snapshots-workflow-virtualbox) · [Windows 11 QEMU/KVM](migration-baremetal-checklist.md#windows-11-guest-vm-on-linux-qemu-and-kvm) · [This PC](win11-kinoite-parity-matrix.md#this-pc-quick-template) — *former* `systemd-rpm-ostree-wsl2-claims.md`, `kde-wsl2-runtime-verification.md`, `fedora-dnf-fallback-optional.md`, `virtualbox-snapshots-workflow.md`, `virtualization-windows-vm.md`, `this-pc-inventory-template.md` **deleted**; `virtualbox-kinoite-fallback.md` **merged** into [migration-baremetal-checklist — Kinoite guest VM](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c); `keep-windows.md` **merged** into [app-mapping — when to keep Windows/VM](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads); `flatpak-overrides.md` **merged** into [GETTING_STARTED — Step 6 / Flatpak overrides](../GETTING_STARTED.md#flatpak-overrides-optional-per-app); `3d-and-autodesk.md` **merged** into [app-mapping — 3D and Autodesk (DCC)](app-mapping.md#3d-and-autodesk-dcc); `bluetooth-pipewire.md` **merged** into [kde-daily-driver — Bluetooth / PipeWire](kde-daily-driver-recommendations.md#bluetooth-and-pipewire); `microsoft-365-on-linux.md` **merged** into [kde-daily-driver — Microsoft 365](kde-daily-driver-recommendations.md#microsoft-365-on-linux); `fonts-and-theming.md` **merged** into [kde-daily-driver — Fonts and theming](kde-daily-driver-recommendations.md#fonts-and-theming-kinoite); `podman-and-toolbox.md` **merged** into [ides-and-terminals — Podman / toolbox / distrobox](ides-and-terminals.md#podman-toolbox-and-docker-compatibility); `media-and-homelab.md` **merged** into [llm-and-dev-ai — Media and homelab](llm-and-dev-ai.md#media-and-homelab-jellyfin-plex-and-arr); `secrets-ssh-gpg.md` **merged** into [networking — Secrets, SSH, and GPG](networking.md#secrets-ssh-and-gpg); `backup-and-sync.md` **merged** into [migration-baremetal — Backup and sync](migration-baremetal-checklist.md#backup-and-sync); `filesystems-and-external.md` **merged** into [migration-baremetal — Filesystems and external drives](migration-baremetal-checklist.md#filesystems-and-external-drives); `input-and-ime.md` **merged** into [kde-daily-driver — Input, IME, and accessibility](kde-daily-driver-recommendations.md#input-ime-and-accessibility); `printing-and-scanning.md` **merged** into [kde-daily-driver — Printing and scanning](kde-daily-driver-recommendations.md#printing-and-scanning); `gaming-steam-epic.md` **merged** into [app-mapping — Steam, Proton, anti-cheat](app-mapping.md#steam-proton-heroic-and-anti-cheat); `audio-and-display.md` **merged** into [kde-daily-driver — Audio and display](kde-daily-driver-recommendations.md#audio-and-display) (Bluetooth: [`#bluetooth-and-pipewire`](kde-daily-driver-recommendations.md#bluetooth-and-pipewire)); `config/capture/README.md` **merged** into [app-mapping — Linux-map template](app-mapping.md#linux-map-template-row-level-map); `config/network/README.md` **merged** into [secrets — On-disk network templates](../config/secrets/README.md#on-disk-network-templates). |
| *Meta / plan-link stubs removed* | [Phases: definition of done](#phases-definition-of-done) · [KotOR matrix](#kotor-plan-and-workspace-coverage-matrix) · [Plan-stipulated file tree](#plan-stipulated-file-tree) (this file); [Topic → provision](README.md#topic-docs-and-provisioning-plane); [README — Research](README.md#research-tavily-firecrawl-and-the-web); [Win11 evidence](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts); [Strategy Phase A in kinoite-wsl2](kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only) — *former* `phases-definition-of-done.md`, `plan-stipulated-file-tree.md`, `plan-alignment.md`, `doc-to-provision-map.md`, `windows11-daily-driver-baseline.md`, `strategy-phaseA-kinoite-wsl2.md`, `research-workflow-tavily-firecrawl.md` **deleted**. |
| *Phase C topic files removed* | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) — [atomic/rollback](migration-baremetal-checklist.md#atomic-updates-and-rollback), [firmware / Secure Boot](migration-baremetal-checklist.md#firmware-and-secure-boot), [power](migration-baremetal-checklist.md#power-and-battery), [swap / zram](migration-baremetal-checklist.md#swap-and-zram) — *former* `docs/atomic-updates-rollback.md`, `firmware-and-secure-boot.md`, `power-and-battery.md`, `swap-and-zram.md` were merged here and **deleted**. |

---

## KotOR plan and workspace coverage matrix

**Source of truth (spec):** the Cursor plan in the **KotOR.js** repository at `.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`. The **Kinoite** tree is a **sibling** workspace, not a subtree of that repo, so cross-links are by **convention**.

**Execution tree (this workspace):** `G:\workspaces\Kinoite` (or `KINOITE_WORKSPACE_ROOT`).

| Plan § / todo theme | In this workspace | Notes |
|---------------------|-------------------|-------|
| Phase A: Kinoite in WSL2, import, ostree | `docs/kinoite-wsl2.md` (**## Spec and the KotOR.js repository** + [honesty section](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty)), [plan-stipulated file tree](#plan-stipulated-file-tree) | WSL2 container import → `rpm-ostree` limitations documented in `kinoite-wsl2` |
| `wsl.conf` systemd, user | `config/wsl.conf.example` | |
| Host WSL2 VM | `config/.wslconfig.example` | |
| App mapping, winget, plan “this host” § | `docs/app-mapping.md`, [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts) (evidence), `scripts/export-winget.ps1`, `imports/winget-export.json` (gitignored) | |
| `KINOITE_WORKSPACE_ROOT` | [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) | plan workspace path + env |
| PC + shortcuts | [win11 matrix — This PC](win11-kinoite-parity-matrix.md#this-pc-quick-template), `scripts/list-windows-shortcuts.ps1` | **Same** as plan’s shortcut inventory pattern |
| Full Windows inventory | `scripts/run-windows-inventory.ps1` | CIM, `wsl -l -v`, podman |
| Phase B/C: VBox, bare metal | [migration — Kinoite guest VM + Win11 guest](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) | |
| *keep-windows* (merged) | [app-mapping#when-to-keep-windows…](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads) | |
| Daily driver topics (audio, print, games, …) | `docs/*.md` — [README.md](README.md#daily-driver-topic-guides-a--z-by-filename) and [Topic docs and provisioning](README.md#topic-docs-and-provisioning-plane) | |
| Research: Tavily / Firecrawl | [README — Research](README.md#research-tavily-firecrawl-and-the-web), `research/`, `.firecrawl/README` | |
| post-exec-mark-plan | completed | `WORKSPACE_STATUS.md`, KotOR plan **Status** + `AGENTS.md` |
| provision-atomic-declarative | `config/rpm-ostree/`, `apply-atomic-provision.sh`, `install-atomic-provision-service.sh`, systemd unit, `GETTING_STARTED.md` | Immutable provision (not docs-only) |
| 75 `id`s vs plan YAML + drift check | `docs/plan-frontmatter-coverage.md` Appendix C; `scripts/verify-plan-frontmatter-coverage.ps1` (exit 0 = all `id`s in coverage doc) or `scripts/verify-repo-health.ps1` (same + markdown link check) | Re-run when KotOR `kinoite_wsl_workspace_ec9c3c8b.plan.md` `todos` change |

**Frontmatter `todos`:** all **completed** or **cancelled** in plan; this workspace is the **materialized** deliverable; new or renamed `id`s in KotOR must be mirrored in `plan-frontmatter-coverage.md` (main table + **Appendix C**) and pass **`verify-plan-frontmatter-coverage.ps1`** (or **`verify-repo-health.ps1`** to include the link scan in the same run).

---

**“All phases complete” in documentation terms:** every **plan** deliverable that can be represented as **markdown + scripts + config templates** exists in-tree, [plan-frontmatter-coverage](plan-frontmatter-coverage.md) (including **Appendix C** — **75** YAML `id` values vs KotOR `kinoite_wsl_workspace_ec9c3c8b.plan.md`, verifiable with [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1) or [`../scripts/verify-repo-health.ps1`](../scripts/verify-repo-health.ps1)) is exhaustive, and [WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) + [app-mapping.md](app-mapping.md) + **`imports/CAPTURE-MANIFEST.txt`** (when present) names the current capture index under `imports/`. **Phases that require real hardware/ISO installs** (bare metal, full VBox run) are **checklisted** in the repo, not **machine-completed** from git alone; see **[Phases: definition of done](#phases-definition-of-done)** below.

---

## Phases: definition of done

*Plan vs this workspace — source:* **`.cursor/plans/kinoite_wsl_workspace_ec9c3c8b.plan.md`** in **KotOR.js**.

### Done in this tree (automation, not a handoff)

- Every YAML `todos` entry from the plan maps to a path in [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) (main table, Appendix A, B, and **C** = ordered **75** `id` list), including **declarative** Linux provision (`provision-atomic-declarative`); re-check with [`../scripts/verify-plan-frontmatter-coverage.ps1`](../scripts/verify-plan-frontmatter-coverage.ps1) or [`../scripts/verify-repo-health.ps1`](../scripts/verify-repo-health.ps1) after the KotOR plan’s `todos` change.
- **Windows (this host):** [`../scripts/run-full-plan-capture.ps1`](../scripts/run-full-plan-capture.ps1) runs `export-winget.ps1`, `run-windows-inventory.ps1`, `winget list`, `list-windows-shortcuts.ps1` into `imports/`, Scoop, StartApps, CIM hardware outline, performance + application log samples, **`wsl -d Kinoite-WS2`**, and **VBoxManage** presence. It overwrites **`imports/CAPTURE-MANIFEST.txt`** and stable artifact names. Re-run only after a **big** add/remove of Windows apps; update [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) as needed.
- **Linux (Kinoite) immutable provision:** [../GETTING_STARTED.md](../GETTING_STARTED.md#step-3--edit-the-declarative-lists), [`../config/rpm-ostree/layers.list`](../config/rpm-ostree/layers.list) + [config/flatpak/*.list](../config/flatpak/), [`../scripts/apply-atomic-provision.sh`](../scripts/apply-atomic-provision.sh), and optional boot [`../config/systemd/kinoite-atomic-ostree.service`](../config/systemd/kinoite-atomic-ostree.service) via [`../scripts/install-atomic-provision-service.sh`](../scripts/install-atomic-provision-service.sh).
- **KotOR.js (sibling checkout) and this tree:** the Kinoite workspace plan file lives in KotOR; how it maps to this repo and optional **`AGENTS.md`** pointers are in [kinoite-wsl2.md](kinoite-wsl2.md) (**## Spec and the KotOR.js repository**), [Plan-stipulated file tree](#plan-stipulated-file-tree) and [KotOR plan and workspace matrix](#kotor-plan-and-workspace-coverage-matrix) (Phase **A** rows), and [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md).
- Phase A oddities (e.g. `rpm-ostree` *not booted* on a container import) appear in `imports/wsl-Kinoite-WS2-verify.txt` and in `kinoite-wsl2.md` (including [honesty](kinoite-wsl2.md#systemd-and-rpm-ostree-in-wsl2-honesty)).

### Product completion: KDE + WSLg (cannot be “green” from git only)

A **runnable** Fedora Kinoite WSL2 install with an **interactive Plasma** experience under WSLg is a **separate** bar from “every plan `id` maps to a file” and “scripts exist.” **Minimum machine checks:** a **non-root** default user (`/etc/wsl.conf` + `wsl --shutdown`), a **WSLg** display session (`DISPLAY` / `WAYLAND_DISPLAY`), and **`plasmashell` actually running** when you want to call the desktop “functional.”

Coding agents in Cursor do **not** all have **windows-mcp** or **desktop-commander**; do not treat those as guaranteed for verification. Use [kinoite-wsl2 — runtime completion bar](kinoite-wsl2.md#runtime-completion-bar-kde-and-wslg) + [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) for the live checklist and [`../scripts/verify-kde-wsl2-runtime.sh`](../scripts/verify-kde-wsl2-runtime.sh) once the session is up.

### B / C: only physical installs are out of scope for a repo

| Phase | In git (complete when present) | Outside any script (requires an OS install or bare metal) |
|-------|--------------------------------|-----------------------------------------------------------|
| **A** | WSL2 rootfs, scripts, `docs/*`, `imports/*` with manifest, **`config/rpm-ostree` + `apply-atomic-provision.sh` + `GETTING_STARTED`** | Iterating until **satisfied** with a given `rpm-ostree` experiment — but **state is captured** in `WORKSPACE_STATUS` and `imports/`, not “pending on the user” for evidence. |
| **B** | [migration-baremetal-checklist — Kinoite guest VM](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) (ISO + [snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox)) — **repo deliverable: complete**. Machine: create VM, install guest additions, validate GPU. Evidence on Windows: `imports/host-tools.txt` (VBoxManage on `PATH` or not). |
| **C** | [migration-baremetal-checklist.md](migration-baremetal-checklist.md) (incl. former `firmware-*` / `atomic-*` / `power-*` / `swap-*` stand-alones) — **repo deliverable: complete** (firmware, ostree rollback, zram/swap, migration steps). Machine: real disk layout, `fwupd`, bare-metal install. |

**Win 11 + plan “Windows C”** evidence: [app-mapping.md](app-mapping.md), [win11-kinoite-parity-matrix.md](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts), and the **`CAPTURE-MANIFEST.txt`**. **Start Menu** for this host is in `imports/start-menu-shortcuts.txt` when produced by the full-capture path (same script; full capture) instead of only `%TEMP%`. Optional env: [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example).

---

## Plan-stipulated file tree

The plan **“Workspace path”** block in `kinoite_wsl_workspace_ec9c3c8b.plan.md` shows an example tree. This repository **includes** that tree **and** the **“(… other topic docs from prior plans …)”** expansion (atomic rollback, M365, games, 3D, swap, WSLg clipboard, etc. — all under `docs/`).

**Not in this path:** the **KotOR.js** game-engine repository (where the plan file and [AGENTS.md](https://github.com/KobaltBlu/KotOR.js/blob/master/AGENTS.md) live) is a **sibling** checkout, e.g. `c:\GitHub\KotOR.js` — it is **not** a subfolder of `G:\workspaces\Kinoite\`.

| Plan line / intent | In `G:\workspaces\Kinoite` |
|--------------------|----------------------------|
| `Kinoite/README.md` | [README.md](../README.md) |
| `WORKSPACE_STATUS.md` (plan’s execution log) | [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md) |
| `.gitignore` | [../.gitignore](../.gitignore) |
| `docs/kinoite-wsl2.md` | [kinoite-wsl2.md](kinoite-wsl2.md) — **authoritative Phase A**; [Strategy: Phase A in WSL2](kinoite-wsl2.md#strategy-phase-a-kinoite-in-wsl2-only) + [Kinoite vs other Atomic](kinoite-wsl2.md#kinoite-and-other-atomic-desktops) in the same file |
| `docs/plan-frontmatter-coverage.md` / [phases definition](#phases-definition-of-done) / Win11 evidence (merged) | [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md), [win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts](win11-kinoite-parity-matrix.md#host-evidence-and-capture-scripts) |
| `scripts/run-full-plan-capture.ps1` | [../scripts/run-full-plan-capture.ps1](../scripts/run-full-plan-capture.ps1) (full Win11+WSL evidence + `CAPTURE-MANIFEST`) |
| `scripts/apply-atomic-provision.sh` + `install-atomic-provision-service.sh` + `config/rpm-ostree/` + `config/systemd/kinoite-atomic-ostree.service` + `GETTING_STARTED` | [../GETTING_STARTED.md](../GETTING_STARTED.md#step-3--edit-the-declarative-lists), [../config/rpm-ostree/layers.list](../config/rpm-ostree/layers.list), [../scripts/apply-atomic-provision.sh](../scripts/apply-atomic-provision.sh), [../scripts/install-atomic-provision-service.sh](../scripts/install-atomic-provision-service.sh), [../config/systemd/kinoite-atomic-ostree.service](../config/systemd/kinoite-atomic-ostree.service) (plan: `provision-atomic-declarative`) |
| `scripts/import-kinoite-rootfs-to-wsl.ps1` | [../scripts/import-kinoite-rootfs-to-wsl.ps1](../scripts/import-kinoite-rootfs-to-wsl.ps1) (Phase A import) |
| `docs/app-mapping.md` + winget TSV | [app-mapping.md](app-mapping.md) + `imports/winget-export.json` (gitignored) |
| `app-mapping` (keep-Windows section) | [app-mapping#when-to-keep-windows…](app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads) |
| `docs/migration-baremetal-checklist.md` (Kinoite guest VM + snapshots) | [migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c](migration-baremetal-checklist.md#kinoite-guest-vm-with-the-official-iso-phase-b-or-c) (incl. [snapshots](migration-baremetal-checklist.md#snapshots-workflow-virtualbox)) |
| `(… other topic docs …)` | 40+ topic files — hub: [docs/README.md](README.md) + this file; every `doc-*` plan todo: [plan-frontmatter-coverage.md](plan-frontmatter-coverage.md) |
| `config/` | [wsl.conf.example](../config/wsl.conf.example), [`.wslconfig.example`](../config/.wslconfig.example), [flatpak/*.list](../config/flatpak/), [shell/](../config/shell/) ([ides — optional shell](ides-and-terminals.md#optional-shell-skeleton)) |
| `scripts/` | [../scripts/README.md](../scripts/README.md) (catalog); [../scripts/](../scripts/) |
| `imports/` | [scripts/README — The `imports` directory](../scripts/README.md#the-imports-directory) (bulk exports gitignored; **`CAPTURE-MANIFEST.txt`** can be committed) |
| **Env (plan):** `KINOITE_WORKSPACE_ROOT` | [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) |
| **Fallback path** `C:\Users\…\workspaces\Kinoite` | Same layout; [kinoite-workspace-root.env.example](../kinoite-workspace-root.env.example) can be edited to that path |

**Execution state** (not a second copy of the tree): [../WORKSPACE_STATUS.md](../WORKSPACE_STATUS.md).
