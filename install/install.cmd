@echo off
rem PeDitX-AI installer bootstrap: runs install.ps1 with execution policy bypass.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
