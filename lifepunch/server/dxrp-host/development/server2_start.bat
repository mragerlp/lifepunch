@echo off
setlocal EnableExtensions
REM Blue + VENGEANCE — same Dxura flow that works on VENGEANCE:
REM   dotnet run dxrp-server.cs --token <Development token>
REM Blue only: stamp port 27016 (Official 70p uses 27015 on same host).

cd /d "%~dp0"

if not exist "dxrp-server.cs" (
  echo ERROR: dxrp-server.cs missing in %CD%
  echo Download from https://docs.dxrp.net/launching-server-with-addons
  pause
  exit /b 1
)

if not exist "sbox-server.dll" (
  echo ERROR: sbox-server.dll missing. Run auto_update.bat ^(elevated^).
  pause
  exit /b 1
)

where dotnet >nul 2>&1
if errorlevel 1 (
  echo ERROR: .NET SDK missing. Install .NET 10: https://dotnet.microsoft.com/download/dotnet/10.0
  pause
  exit /b 1
)

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
