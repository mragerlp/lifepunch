@echo off
setlocal EnableExtensions
REM LIFEPUNCH lifepunchnet - s&box engine bump: BOTH servers, same public release version.
REM Run after Facepunch ships a new public s&box build (double-click, elevated).

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator for SteamCMD + both server restarts...
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
echo   LIFEPUNCH AUTO UPDATE - Official 70p + Development
echo   SteamCMD public release -^> both install roots (same version)
echo ============================================================
echo.

cd /d "%SCRIPTS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" -IncludeOfficial -UpdateOfficialBinaries -UpdateDevelopmentBinaries -OfficialRelease
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% neq 0 (
    echo AUTO UPDATE failed with code %EXIT%
) else (
    echo AUTO UPDATE finished. Portal Version must match on Official + Dev.
)
pause
exit /b %EXIT%
