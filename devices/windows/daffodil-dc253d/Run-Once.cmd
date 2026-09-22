@echo off
:: ============================================================================
::  Daffodil Computers Ltd. DC253D - Autonomous 18-Sector Optimization Suite
::  Self-Elevating 1-Click Launcher (Windows 11 / 10)
:: ============================================================================
title Daffodil DC253D Autonomous Optimization Suite

:: Check for Administrator elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Requesting administrative privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo ==============================================================================
echo    DAFFODIL DC253D - AUTONOMOUS HARDWARE OPTIMIZATION & REPAIR
echo ==============================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Optimize-Daffodil-DC253D.ps1" -All

echo.
echo ==============================================================================
echo   Execution complete. Press any key to exit.
echo ==============================================================================
pause >nul
