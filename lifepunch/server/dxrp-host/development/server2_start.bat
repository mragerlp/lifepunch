@echo off
setlocal EnableExtensions
title LIFEPUNCH Development - dxrp-server.cs
cd /d "%~dp0"

REM lifepunchnet Development — Steam sbox folder.
REM Dxura launcher: dotnet run dxrp-server.cs (staging via Steam Betas).

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

set "SECRETS_ROOT=C:\SBOX-DXRP-Server\secure"
set "DXRP_TOKEN_DEVELOPMENT="
if exist "%SECRETS_ROOT%\development.local.env" (
  for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%SECRETS_ROOT%\development.local.env") do (
    if /i "%%A"=="DXRP_TOKEN_DEVELOPMENT" set "DXRP_TOKEN_DEVELOPMENT=%%B"
  )
)
if "%DXRP_TOKEN_DEVELOPMENT%"=="" if exist "secure\development.local.env" (
  for /f "usebackq eol=# tokens=1,* delims==" %%A in ("secure\development.local.env") do (
    if /i "%%A"=="DXRP_TOKEN_DEVELOPMENT" set "DXRP_TOKEN_DEVELOPMENT=%%B"
  )
)
if "%DXRP_TOKEN_DEVELOPMENT%"=="" (
  echo ERROR: Create %SECRETS_ROOT%\development.local.env with DXRP_TOKEN_DEVELOPMENT=
  pause
  exit /b 1
)

if exist "Ensure-DxrpRpCsproj.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\Ensure-DxrpRpCsproj.ps1" -InstallRoot "%CD%"
)
if exist "Set-DxrpServerConfig.ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "& { . '%CD%\Set-DxrpServerConfig.ps1'; Set-DxrpServerConfigForProfile -Profile Development -InstallRoot '%CD%' -Token '%DXRP_TOKEN_DEVELOPMENT%'; Test-DxrpServerConfigForProfile -Profile Development -InstallRoot '%CD%' }"
)

echo.
echo ============================================================
echo   LIFEPUNCH DEVELOPMENT
echo   dotnet run dxrp-server.cs  ^|  Port 27016 / Query 27017  ^|  s^&box STAGING
echo   Token: C:\SBOX-DXRP-Server\secure\development.local.env
echo   Install: %CD%
echo   Wait for [7/7] + Connected to Steam before players join.
echo ============================================================
echo.

:loop
dotnet run dxrp-server.cs --token %DXRP_TOKEN_DEVELOPMENT%
echo.
echo [%date% %time%] Launcher exited. Restarting in 10 seconds (Ctrl+C to quit)...
timeout /t 10 /nobreak
goto loop
