#!/usr/bin/env python3
"""
Read imports/winget-export.json + config/mappings/winget-to-kinoite.csv + optional overrides.csv,
emit host-local/flatpak/kinoite.generated.list, provision-report.md,
host-local/rpm-ostree/layers.fragment.list (deduped rpm tokens), optional host-local/locale.env stub.

Usage:
  python scripts/sync_imports_to_provision.py [--repo ROOT] [--imports DIR] [--strict]
  python scripts/sync_imports_to_provision.py --export-committed-csv [--repo ROOT]
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path


# Exact winget PackageIdentifier -> (disposition, flatpak_id, rpm_tokens, vendor_kind, creds, summary)
# disposition: flatpak | rpm | vendor | toolbox | skip_win_runtime | skip_ms_meta | documentation_gap | unknown
SPECIFIC: dict[str, tuple[str, str, str, str, bool, str]] = {
    "7zip.7zip": ("flatpak", "org.7-Zip.7-Zip", "", "", False, "7-Zip native"),
    "qBittorrent.qBittorrent": ("flatpak", "org.qbittorrent.qBittorrent", "", "", False, "qBittorrent"),
    "Discord.Discord": ("flatpak", "com.discordapp.Discord", "", "", False, "Discord"),
    "ShareX.ShareX": ("flatpak", "org.flameshot.Flameshot", "", "", False, "Screenshot + annotate (share workflows differ)"),
    "CPUID.HWMonitor": ("flatpak", "io.missioncenter.MissionCenter", "", "", False, "System monitor / sensors"),
    "GIMP.GIMP.3": ("flatpak", "org.gimp.GIMP", "", "", False, "GIMP"),
    "HermannSchinagl.LinkShellExtension": ("documentation_gap", "", "", "", False, "Hardlinks: use ln(1) / KDE Dolphin"),
    "MHNexus.HxD": ("flatpak", "net.werwolv.ImHex", "", "", False, "Hex editor"),
    "Resplendence.LatencyMon": ("documentation_gap", "", "", "", False, "DPC latency: pw-top perf dmesg — no single Linux twin"),
    "CrystalRich.LockHunter": ("documentation_gap", "", "", "", False, "lsof/fuser"),
    "Logitech.LGS": ("rpm", "", "solaar piper libratbag-ratbagd", "", False, "Solaar + Piper / ratbagd"),
    "Mozilla.Firefox": ("flatpak", "org.mozilla.firefox", "", "", False, "Firefox"),
    "Notepad++.Notepad++": ("flatpak", "org.kde.kate", "", "", False, "Kate / Kate editor"),
    "Daum.PotPlayer": ("flatpak", "org.videolan.VLC", "", "", False, "VLC / Celluloid"),
    "AntoineAflalo.SoundSwitch": ("documentation_gap", "", "", "", False, "PipeWire/KDE audio device switching"),
    "TeamViewer.TeamViewer": ("vendor", "", "", "teamviewer_rpm", True, "Vendor Fedora RPM from teamviewer.com"),
    "VapourSynth.VapourSynth": ("toolbox", "", "", "", False, "Video scripting in toolbox container"),
    "RedHat.Podman-Desktop": ("flatpak", "io.podman_desktop.PodmanDesktop", "", "", False, "Podman Desktop"),
    "ElementLabs.LMStudio": ("documentation_gap", "", "", "", False, "Ollama + Flathub LLM UI — not LM Studio"),
    "EclipseAdoptium.Temurin.21.JDK": ("toolbox", "", "", "", False, "JDK in distrobox/toolbx"),
    "EclipseAdoptium.Temurin.25.JDK": ("toolbox", "", "", "", False, "JDK in distrobox/toolbx"),
    "xpipe-io.xpipe": ("documentation_gap", "", "", "", False, "SSH: terminals / connections — see distro tools"),
    "BlenderFoundation.Blender": ("flatpak", "org.blender.Blender", "", "", False, "Blender"),
    "PrivateInternetAccess.PrivateInternetAccess": ("vendor", "", "", "pia_run", True, "PIA Linux .run installer"),
    "Malwarebytes.Malwarebytes": ("documentation_gap", "", "", "", False, "ClamAV optional in toolbox — no 1:1"),
    "OpenJS.NodeJS": ("toolbox", "", "", "", False, "Node via nvm/fnm in home or toolbox"),
    "SSHFS-Win.SSHFS-Win": ("documentation_gap", "", "", "", False, "sshfs FUSE on Linux — sshfs package"),
    "Microsoft.PowerShell": ("rpm", "", "powershell", "", False, "PowerShell for Linux RPM when desired"),
    "OpenVPNTechnologies.OpenVPN": ("documentation_gap", "", "", "", False, "NetworkManager OpenVPN import"),
    "Podman.CLI": ("rpm", "", "podman", "", False, "podman"),
    "Cloudflare.Warp": ("documentation_gap", "", "", "", False, "wgcf / Cloudflare WARP Linux docs"),
    "WinDirStat.WinDirStat": ("flatpak", "org.kde.filelight", "", "", False, "Disk usage"),
    "Autodesk.AutodeskAccess": ("documentation_gap", "", "", "", False, "Autodesk services — Windows-centric"),
    "Tailscale.Tailscale": ("rpm", "", "tailscale", "", False, "tailscale RPM"),
    "GoLang.Go": ("toolbox", "", "", "", False, "Go in toolbox"),
    "GitHub.cli": ("rpm", "", "gh", "", False, "gh CLI"),
    "EpicGames.EpicGamesLauncher": ("flatpak", "com.heroicgameslauncher.hgl", "", "", False, "Heroic for Epic/GOG"),
    "Anysphere.Cursor": ("flatpak", "com.visualstudio.code", "", "", False, "VS Code / VSCodium — closest OSS IDE"),
    "JohnMacFarlane.Pandoc": ("rpm", "", "pandoc", "", False, "pandoc"),
    "Kitware.CMake": ("rpm", "", "cmake", "", False, "cmake"),
    "OBSProject.OBSStudio": ("flatpak", "com.obsproject.Studio", "", "", False, "OBS"),
    "Valve.Steam": ("flatpak", "com.valvesoftware.Steam", "", "", False, "Steam — prefer native Linux builds"),
    "Spotify.Spotify": ("flatpak", "com.spotify.Client", "", "", False, "Spotify"),
    "LocalSend.LocalSend": ("flatpak", "org.localsend.localsend_app", "", "", False, "LocalSend"),
    "GitHub.GitHubDesktop": ("documentation_gap", "", "", "", False, "git + gh / KDE Git clients"),
    "Docker.DockerCLI": ("documentation_gap", "", "", "", False, "podman-docker / podman"),
    "flux.flux": ("documentation_gap", "", "", "", False, "Night Color / redshift on Plasma"),
    "Anthropic.Claude": ("flatpak", "org.mozilla.firefox", "", "", False, "Web + optional native wrappers"),
    "Microsoft.OneDrive": ("documentation_gap", "", "", "", False, "Nextcloud/rclone or web — no full parity"),
    "Rustlang.Rustup": ("toolbox", "", "", "", False, "rustup in home"),
    "Python.Python.3.13": ("toolbox", "", "", "", False, "uv / pyenv / toolbox Python"),
    "Google.Chrome.EXE": ("flatpak", "org.chromium.Chromium", "", "", False, "Chromium / Firefox"),
    "Microsoft.Edge": ("flatpak", "com.microsoft.Edge", "", "", False, "Edge Flatpak if desired"),
    "WiXToolset.WiXToolset": ("skip_win_runtime", "", "", "", False, "Windows installer toolchain — N/A"),
    "WinFsp.WinFsp": ("skip_win_runtime", "", "", "", False, "Windows FS — N/A"),
    "Microsoft.WSL": ("skip_win_runtime", "", "", "", False, "Host WSL — N/A on Linux guest"),
    "Microsoft.WindowsTerminal": ("documentation_gap", "", "", "", False, "Konsole / Ptyxis"),
    "VoodooSoft.DefenderUI": ("documentation_gap", "", "", "", False, "Host firewall + stock KDE security tools"),
    "MTSD.AllDup": ("documentation_gap", "", "", "", False, "fdupes / rdfind / KDE filelight dedupe workflows"),
    "DigitalVolcanoSoftware.DuplicateCleaner.4.Free": ("documentation_gap", "", "", "", False, "fdupes / rdfind"),
    "FreePascal.FreePascalCompiler": ("toolbox", "", "", "", False, "fpc in distrobox"),
    "Google.CloudSDK": ("toolbox", "", "", "", False, "gcloud in container or tarball"),
    "Jellyfin.Server": ("documentation_gap", "", "", "", False, "jellyfin-server rpm/podman per Fedora docs"),
    "CodecGuide.K-LiteCodecPack.Mega": ("documentation_gap", "", "", "", False, "ffmpeg + VLC Flatpak; no codec pack bundle"),
    "NSIS.NSIS": ("skip_win_runtime", "", "", "", False, "NSIS compiler — Windows-only toolchain"),
    "Plex.PlexMediaServer": ("documentation_gap", "", "", "", False, "plex-media-server rpm or official container"),
    "ElectronicArts.EADesktop": ("flatpak", "com.heroicgameslauncher.hgl", "", "", False, "Heroic / Lutris for stores"),
    "Python.Launcher": ("toolbox", "", "", "", False, "uv/python on PATH in toolbox"),
    "Apache.OpenOffice": ("flatpak", "org.libreoffice.LibreOffice", "", "", False, "LibreOffice"),
    "AviSynth.AviSynthPlus": ("documentation_gap", "", "", "", False, "VapourSynth stack in toolbox"),
    "Nvidia.PhysXLegacy": ("skip_win_runtime", "", "", "", False, "PhysX legacy Windows runtime — N/A"),
    "Kaitai.StructCompiler": ("toolbox", "", "", "", False, "kaitai-struct-compiler via npm/toolbox"),
    "GodotEngine.GodotEngine": ("flatpak", "org.godotengine.Godot", "", "", False, "Godot editor"),
    "LilyPond.LilyPond": ("rpm", "", "lilypond", "", False, "lilypond"),
    "MiKTeX.MiKTeX": ("toolbox", "", "", "", False, "texlive/MiKTeX in toolbox"),
    "MikeFarah.yq": ("rpm", "", "yq", "", False, "yq"),
    "RuneLite.RuneLite": ("flatpak", "net.runelite.RuneLite", "", "", False, "RuneLite Flatpak"),
    "StefanSundin.Superf4": ("documentation_gap", "", "", "", False, "xdotool/wmctrl; Plasma shortcuts"),
    "HTTPToolKit.HTTPToolKit": ("documentation_gap", "", "", "", False, "mitmproxy / proxyman alternatives"),
    "Replit.Replit": ("documentation_gap", "", "", "", False, "browser IDE or VS Code + remote"),
    "Amazon.Games": ("documentation_gap", "", "", "", False, "Heroic / Lutris"),
    "Codeium.Windsurf": ("flatpak", "com.visualstudio.code", "", "", False, "VS Code + extensions"),
    "Microsoft.Teams": ("flatpak", "com.github.IsmaelMartinez.teams_for_linux", "", "", False, "teams-for-linux unofficial client"),
    "Microsoft.VisualStudio.2022.BuildTools": ("toolbox", "", "", "", False, "gcc/llvm/rust for Linux builds in toolbox"),
    "XPDC2RH70K22MN": ("skip_ms_meta", "", "", "", False, "Microsoft Store stub ID"),
    "XP9KHM4BK9FZ7Q": ("skip_ms_meta", "", "", "", False, "Microsoft Store stub ID"),
}

PREFIX_RULES: list[tuple[re.Pattern[str], tuple[str, str, str, str, bool, str]]] = [
    (re.compile(r"^Microsoft\.VC"), ("skip_win_runtime", "", "", "", False, "VC++ redist — not used on Linux ELF")),
    (re.compile(r"^Microsoft\.DotNet"), ("toolbox", "", "", "", False, ".NET in toolbx if needed")),
    (re.compile(r"^Microsoft\.WindowsAppRuntime"), ("skip_ms_meta", "", "", "", False, "WinApp SDK — N/A")),
    (re.compile(r"^Microsoft\.VCLibs"), ("skip_ms_meta", "", "", "", False, "MSIX libs — N/A")),
    (re.compile(r"^Microsoft\.UI\.Xaml"), ("skip_ms_meta", "", "", "", False, "WinUI — N/A")),
    (re.compile(r"^Microsoft\.AppInstaller"), ("skip_ms_meta", "", "", "", False, "Store meta — N/A")),
    (re.compile(r"^Microsoft\.VisualStudio"), ("toolbox", "", "", "", False, "MSVC stack — use Linux toolchains in toolbox")),
    (re.compile(r"^XP[A-Z0-9]+$"), ("skip_ms_meta", "", "", "", False, "Microsoft Store opaque package id")),
]

# Windows display timezone id -> IANA (subset; extend as needed)
WIN_TZ_TO_IANA: dict[str, str] = {
    "Central Standard Time": "America/Chicago",
    "Central European Standard Time": "Europe/Berlin",
    "Pacific Standard Time": "America/Los_Angeles",
    "Mountain Standard Time": "America/Denver",
    "Eastern Standard Time": "America/New_York",
    "UTC": "UTC",
    "GMT Standard Time": "Europe/London",
    "W. Europe Standard Time": "Europe/Berlin",
}


def load_mapping_csv(path: Path) -> dict[str, tuple[str, str, str, str, bool, str]]:
    """CSV: source_id,disposition,flatpak_id,rpm_packages,vendor_install_kind,requires_credentials,native_replacement_summary[,toolbox_notes]"""
    if not path.is_file():
        return {}
    out: dict[str, tuple[str, str, str, str, bool, str]] = {}
    with path.open(newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        for row in r:
            sid = (row.get("source_id") or "").strip()
            if not sid or sid.startswith("#"):
                continue
            cred = (row.get("requires_credentials") or "").strip().lower() in ("1", "true", "yes")
            summ = (row.get("native_replacement_summary") or row.get("summary") or "").strip()
            out[sid] = (
                (row.get("disposition") or "documentation_gap").strip(),
                (row.get("flatpak_id") or "").strip(),
                (row.get("rpm_packages") or "").strip(),
                (row.get("vendor_install_kind") or "").strip(),
                cred,
                summ or "mapped",
            )
    return out


def build_full_mapping(repo: Path) -> dict[str, tuple[str, str, str, str, bool, str]]:
    """SPECIFIC < committed winget-to-kinoite.csv < overrides.csv (each layer overwrites)."""
    full: dict[str, tuple[str, str, str, str, bool, str]] = dict(SPECIFIC)
    committed = repo / "config" / "mappings" / "winget-to-kinoite.csv"
    full.update(load_mapping_csv(committed))
    overrides = repo / "config" / "mappings" / "overrides.csv"
    full.update(load_mapping_csv(overrides))
    return full


def resolve_row(pkg_id: str, full_map: dict[str, tuple[str, str, str, str, bool, str]]) -> tuple[str, str, str, str, bool, str]:
    if pkg_id in full_map:
        return full_map[pkg_id]
    for pat, row in PREFIX_RULES:
        if pat.match(pkg_id):
            return row
    return ("unknown", "", "", "", False, "Add row to winget-to-kinoite.csv or overrides.csv")


def load_json_export(path: Path) -> list[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    out: list[str] = []
    for src in data.get("Sources") or []:
        for pkg in src.get("Packages") or []:
            pid = pkg.get("PackageIdentifier")
            if pid:
                out.append(pid)
    return sorted(set(out))


def parse_locale_capture(repo: Path, imp_dir: Path) -> dict[str, str]:
    """Best-effort KINOITE_* from host-locale-network.txt or windows-inventory.txt."""
    env: dict[str, str] = {}
    for name in ("host-locale-network.txt", "windows-inventory.txt"):
        p = imp_dir / name
        if not p.is_file():
            continue
        text = p.read_text(encoding="utf-8", errors="replace")
        tz_block = False
        for line in text.splitlines():
            if "=== Get-TimeZone ===" in line:
                tz_block = True
                continue
            if tz_block and line.startswith("==="):
                break
            if tz_block:
                m = re.match(r"^\s*Id\s*:\s*(.+?)\s*$", line)
                if m:
                    win_id = m.group(1).strip()
                    if win_id in WIN_TZ_TO_IANA:
                        env["KINOITE_TIMEZONE"] = WIN_TZ_TO_IANA[win_id]
                    break
        loc_block = False
        for line in text.splitlines():
            if "=== Get-WinSystemLocale ===" in line or "IetfLanguageTag" in line and "===" in text:
                pass
            if "=== Get-WinSystemLocale ===" in line:
                loc_block = True
                continue
            if loc_block and line.startswith("===") and "Get-WinSystemLocale" not in line:
                break
            if loc_block:
                m = re.match(r"^\s*IetfLanguageTag\s*:\s*([\w-]+)", line)
                if m:
                    tag = m.group(1).strip()
                    env["KINOITE_LANG"] = tag.replace("-", "_") + ".UTF-8"
                    break
        if env:
            break
    return env


def collect_rpm_tokens(rows: list[tuple[str, str, str, str, bool, str]]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for disp, _fp, rpm, _v, _c, _s in rows:
        if not rpm:
            continue
        for tok in rpm.replace(",", " ").split():
            t = tok.strip()
            if t and t not in seen:
                seen.add(t)
                out.append(t)
    return sorted(out)


def export_committed_csv(repo: Path) -> None:
    path = repo / "config" / "mappings" / "winget-to-kinoite.csv"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "source_id",
                "disposition",
                "flatpak_id",
                "rpm_packages",
                "vendor_install_kind",
                "requires_credentials",
                "native_replacement_summary",
                "toolbox_notes",
            ]
        )
        for sid in sorted(SPECIFIC.keys()):
            disp, fp, rpm, vk, cred, summ = SPECIFIC[sid]
            w.writerow([sid, disp, fp, rpm, vk, "yes" if cred else "no", summ, ""])
    print(f"Wrote {path} ({len(SPECIFIC)} rows)")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", type=Path, default=Path(__file__).resolve().parent.parent)
    ap.add_argument("--imports", type=Path, default=None)
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--export-committed-csv", action="store_true", help="Write config/mappings/winget-to-kinoite.csv from SPECIFIC and exit")
    args = ap.parse_args()
    repo: Path = args.repo
    if args.export_committed_csv:
        export_committed_csv(repo)
        return 0

    imp_dir = args.imports or (repo / "imports")
    export_json = imp_dir / "winget-export.json"
    if not export_json.is_file():
        print(f"Missing {export_json}", file=sys.stderr)
        return 2

    full_map = build_full_mapping(repo)
    pkg_ids = load_json_export(export_json)
    host_local = repo / "host-local"
    flatpak_dir = host_local / "flatpak"
    rpm_frag_dir = host_local / "rpm-ostree"
    flatpak_dir.mkdir(parents=True, exist_ok=True)
    rpm_frag_dir.mkdir(parents=True, exist_ok=True)

    flatpak_ids: set[str] = set()
    rpm_rows: list[tuple[str, str, str, str, bool, str]] = []
    report_lines: list[str] = [
        "# Provision report (generated)",
        "",
        f"- Export: `{export_json}`",
        f"- Mapping: `{repo / 'config' / 'mappings' / 'winget-to-kinoite.csv'}`",
        f"- Overrides: `{repo / 'config' / 'mappings' / 'overrides.csv'}` (optional)",
        "",
        "## Rows",
        "",
        "| PackageIdentifier | disposition | flatpak | rpm | vendor | creds | summary |",
        "|---|---|---|---|---|---|---|",
    ]

    unresolved = 0
    for pid in pkg_ids:
        row = resolve_row(pid, full_map)
        disp, fp, rpm, vendor, creds, summary = row
        rpm_rows.append(row)
        if disp == "unknown":
            unresolved += 1
        if fp:
            flatpak_ids.add(fp)
        cred = "yes" if creds else ""
        report_lines.append(
            f"| `{pid}` | {disp} | `{fp}` | `{rpm}` | `{vendor}` | {cred} | {summary} |"
        )

    list_path = flatpak_dir / "kinoite.generated.list"
    list_path.write_text(
        "\n".join(sorted(flatpak_ids)) + ("\n" if flatpak_ids else ""),
        encoding="utf-8",
    )

    rpm_tokens = collect_rpm_tokens(rpm_rows)
    frag_path = rpm_frag_dir / "layers.fragment.list"
    frag_path.write_text(
        "# Merged by apply-atomic-provision.sh with config/rpm-ostree/layers.list\n"
        + "\n".join(rpm_tokens)
        + ("\n" if rpm_tokens else ""),
        encoding="utf-8",
    )

    locale_env = parse_locale_capture(repo, imp_dir)
    locale_path = host_local / "locale.env"
    if locale_env:
        lines = [f"{k}={v}" for k, v in sorted(locale_env.items())]
        locale_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    else:
        locale_path.write_text(
            "# No timezone/locale parsed from imports/host-locale-network.txt — set manually or re-run windows-inventory.\n",
            encoding="utf-8",
        )

    report_path = host_local / "provision-report.md"
    report_lines.append("")
    report_lines.append(f"- **Flatpak refs generated:** {len(flatpak_ids)}")
    report_lines.append(f"- **rpm tokens (fragment):** {len(rpm_tokens)}")
    report_lines.append(f"- **locale.env keys:** {len(locale_env)}")
    report_lines.append(f"- **unknown / needs mapping row count:** {unresolved}")
    report_path.write_text("\n".join(report_lines) + "\n", encoding="utf-8")

    print(f"Wrote {list_path} ({len(flatpak_ids)} flatpak ids)")
    print(f"Wrote {frag_path}")
    print(f"Wrote {locale_path}")
    print(f"Wrote {report_path}")
    if args.strict and unresolved:
        print(f"Strict: {unresolved} packages have no mapping", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
