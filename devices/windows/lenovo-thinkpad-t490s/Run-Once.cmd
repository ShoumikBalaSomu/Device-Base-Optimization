@echo off
setlocal EnableDelayedExpansion

:: -------------------------------------------------------------------------
:: ThinkPad T490s 1-Click Autonomous Setup Launcher
:: Automatically requests Administrator elevation and runs full optimization.
:: -------------------------------------------------------------------------

title ThinkPad T490s 1-Click Autonomous Optimizer

:: Check for Administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ======================================================================
    echo   Requesting Administrator Privileges...
    echo ======================================================================
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~dpnx0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo ======================================================================
echo   Launching Autonomous ThinkPad T490s Optimization Suite...
echo   100%% Automated - Running all 10 sectors and installing watchdog.
echo ======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Optimize-ThinkPad-T490s.ps1" -AutoInstall

echo.
echo ======================================================================
echo   Optimization Complete! You can now close this window.
echo ======================================================================
echo.
pause
