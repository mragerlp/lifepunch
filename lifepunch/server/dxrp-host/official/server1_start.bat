@echo off
setlocal EnableExtensions
REM LIFEPUNCH Blue (lifepunchnet) — Official 70p server
REM dotnet run dxrp-server.cs --token <OFFICIAL>
REM Run as normal RDP user. NOT "Run as administrator".

cd /d "%~dp0"

if not exist "dxrp-server.cs" (
  echo ERROR: dxrp-server.cs missing in %CD%
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

if exist "secure\official.local.env" call "secure\official.local.env"
if "%DXRP_TOKEN_OFFICIAL%"=="" (
  echo ERROR: Create secure\official.local.env with:
  echo   DXRP_TOKEN_OFFICIAL=^<portal Official 70p token^>
  pause
  exit /b 1
)

if exist "Set-DxrpServerConfig.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command ". '%~dp0Set-DxrpServerConfig.ps1'; Set-DxrpServerConfigForProfile -Profile Official -InstallRoot '%CD%'" 2>nul
)

echo.
echo ============================================================
echo   LIFEPUNCH OFFICIAL 70p — dotnet run dxrp-server.cs
echo   Port 27015  ^|  User: %USERNAME%
echo ============================================================
echo.

dotnet run dxrp-server.cs --token %DXRP_TOKEN_OFFICIAL%
set EXIT=%ERRORLEVEL%
echo.
echo Official server exited with code %EXIT%
pause
exit /b %EXIT%
