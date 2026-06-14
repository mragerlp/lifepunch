@echo off
title VENGEANCE Voice PTT
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-VengeancePtt.ps1"
pause
