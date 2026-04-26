---
title: Exhaustive provisional Kinoite provisioning + repo consolidation
type: feat
status: active
date: 2026-04-25
origin: user request + aggregated subagent findings (explore, ce-repo-research-analyst, ce-architecture-strategist, ce-best-practices-researcher, ce-web-researcher)
---

# Exhaustive provisional Kinoite provisioning + repo consolidation

## Overview

Turn this workspace into an **exhaustive, row-level** provisioning system for **Fedora Kinoite** aligned to **Windows 11 daily-driver** inventory: **immutability** (rpm-ostree + Flatpak + optional containers), **no plaintext secrets in git**, **no reinstall-every-boot** anti-patterns. **“Exhaustive”** means **every captured Windows line item and every doc category** maps to a **`linux_plane` + `linux_artifact`** disposition (CSV + lists), including **Windows-only** and **manual** rows — not “RPM for every `.exe`.” Consolidate overlapping **plan/docs** noise and remove **placeholder** dead ends.

---

## Problem Frame

- **Declarative spine exists** (`GETTING_STARTED.md`, `config/rpm-ostree/layers.list`, `config/flatpak/*.list`, `scripts/apply-atomic-provision.sh`) but **`layers.list` is almost entirely commented** and there is **no** automated path for NetworkManager, locale, VPN secrets, or a gitignored secrets plane.
- **Docs** cover many topics (networking, audio, gaming, printing, LLM, M365, etc.) but many files are **thin stubs**; **three plan crosswalk docs** overlap with `docs/provisional-configuration-index.md`.
- **Win11 → Kinoite** is tracked as **data**: `imports/*` capture on Windows, **`config/capture/linux-map.template.csv`** for per-row disposition, category tables in **`docs/win11-kinoite-parity-matrix.md`**. Proprietary CAD, anti-cheat, OEM bundles, etc. are **`windows_only` / `manual` rows**, not undocumented gaps.

---

## Requirements Trace

- R1. **Expand `layers.list`** to reflect doc-derived **host packages** (printing, codecs policy, input, BT, power tools, virtualization helpers, etc.) with **minimal layering** discipline per rpm-ostree handbook.
- R2. **Expand Flatpak lists** (and/or split new lists) so **desktop-core / dev / gaming** reflect `docs/app-mapping.md` + topic docs, without duplicating unmaintainable one-offs.
- R3. Add a **provisional secrets + host-local** workflow: templates in-repo, **rendered** files **gitignored**, documented merge to `/etc/NetworkManager/system-connections/` (0600, root), VPN imports, optional **SOPS/age** or **ansible-vault** convention — **no PSK/password in git**.
- R4. Add **optional hooks** (conceptually `scripts/provision.d/`, invoked from `apply-atomic-provision.sh`) for **first-boot markers** under `/var/lib/kinoite-provision/` and **idempotent** reconcile — **not** full reprovision every boot.
- R5. Add **locale/timezone/keyboard** one-shot documentation + optional script **targeting bare metal** (`timedatectl`, `localectl`) — no secrets.
- R6. **Repo cleanup**: gitignore or remove `.history/`, consolidate plan crosswalk docs, fix **empty `config/shell/`** story, demote stub docs into a **`docs/archive/`** or merge into parent topic guides.
- R7. Maintain **canonical funnels**: WSL-only narrative stays in `config/wsl2/README.md`; **universal** atomic path is **`GETTING_STARTED.md`**. Any **material** change to layers, secrets workflow, hook loader, or **capture/map** artifacts must update **WSL2 README** + **GETTING_STARTED** + `README` quick links so newcomers do not drift.

---

## Scope Boundaries

- **Non-goals:** Shipping proprietary installers, Windows ISOs, or license keys; automating **interactive** store OAuth (Steam/Epic) beyond documenting; **perfect** anti-cheat compatibility; committing **real** Wi-Fi PSKs or VPN private keys.
- **Deferred:** BlueBuild/custom OSTree images; full **Ansible pull** fleet pattern (document only unless later unit adds it); **Ignition** (wrong default for laptop Kinoite — see best-practices research).

---

## Context & Research

### Relevant code and patterns

