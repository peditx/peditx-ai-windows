# Builds the single-file PeDitX-AI.exe with PyInstaller.
# Run from the repository root: powershell -File packaging\build.ps1
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

python -m pip install --quiet --upgrade pip pyinstaller
python -m PyInstaller --noconfirm --onefile --name PeDitX-AI `
    --icon assets\peditx-ai.ico `
    --add-data "web;web" --add-data "assets;assets" `
    --paths src src\peditx_ai.py

Write-Host "Built dist\PeDitX-AI.exe"
