@echo off
setlocal EnableExtensions
REM LIFEPUNCH - fix "not connected to Steam" on dedicated server (26.06.10+)

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

set "SCRIPTS=%~dp0"
if not exist "%SCRIPTS%Fix-LifepunchnetSteamClient.ps1" (
    set "SCRIPTS=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\"
)

echo.
echo ============================================================
echo   LIFEPUNCH FIX STEAM - wire SteamCMD client DLLs
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Fix-LifepunchnetSteamClient.ps1"
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% equ 0 (
    echo OK. Now restart server2_start.bat ^(Dev^) or server1_start.bat ^(Official^).
) else (
    echo FIX STEAM failed with code %EXIT%
)
pause
exit /b %EXIT%
