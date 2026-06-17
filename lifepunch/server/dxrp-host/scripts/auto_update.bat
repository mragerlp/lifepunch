@echo off
setlocal EnableExtensions
REM LIFEPUNCH lifepunchnet - s&box dedicated server auto update (Development only).
REM Double-click after Steam/engine bumps. For 70p too, use auto_update_all.bat

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator for steamcmd + server restart...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

set "SCRIPTS=%~dp0"
if not exist "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" (
    set "SCRIPTS=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\"
)
if not exist "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" (
    echo ERROR: Update-LifepunchnetSboxServers.ps1 not found.
    echo Run: cd C:\lifepunch\lifepunch-rdp-server ^&^& git pull --rebase
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   LIFEPUNCH AUTO UPDATE - Development server (Server 2)
echo   Engine target: 26.06.10+
echo ============================================================
echo.

cd /d "%SCRIPTS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Update-LifepunchnetSboxServers.ps1"
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% neq 0 (
    echo AUTO UPDATE failed with code %EXIT%
) else (
    echo AUTO UPDATE finished. Check DXRP portal: Dev Last Pulsed + Version 26.06.10+
    echo For Official 70p after Dev OK, run auto_update_all.bat
)
pause
exit /b %EXIT%
