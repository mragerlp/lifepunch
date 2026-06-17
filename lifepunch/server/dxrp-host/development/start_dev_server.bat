@echo off
setlocal EnableExtensions
REM LIFEPUNCH Development — dxrp-server.cs + dev token (same path that worked before 26.06.10 update)
REM Run as normal RDP user (NOT "Run as administrator").

cd /d "%~dp0"

set "RUNNER=%~dp0Run-DevServer.ps1"
if not exist "%RUNNER%" set "RUNNER=C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\Run-DevServer.ps1"

if not exist "%RUNNER%" (
    echo ERROR: Run-DevServer.ps1 not found. git pull lifepunch-rdp-server then Deploy-DxrpHostLaunchers.ps1
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%RUNNER%" -InstallRoot "%~dp0"
set EXIT=%ERRORLEVEL%
if %EXIT% neq 0 echo DEV SERVER FAILED exit=%EXIT%
pause
exit /b %EXIT%
