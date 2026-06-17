@echo off
setlocal
cd /d "%~dp0"
REM 26.06.10+: dedicated server needs SteamCMD client DLL registry (same user as this console)
for %%S in ("%~dp0Fix-LifepunchnetSteamClient.ps1" "C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\Fix-LifepunchnetSteamClient.ps1") do (
  if exist %%~S powershell -NoProfile -ExecutionPolicy Bypass -File "%%~S" 2>nul
)
if not exist "dxrp-server.cs" (
  echo ERROR: dxrp-server.cs not found in %CD%
  pause
  exit /b 1
)
if exist "secure\development.local.env" call "secure\development.local.env"
if "%DXRP_TOKEN_DEVELOPMENT%"=="" (
  echo ERROR: Set DXRP_TOKEN_DEVELOPMENT in secure\development.local.env
  pause
  exit /b 1
)
if not exist "dxrp-server-config.json" if exist "dxrp-server-config.json.example" (
  copy /Y "dxrp-server-config.json.example" "dxrp-server-config.json" >nul
)
echo [%date% %time%] Starting Server 2 (Development) via dxrp-server.cs ...
dotnet run dxrp-server.cs --token %DXRP_TOKEN_DEVELOPMENT%
set EXIT=%ERRORLEVEL%
echo Server 2 exited with code %EXIT%
pause
exit /b %EXIT%
