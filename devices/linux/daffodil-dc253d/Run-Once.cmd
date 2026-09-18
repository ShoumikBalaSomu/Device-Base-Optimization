@echo off
:: ============================================================================
::  Daffodil DC253D - Linux Optimization Launcher (WSL / Dual-Boot Helper)
:: ============================================================================
echo [!] Launching Linux Optimization suite...
wsl -d Fedora -u root /usr/local/bin/daffodil-watchdog.sh 2>nul || (
    echo Note: To run this under native Linux, run:
    echo   chmod +x run-once.sh ^&^& sudo ./run-once.sh
)
pause