- `scripts/apply-atomic-provision.sh` — config root resolution, WSL detection, Flatpak as login user, rpm-ostree install loop.
- `scripts/install-atomic-provision-service.sh` + `config/systemd/kinoite-atomic-ostree.service` — **ostree-only** boot path (`KINOITE_OSTREE_ONLY=1`).
- `config/kde/` + `scripts/apply-kde-night-light.sh` — pattern for **user-scoped** optional apply.
- Explore-agent **category matrix** maps each doc topic to rpm / flatpak / box / NM / fwupd / win-only.

### Institutional / web grounding

- rpm-ostree administrator handbook — **minimal layering**, containers for most software.
- NetworkManager keyfile docs — **0600**, root ownership, **secret flags**, `nmcli connection reload`.
- Fedora Atomic getting-started material — Flatpak + toolbox mental model; printing may require **layering** for CUPS filters.

---

## Key Technical Decisions

- **Single orchestrator:** extend **`scripts/apply-atomic-provision.sh`** (do not fork a second “provision desktop” entrypoint unless it is a thin alias).
- **Secrets:** repo holds **`.example`** + **README** under e.g. `config/secrets/README.md` + `config/network/example.nmconnection.template` **without** `psk=`; real tree `host-local/` or `secrets/` **gitignored**, documented copy commands.
- **First-boot vs idempotent:** destructive or expensive steps gated by **stamp files** in `/var/lib/kinoite-provision/`; list application remains safe to re-run.
- **WSL vs metal:** networking secrets and **fwupd** flows are **bare-metal first**; WSL continues to use `config/wsl2/README.md` expectations.

---

## Open Questions

### Resolved during planning

- **Cloud-init every boot?** Rejected — use staged deployment + optional timer only if reconcile is truly needed.
- **systemd-creds for NM Wi-Fi?** Not portable first choice; prefer NM keyfile + secret flags / keyring / gitignored keyfiles per NM docs.

### Deferred to implementation

- Exact **package names** for each layered stack (must be validated on a **real** Kinoite major version before uncommenting).
- Whether **RPM Fusion** (codecs) is acceptable for the maintainer’s legal posture — document as optional layer group.

---

## Implementation Units

- [x] U1. **Secrets + network templates scaffold**

**Goal:** Add a **gitignored** convention and in-repo **templates** for NM / VPN **without** credentials.

**Requirements:** R3

**Dependencies:** None

**Files:**
- Create: `config/secrets/README.md` (how to render, permissions, `nmcli connection reload`)
- Create: `config/network/*.nmconnection.example` (SSID, **no** `psk`, document `psk-flags` / post-hoc `nmcli`)
- Modify: `.gitignore` (e.g. `host-local/`, `secrets/`, `*.nmconnection` under a private path if needed — **careful** not to ignore tracked examples)
- Test expectation: none — documentation/scaffold only

**Verification:** `git check-ignore -v` behaves as intended; no secrets in tracked files.

---

- [x] U2. **Populate `config/rpm-ostree/layers.list` from doc matrix**

**Goal:** Uncomment / add **concrete** packages aligned to explore-agent categories (printing, CUPS deps, IBus/Fcitx5, TLP/auto-cpufreq optional, virt stack optional, `fwupd` already on metal, etc.) in **tiered comment blocks** (core / optional / proprietary-risk).

**Requirements:** R1, R7

**Dependencies:** U1 (for NM docs cross-links optional)

**Files:**
- Modify: `config/rpm-ostree/layers.list`
- Modify: `docs/networking.md` or `GETTING_STARTED.md` — pointer to layered printing/network packages as needed
- Modify: `GETTING_STARTED.md` — short pointer when new **metal-only** layers or secrets steps exist
- Modify: `config/wsl2/README.md` — only if WSL caveats for new layers change (otherwise explicit “no change” in PR notes)

**Test scenarios:**
- Happy path: `rpm-ostree status` on a test VM after apply shows expected packages pending reboot.
- Edge: WSL path — script warns / skips incompatible layers (document which lines are metal-only).

**Verification:** A test `apply-atomic-provision.sh` dry review (comment block) matches docs.

---

- [x] U3. **Expand Flatpak lists from `app-mapping` + topic docs**

**Goal:** Split or extend `config/flatpak/*.list` with IDs for browsers, chat, IDE flats, Steam/Heroic/Lutris/Bottles, backup (Syncthing, Pika/Deja Dup), multimedia, etc. — **bounded curated set** (maintainable defaults + comments pointing to Flathub search for long tail; **not** every optional app ID).

