@echo off
setlocal
cd /d "%~dp0"
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
