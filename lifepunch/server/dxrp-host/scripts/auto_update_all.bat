@echo off
setlocal EnableExtensions
REM LIFEPUNCH lifepunchnet - s&box auto update + restart Development AND Official (70p).

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
echo   LIFEPUNCH AUTO UPDATE ALL - Dev + Official 70p (staging engine)
echo   Official: SteamCMD staging -^> C:\SBOX-DXRP-Server
echo ============================================================
echo.

cd /d "%SCRIPTS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" -IncludeOfficial -UpdateOfficialBinaries -UpdateDevelopmentBinaries -UseStagingBranch
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% neq 0 (
    echo AUTO UPDATE ALL failed with code %EXIT%
) else (
    echo AUTO UPDATE ALL finished. Check portal Version 26.06.10+ on both servers.
)
pause
exit /b %EXIT%
