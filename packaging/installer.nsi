; PeDitX-AI Windows installer (per-user, no admin).
; Expects dist\PeDitX-AI.exe from packaging\build.ps1 next to the project root.
; Build: makensis packaging\installer.nsi   (run from the repository root)

!define APPNAME "PeDitX-AI"
!define COMPANY "PeDitX"
!define VERSION "0.1.0"

Unicode True
SetCompressor /SOLID lzma

Name "${APPNAME}"
OutFile "${__FILEDIR__}\..\dist\PeDitX-AI-Setup-x64.exe"
InstallDir "$LOCALAPPDATA\Programs\${APPNAME}"
RequestExecutionLevel user

!include "MUI2.nsh"

!define MUI_ICON "${__FILEDIR__}\..\assets\peditx-ai.ico"
!define MUI_UNICON "${__FILEDIR__}\..\assets\peditx-ai.ico"
!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Install"
    SetOutPath "$INSTDIR"
    File "${__FILEDIR__}\..\dist\PeDitX-AI.exe"
    File "${__FILEDIR__}\..\src\peditx_ai.py"
    File /r "${__FILEDIR__}\..\web"
    File /r "${__FILEDIR__}\..\assets"

    ; Start Menu shortcuts: web UI (hidden console) and console CLI.
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\PeDitX-AI.exe"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME} CLI.lnk" "cmd.exe" '/k "$INSTDIR\PeDitX-AI.exe" --cli' "$INSTDIR\PeDitX-AI.exe" 0
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Add/remove entry in the user's Programs and Features.
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\PeDitX-AI.exe"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\PeDitX-AI.exe"
    Delete "$INSTDIR\peditx_ai.py"
    RMDir /r "$INSTDIR\web"
    RMDir /r "$INSTDIR\assets"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"

    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME} CLI.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
    RMDir "$SMPROGRAMS\${APPNAME}"

    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
