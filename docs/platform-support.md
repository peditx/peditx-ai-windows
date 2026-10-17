# Platform support strategy

This repository is the Windows port of PeDitX-AI. It targets Windows 10 and Windows 11 on x64 as the only supported platform. The Linux desktop, headless Linux, and OpenWrt profiles live in the separate upstream repositories and are not built or tested here.

## Deployment profile

| Target | Intended experience | Installer path |
| --- | --- | --- |
| Windows 10/11 (x64) | Start Menu shortcuts, local browser UI on loopback, console CLI | NSIS per-user installer (`packaging/installer.nsi`) or PowerShell bootstrap (`install/install.ps1`) |

Requirements on the target machine:

- No Python install is needed for the NSIS build; PyInstaller bundles the interpreter. The PowerShell bootstrap and source runs need Python 3.10+.
- OpenSSH Client (optional Windows feature) for `ssh_command`.
- Poppler `pdftotext` on PATH (optional) for PDF attachments.
- `git` on PATH (optional) for Skills installed from Git and remote memory sync.

## Windows-specific behavior

- Config lives under `%APPDATA%\peditx-ai`, state under `%LOCALAPPDATA%\peditx-ai`. Both inherit the per-user AppData ACLs; the code applies no explicit ACL or chmod.
- The workspace validator blocks `C:\Windows`, `Program Files`, `ProgramData`, the `Users` tree, `AppData`, and drive roots.
- Ask-mode command allowlist contains Windows commands only; `shell=True` runs through `cmd.exe` and compound-command metacharacters are blocked.
- SMB uses `net use` with saved credentials; the app never prompts for or stores SMB passwords.
- The folder picker uses a PowerShell `FolderBrowserDialog`; browser launch uses `os.startfile`.
- The local HTTP server stays loopback-only with a per-launch bearer token. Do not expose it on a LAN or WAN until persistent authentication, TLS, and an explicit network-access setting exist.

## Support claims

"Runs on Python" is not evidence of Windows compatibility. A change is supported only after the NSIS artifact builds on `windows-latest`, installs per-user, starts the loopback server, and exercises chat, workspace validation, Ask-mode commands, and SSH against a verified host.
