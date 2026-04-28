"""
Entry: ``uv run kinoite-bootstrap-init`` or
``uvx --refresh --from git+https://github.com/bolabaden/kinoite-daily-driver kinoite-bootstrap-init``.

Extra CLI args are forwarded to ``Kinoite-AIO.ps1`` (Windows) or ``kinoite-aio.sh`` (other OS); examples:
``-Run MapImports,Bootstrap,Apply`` or ``-Run MigrateAppConfigs``.
When installed from an isolated venv (uvx), set ``KINOITE_WORKSPACE_ROOT`` to a full git clone
of this repository (the directory that contains ``scripts/``).
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path


def _find_repo_root() -> Path:
    here = Path(__file__).resolve()
    for p in (here, *here.parents):
        ps = p / "scripts" / "Kinoite-AIO.ps1"
        if ps.is_file():
            return p
    env = os.environ.get("KINOITE_WORKSPACE_ROOT", "").strip()
    if env:
        c = Path(env) / "scripts" / "Kinoite-AIO.ps1"
        if c.is_file():
            return Path(env)
    try:
        cwd = Path.cwd()
        for p in (cwd, *cwd.parents):
            if (p / "scripts" / "Kinoite-AIO.ps1").is_file():
                return p
    except OSError:
        pass
    print(
        "kinoite-bootstrap-init: set KINOITE_WORKSPACE_ROOT to a clone of\n"
        "  https://github.com/bolabaden/kinoite-daily-driver\n"
        "or run `uv run kinoite-bootstrap-init` from inside that repository.",
        file=sys.stderr,
    )
    sys.exit(2)


def _windows_powershell() -> str:
    for name in ("powershell.exe", "powershell"):
        w = shutil.which(name)
        if w:
            return w
    return r"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"


def _run_powershell_aio(repo: Path, argv: list[str]) -> int:
    aio = repo / "scripts" / "Kinoite-AIO.ps1"
    if not aio.is_file():
        print("Missing:", aio, file=sys.stderr)
        return 2
    ps = _windows_powershell()
    cmd = [ps, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(aio), *argv]
    env = {**os.environ, "KINOITE_WORKSPACE_ROOT": str(repo)}
    return subprocess.call(cmd, env=env, cwd=str(repo))


def _run_bash_aio(repo: Path, argv: list[str]) -> int:
    sh = repo / "scripts" / "kinoite-aio.sh"
    if not sh.is_file():
        print("Missing:", sh, file=sys.stderr)
        return 2
    cmd = ["/usr/bin/env", "bash", str(sh), *argv]
    env = {**os.environ, "KINOITE_WORKSPACE_ROOT": str(repo)}
    return subprocess.call(cmd, env=env, cwd=str(repo))


def main() -> None:
    repo = _find_repo_root()
    argv = list(sys.argv[1:])
    if os.name == "nt":
        raise SystemExit(_run_powershell_aio(repo, argv))
    raise SystemExit(_run_bash_aio(repo, argv))


if __name__ == "__main__":
    main()
