@echo off
setlocal EnableExtensions
title LIFEPUNCH Official 70p - dxrp-server.cs
cd /d "%~dp0"

REM lifepunchnet Official 70p — C:\SBOX-DXRP-Server
REM Dxura launcher: dotnet run dxrp-server.cs (staging engine, portal staging gamemode + addons).

if not exist "dxrp-server.cs" (
  echo ERROR: dxrp-server.cs missing in %CD%
  echo Download from https://docs.dxrp.net/launching-server-with-addons
  pause
  exit /b 1
)
if not exist "sbox-server.dll" (
  echo ERROR: sbox-server.dll missing in %CD%
  pause
  exit /b 1
)
where dotnet >nul 2>&1
if errorlevel 1 (
  echo ERROR: .NET SDK not found. Install .NET 10 — https://dotnet.microsoft.com/download/dotnet/10.0
  pause
  exit /b 1
)

set "DXRP_TOKEN_OFFICIAL="
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("secure\official.local.env") do (
  if /i "%%A"=="DXRP_TOKEN_OFFICIAL" set "DXRP_TOKEN_OFFICIAL=%%B"
)
if "%DXRP_TOKEN_OFFICIAL%"=="" (
  echo ERROR: secure\official.local.env needs DXRP_TOKEN_OFFICIAL=
  pause
  exit /b 1
)

if exist "Ensure-DxrpRpCsproj.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\Ensure-DxrpRpCsproj.ps1" -InstallRoot "%CD%"
)
if exist "Set-DxrpServerConfig.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "& { . '%CD%\Set-DxrpServerConfig.ps1'; Set-DxrpServerConfigForProfile -Profile Official -InstallRoot '%CD%' -Token '%DXRP_TOKEN_OFFICIAL%'; Test-DxrpServerConfigForProfile -Profile Official -InstallRoot '%CD%' }"
)

echo.
echo ============================================================
echo   LIFEPUNCH OFFICIAL 70p
echo   dotnet run dxrp-server.cs  ^|  Port 27015 / Query 27018  ^|  s^&box STAGING
echo   Wait for [7/7] + Connected to Steam before players join.
echo   Portal: staging gamemode (Dev-proven pins).
echo ============================================================
echo.

:loop
dotnet run dxrp-server.cs --token %DXRP_TOKEN_OFFICIAL%
echo.
echo [%date% %time%] Launcher exited. Restarting in 10 seconds (Ctrl+C to quit)...
timeout /t 10 /nobreak
goto loop