**Requirements:** R2

**Dependencies:** U2 (shared narrative)

**Files:**
- Modify: `config/flatpak/desktop-core.list`, `dev.list`, `gaming.list` (or add `flatpak/office.list`, `flatpak/media.list` if needed)
- Modify: `scripts/apply-atomic-provision.sh` only if new list globs required

**Verification:** `flatpak install` dry-run on test user matches lists.

---

- [x] U4. **Optional `scripts/provision.d/` hook loader**

**Goal:** Source or execute **numbered** hooks from `scripts/provision.d/` when present — **metal-only**, **WSL-only**, or **first-boot** gated by markers — without breaking idempotency.

**Requirements:** R4 only (optional hooks + first-boot markers; aligns with architecture decision to extend `apply-atomic-provision.sh` rather than duplicate orchestrators)

**Dependencies:** U2

**Files:**
- `provision.d` hooks: [scripts/README.md — Post-provision hooks](../../scripts/README.md#post-provision-hooks) (in-script doc; ex-`provision.d/README.md` merged there)
- Modify: `scripts/apply-atomic-provision.sh`

**Test scenarios:**
- Hook skipped when marker exists; runs once when marker absent.
- Missing `provision.d/` is silent.

**Verification:** Manual run on VM with a no-op hook file.

---

- [x] U5. **Locale / time / keyboard helper + doc**

**Goal:** Document and optionally implement `scripts/provision-locale.sh` (bare metal) wrapping `timedatectl` / `localectl` with **environment variables** or **gitignored** `host-local/locale.env` (no secrets).

**Requirements:** R5

**Dependencies:** U1 pattern for gitignored inputs

**Files:**
- Create: `scripts/provision-locale.sh` (optional)
- Modify: `GETTING_STARTED.md` — Step for timezone/keyboard

**Verification:** Running script sets expected `/etc` state on test VM.

---

- [x] U6. **Repo consolidation**

**Goal:** Reduce placeholder surface per repo-research-analyst: remove/ignore `.history/`, merge plan crosswalk into a single index (keep `plan-frontmatter-coverage.md` if verify script depends on it — **do not break** `verify-plan-frontmatter-coverage.ps1`), resolve `config/shell/` empty README, move thin stubs to `docs/archive/` **or** expand them to ≥10 useful lines.

**Requirements:** R6

**Dependencies:** None (can parallelize with U2–U5). **Merge order:** apply **U1 `.gitignore` rules first** in a single commit hunk or rebase so U6 additions (`/.history/` etc.) do not conflict with U1 `host-local/` patterns.

**Files:**
- Modify: `.gitignore`
- Modify: `README.md` (fewer duplicate links)
- Merged: `docs/archive/README.md` → [docs/README — Archived / superseded notes](../README.md#archived--superseded-notes) (the empty `docs/archive/` tree was later removed; policy lives in the doc hub only).
- Merged: phase “definition of done” and related material → [provisional-configuration-index.md#phases-definition-of-done](../provisional-configuration-index.md#phases-definition-of-done) (historical note; small stub files were later removed in favor of anchors in this file only).

**Test scenarios:**
- `scripts/verify-plan-frontmatter-coverage.ps1` still exits 0 when KotOR plan present.

**Verification:** Cleaner `git status`; no broken links in `README.md` quick table.

---

- [x] U7. **Parity matrix (row-level contract)**

**Goal:** One category table: **topic → automated here → manual → Windows-only**, citing [app-mapping — when to keep Windows or a VM](../app-mapping.md#when-to-keep-windows-or-a-vm-for-these-workloads) and [kinoite-wsl2 — WSL vs bare metal](../kinoite-wsl2.md#wsl2-vs-bare-metal-atomic-parity). Per-install rows live in **`config/capture/linux-map.template.csv`** + **`host-local/`** fills.

**Requirements:** R1–R3 and R7 (explicit disposition for automation vs manual vs Windows).

**Dependencies:** U2, U3 (category table can precede every CSV row filled)

**Files:**
- Create: `docs/win11-kinoite-parity-matrix.md`

**Verification:** Review with `docs/app-mapping.md` (incl. **Linux-map template** section) and the template file side-by-side.

---

- [x] U8. **Windows host capture extensions + linux-map scaffold**

**Goal:** Extend **`scripts/run-full-plan-capture.ps1`** with registry Uninstall CSV, Appx CSV, locale/network metadata (no PSK export), Run keys, optional DISM + pnputil; add **`config/capture/linux-map.template.csv`**, **`docs/app-mapping` — Linux-map section**, **`scripts/merge-linux-map-stub.ps1`**; gitignore **`imports/*.csv`** and **`imports/*.reg`**; document patterns in **[`scripts/README.md` — The imports directory](../../scripts/README.md#the-imports-directory)**.

**Requirements:** R7, exhaustive inventory traceability

**Dependencies:** U6 `.gitignore` discipline

**Files:**
- Modify: `scripts/run-full-plan-capture.ps1`, `.gitignore`, `scripts/README.md` (imports/ section)
- Create: `config/capture/linux-map.template.csv`, [app-mapping — Linux-map template](../app-mapping.md#linux-map-template-row-level-map) (ex-`config/capture/README.md`), `scripts/merge-linux-map-stub.ps1`

**Test expectation:** none — capture scripts; validate manually on Win11 host.

**Verification:** Full capture produces new artifacts and manifest lines; `git check-ignore` covers `imports/*.csv`.

---

## System-Wide Impact

- **Provisioning** becomes multi-plane (ostree + flatpak + gitignored host-local); contributors must understand **gitignore** rules.
- **WSL users** must not assume metal-only layers apply; script messaging must stay accurate.
- **Security:** `.gitignore` and [GETTING_STARTED — gitleaks](../../GETTING_STARTED.md#optional-gitleaks); pre-commit optional.

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Layering explosion / rebase pain | Tiered comments; prefer Flatpak/distrobox; document “pin” escape hatch |
| Accidental secret commit | Templates only in git; `git-secrets` / gitleaks optional; code review |
| Fedora major version package renames | Re-verify package names per release; link to Fedora packages search |

---

## Documentation / Operational Notes

- `provisional-configuration-index.md` = KotOR matrix + plan-stipulated file tree + **phases A/B/C definition of done** + [docs/README.md](../README.md) hub (earlier one-file redirects for the same content were **deleted** to reduce file sprawl).
- `AGENTS.md` includes **secrets plane** bullet (host-local, no PSK in git).

### Research / review delegation (Cursor)

Parallel **Task** subagents (`ce-repo-research-analyst`, `ce-best-practices-researcher`, `ce-architecture-strategist`, `ce-web-researcher`, `ce-doc-review`, etc.) require available **model API quota**. When the harness returns **“API usage limit reached”**, run the same prompts again after the limit resets, or do a focused manual pass using [docs/README.md](../README.md#topic-docs-and-provisioning-plane) + `imports/*` capture + `config/capture/linux-map.template.csv`.

---

## Sources & References

- **Subagent syntheses:** explore (doc→provisioning matrix), ce-repo-research-analyst, ce-architecture-strategist, ce-best-practices-researcher, ce-web-researcher (NM keyfiles, printing, fwupd).
- **Upstream:** [rpm-ostree administrator handbook](https://coreos.github.io/rpm-ostree/administrator-handbook/), [nm-settings-keyfile](https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html), [Fedora Kinoite docs](https://docs.fedoraproject.org/en-US/fedora-kinoite/).

---

## Agent-native posture (condensed audit)

This repository is **documentation + shell/PowerShell automation**, not a product with a web UI or CRUD entities.

| Principle | Score | Notes |
|-----------|-------|--------|
| Action parity | N/A / partial | User runs scripts locally; agent can run same scripts in terminal — parity for **automation**, not for GUI-only flows (NM applet, KDE GUIs). |
| Tools as primitives | ✅ | Scripts are imperative steps; lists are data — acceptable for this repo class. |
| Context injection | N/A | No hosted agent runtime. |
| Shared workspace | ✅ | Same git tree for human and agent. |
| CRUD completeness | N/A | No entity store. |
| UI integration | N/A | No product UI. |
| Capability discovery | ⚠️ | Improve via `README.md` + `GETTING_STARTED.md` + `config/secrets/README.md` (U1, U6). |
| Prompt-native features | N/A | Not a prompt-defined app. |

**Overall:** agent-native concerns apply weakly; focus on **CLI idempotency**, **documented entrypoints**, and **no secret leakage**.
