@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows\start.ps1" %*
set "lab_exit=%errorlevel%"
echo.
pause
exit /b %lab_exit%
