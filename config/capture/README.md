# Capture → Linux mapping

Use **`config/capture/linux-map.template.csv`** as the header row for row-level Windows → Kinoite disposition.

## Columns

| Column | Meaning |
|--------|---------|
| `source_type` | `winget`, `registry_uninstall`, `appx`, `shortcut`, `manual`, … |
| `source_key` | Optional stable id (winget id, registry `PSChildName`, etc.) |
| `source_name` | Human-readable name from export |
| `source_version` | Version string if known |
| `publisher` | Publisher when known |
| `linux_plane` | `rpm-ostree`, `flatpak`, `distrobox`, `toolbox`, `podman`, `appimage`, `manual`, `windows_only` |
| `linux_artifact` | Package name, Flatpak ref, container image, or doc pointer |
| `confidence` | `high` / `med` / `low` |
| `notes` | Edge cases, licensing, metal-only, WSL caveat |

## Inputs

Generated under **`imports/`** (gitignored bulk) by **`scripts/run-full-plan-capture.ps1`**: `registry-uninstall-*.csv`, `appx-packages-*.csv`, `winget-export-*.json`, etc.

Keep filled maps in **`host-local/`** (gitignored) or merge into repo lists only after redacting machine-specific secrets.

## Stub merger

**`scripts/merge-linux-map-stub.ps1`** documents the merge contract; extend it to join winget + registry rows with a map file.
