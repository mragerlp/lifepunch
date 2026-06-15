@echo off
setlocal
cd /d "%~dp0"
if not exist "dxrp-server.cs" (
  echo ERROR: dxrp-server.cs not found in %CD%
  echo Install Dxura host files in this folder first.
  pause
  exit /b 1
)
if exist "secure\official.local.env" call "secure\official.local.env"
if "%DXRP_TOKEN_OFFICIAL%"=="" (
  echo ERROR: Set DXRP_TOKEN_OFFICIAL in secure\official.local.env
  pause
  exit /b 1
)
if not exist "dxrp-server-config.json" if exist "dxrp-server-config.json.example" (
  copy /Y "dxrp-server-config.json.example" "dxrp-server-config.json" >nul
)
echo [%date% %time%] Starting Server 1 (Official) via dxrp-server.cs ...
dotnet run dxrp-server.cs --token %DXRP_TOKEN_OFFICIAL%
set EXIT=%ERRORLEVEL%
echo Server 1 exited with code %EXIT%
pause
exit /b %EXIT%
