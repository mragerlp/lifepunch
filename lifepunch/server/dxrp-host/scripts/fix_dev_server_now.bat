@echo off
setlocal EnableExtensions
REM LIFEPUNCH lifepunchnet — fix Dev server (Steam + restart). NORMAL user only — NOT Administrator.

cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo NOTE: Running as Administrator — server2_start must use THIS SAME user.
    echo.
)

set "SCRIPTS=%~dp0"
if not exist "%SCRIPTS%Fix-LifepunchnetDevServerNow.ps1" (
    set "SCRIPTS=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\"
)

echo.
echo ============================================================
echo   LIFEPUNCH FIX DEV SERVER NOW
echo   User: %USERNAME%
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%Fix-LifepunchnetDevServerNow.ps1"
set EXIT=%ERRORLEVEL%
pause
exit /b %EXIT%
