@echo off
setlocal EnableExtensions
REM LIFEPUNCH lifepunchnet - Official 70p only: SteamCMD staging engine + restart (no Dev).

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator for SteamCMD staging + Official restart...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

set "SCRIPTS=%~dp0"
if not exist "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" (
    set "SCRIPTS=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\"
)

echo.
echo ============================================================
echo   LIFEPUNCH OFFICIAL STAGING UPDATE (70p only)
echo   SteamCMD -beta staging -^> C:\SBOX-DXRP-Server
echo ============================================================
echo.

cd /d "%SCRIPTS%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Update-LifepunchnetSboxServers.ps1" -UpdateOfficialBinaries -OfficialOnly
set EXIT=%ERRORLEVEL%

echo.
if %EXIT% neq 0 (
    echo OFFICIAL STAGING UPDATE failed with code %EXIT%
) else (
    echo Done. Players need Steam Betas -^> staging to join Official 70p.
)
pause
exit /b %EXIT%
