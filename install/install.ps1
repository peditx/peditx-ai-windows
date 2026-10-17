# PeDitX-AI Windows installer — per-user, no admin required.
# Copies the app to %LOCALAPPDATA%\peditx-ai, creates Start Menu shortcuts
# and peditx-ai / assist commands on the user PATH.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $env:LOCALAPPDATA "peditx-ai"
$binDir = Join-Path $appDir "bin"
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\PeDitX-AI"

# Stop a running server so files are not locked during copy.
Get-Process PeDitX-AI -ErrorAction SilentlyContinue | Stop-Process -Force

foreach ($dir in @($appDir, $binDir, $startMenu)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Copy-Item -Force (Join-Path $root "src\peditx_ai.py") $appDir
Copy-Item -Recurse -Force (Join-Path $root "web") $appDir
Copy-Item -Recurse -Force (Join-Path $root "assets") $appDir

# Wrapper commands. python launcher covers the Windows Store and python.org builds.
@(
    @{ name = "peditx-ai.cmd"; args = "" },
    @{ name = "assist.cmd";    args = " --cli" }
) | ForEach-Object {
    $content = "@echo off`r`nwhere py >nul 2>nul`r`nif %errorlevel%==0 (`r`n  py -3 `"$appDir\peditx_ai.py`"$($_.args) %*`r`n) else (`r`n  python `"$appDir\peditx_ai.py`"$($_.args) %*`r`n)"
    Set-Content -Path (Join-Path $binDir $_.name) -Value $content -Encoding ascii
}

# Add the bin directory to the user PATH when it is missing.
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
}

# Start Menu shortcuts through the shell COM object.
$shell = New-Object -ComObject WScript.Shell
$web = $shell.CreateShortcut((Join-Path $startMenu "PeDitX-AI.lnk"))
$web.TargetPath = "cmd.exe"
$web.Arguments = "/c py -3 `"$appDir\peditx_ai.py`" || python `"$appDir\peditx_ai.py`""
$web.WorkingDirectory = $appDir
$web.Description = "PeDitX-AI local assistant (web UI)"
$web.Save()
$cli = $shell.CreateShortcut((Join-Path $startMenu "PeDitX-AI CLI.lnk"))
$cli.TargetPath = "cmd.exe"
$cli.Arguments = "/k py -3 `"$appDir\peditx_ai.py`" --cli || python `"$appDir\peditx_ai.py`" --cli"
$cli.WorkingDirectory = $appDir
$cli.Description = "PeDitX-AI interactive CLI"
$cli.Save()

# Uninstaller entry so Windows can remove the app cleanly.
$uninst = Join-Path $appDir "uninstall.ps1"
@"
Get-Process PeDitX-AI -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Recurse -Force "$appDir" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$startMenu" -ErrorAction SilentlyContinue
`$p = [Environment]::GetEnvironmentVariable("Path","User") -replace [regex]::Escape("$binDir;?"), ""
[Environment]::SetEnvironmentVariable("Path", `$p, "User")
"@ | Set-Content -Path $uninst -Encoding UTF8
$uninstKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\PeDitX-AI"
New-Item -Path $uninstKey -Force | Out-Null
Set-ItemProperty -Path $uninstKey -Name "DisplayName" -Value "PeDitX-AI"
Set-ItemProperty -Path $uninstKey -Name "Publisher" -Value "PeDitX"
Set-ItemProperty -Path $uninstKey -Name "DisplayIcon" -Value (Join-Path $appDir "assets\peditx-ai.png")
Set-ItemProperty -Path $uninstKey -Name "UninstallString" -Value "powershell -NoProfile -ExecutionPolicy Bypass -File `"$uninst`""
Set-ItemProperty -Path $uninstKey -Name "NoModify" -Value 1 -Type DWord
Set-ItemProperty -Path $uninstKey -Name "NoRepair" -Value 1 -Type DWord

Write-Host "PeDitX-AI installed to $appDir"
Write-Host "Start it from the Start Menu, or run: peditx-ai   (web UI) / assist   (CLI)"
Write-Host "Open a NEW terminal for the peditx-ai command to be on PATH."
