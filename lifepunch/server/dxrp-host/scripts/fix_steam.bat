@echo off
setlocal EnableExtensions
REM LIFEPUNCH - fix "not connected to Steam" (26.06.10+)
REM IMPORTANT: Run as the SAME user who starts server2_start.bat - DO NOT "Run as administrator"

cd /d "%~dp0"

set "SCRIPTS=%~dp0"
if not exist "%SCRIPTS%Fix-LifepunchnetSteamClient.ps1" (
    set "SCRIPTS=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\"
)

echo.
echo ============================================================
echo   LIFEPUNCH FIX STEAM
echo   User: %USERNAME%
echo   DO NOT run as Administrator - use your normal RDP login
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Fix-LifepunchnetSteamClient.ps1"
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% equ 0 (
    echo OK. Restart server2_start.bat in THIS SAME session/user.
) else (
    echo FIX STEAM failed with code %EXIT%
)
pause
exit /b %EXIT%
