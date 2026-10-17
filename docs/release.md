# Release and installer integration

Releases are built only on GitHub Actions, never locally.

| Role | Repo | Contains |
| --- | --- | --- |
| Source | `peditx/peditx-ai-windows` | Full project including `.github/workflows/build.yml` |
| Builder | `peditxos-passwall/peditx-ai-windows-builder` | Only the build workflow; checks out the source repo with `PEDITX_TOKEN` and publishes the release onto the source repo |

The source workflow builds `dist/PeDitX-AI.exe` with PyInstaller, wraps it with `makensis packaging/installer.nsi` into `PeDitX-AI-Setup-x64.exe`, uploads it as an artifact, and on a `v*` tag publishes a GitHub Release.

To release a version:

1. Bump `VERSION` in `packaging/installer.nsi` and `version` in `pyproject.toml` so they match.
2. Push to `main`, then dispatch the builder with `-f tag=vX.Y.Z`. Do not push a git tag by hand; the builder creates the release and a pushed tag would also fire the source workflow.
3. Verify with `gh release view vX.Y.Z --repo peditx/peditx-ai-windows`.

Pass an empty tag to build the installer without publishing a release. The NSIS uninstaller entry is registered under `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PeDitX-AI`; user config and chat history under AppData are deliberately kept on uninstall.
