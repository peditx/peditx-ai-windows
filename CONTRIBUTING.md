# Developing PeDitX-AI for Windows

PeDitX-AI for Windows is a standalone fork of the Linux project. Keep application code, web UI, assets, packaging, and release documentation here.

## Run from source

```powershell
cd PeDitX-AI-windows
$env:PYTHONPATH="src"; python -m peditx_ai        # web UI on http://127.0.0.1:8765
$env:PYTHONPATH="src"; python -m peditx_ai --cli  # terminal chat
```

The app uses only the Python standard library and opens a browser on a loopback-only HTTP service. `install\install.ps1` copies the files to `%LOCALAPPDATA%\peditx-ai` and creates Start Menu shortcuts; `packaging\build.ps1` produces the single-file exe and NSIS installer inputs.

## Project layout

- `src/peditx_ai.py`: backend, local HTTP service, CLI, tools, memory, skills, and remote sync.
- `web/index.html`: English desktop UI.
- `assets/peditx-ai.png`: app icon and logo (`peditx-ai.ico` is the same image in ICO form).
- `install/install.ps1`: per-user PowerShell installer with Start Menu shortcuts and an uninstaller registry entry.
- `packaging/build.ps1`: PyInstaller single-file build.
- `packaging/installer.nsi`: NSIS per-user installer.
- `.github/workflows/build.yml`: CI build and release.
- `docs/`: design notes and release/integration decisions.

## Portability direction

Keep platform-specific behavior behind `os.name` checks or clearly separated functions inside `peditx_ai.py`; do not scatter `nt`/`posix` branches through shared logic. Remote SSH payloads stay POSIX because the remote host is a Linux router. The web UI must remain loopback-only until remote authentication and transport protections are implemented. Read `docs/platform-support.md` before adding platform-specific behavior.

## Static checks before pushing

```bash
python3 -m py_compile src/peditx_ai.py
python3 scripts/check-errors.py
python3 scripts/test-trim-history.py
node scripts/check-render.js
```

Never compile locally. The exe and installer are produced only by GitHub Actions; see `docs/release.md`.
