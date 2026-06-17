@echo off
REM Open the last dev server log (even if the console window was lost).
set "LOG=C:\S&BOX DXRP Server\logs\dev-server-last.log"
if not exist "%LOG%" (
    echo No log yet. Run start_dev_server.bat first.
    pause
    exit /b 1
)
notepad "%LOG%"
exit /b 0
