@echo off
:: ==============================================================================
:: ThinkPad T490s Autonomous Optimization Launcher (Cross-Platform)
:: Repository: ShoumikBalaSomu/Device-Base-Optimization
:: ==============================================================================
echo [ThinkPad T490s Optimization Suite - Linux & Windows]
echo.
if exist "%SystemRoot%\System32\wsl.exe" (
    echo Launching Linux optimization engine...
    bash run-once.sh
) else (
    echo Please run run-once.sh in a Linux bash terminal with sudo.
)
pause
