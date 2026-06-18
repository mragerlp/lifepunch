@echo off
setlocal EnableExtensions
REM Blue + VENGEANCE — same Dxura flow that works on VENGEANCE:
REM   dotnet run dxrp-server.cs --token <Development token>
REM Blue only: stamp port 27016 (Official 70p uses 27015 on same host).

cd /d "%~dp0"

if exist "secure\development.local.env" call "secure\development.local.env"

if "%DXRP_TOKEN_DEVELOPMENT%"=="" (
  echo Paste token on command line instead:
  echo   dotnet run dxrp-server.cs --token YOUR_DEV_TOKEN
  echo Or create secure\development.local.env with DXRP_TOKEN_DEVELOPMENT=
  pause
  exit /b 1
)

if exist "Set-DxrpServerConfig.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0Set-DxrpServerConfig.ps1'; Set-DxrpServerConfigForProfile -Profile Development -InstallRoot '%CD%'" 2>nul
)

dotnet run dxrp-server.cs --token %DXRP_TOKEN_DEVELOPMENT%
pause
exit /b %ERRORLEVEL%
