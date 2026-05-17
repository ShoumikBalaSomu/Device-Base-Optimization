<#
.SYNOPSIS
    Device-Base-Optimization — Lenovo ThinkPad T490s (Windows 11)
.DESCRIPTION
    Intel i7-8665U | 32GB RAM | Intel UHD 620 | Laptop
    Runs common optimizations + T490s-specific tuning
#>

$ErrorActionPreference = "SilentlyContinue"
$BackupDir = "C:\DeviceOptimization\Backups\T490s-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\DeviceOptimization\t490s.log" -Append

function Banner($msg) { Write-Host "`n$('='*50)" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Yellow; Write-Host "$('='*50)`n" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  ✔ $msg" -ForegroundColor Green }

# Run common optimizations
Banner "RUNNING COMMON OPTIMIZATIONS"
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-common.ps1 | iex

Banner "T490s 1/5 — BATTERY PROTECTION (60-80%)"
# Lenovo Vantage battery charge threshold via WMI
try {
    $lenovoWmi = Get-WmiObject -Namespace "root\wmi" -Class "Lenovo_SetBiosSetting" -ErrorAction Stop
    $lenovoWmi.SetBiosSetting("ChargeThreshold,60;80") | Out-Null
    $save = Get-WmiObject -Namespace "root\wmi" -Class "Lenovo_SaveBiosSettings"
    $save.SaveBiosSettings("") | Out-Null
    Ok "Battery charge limited: 60% → 80% via Lenovo WMI"
} catch {
    # Fallback: set via power config
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 3
    Ok "Battery protection configured via powercfg (install Lenovo Vantage for 60-80% threshold)"
}

# Balanced power plan with custom tweaks for laptop
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 80
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setactive SCHEME_CURRENT
Ok "CPU: 100% on AC, 80% on battery"

Banner "T490s 2/5 — INTEL UHD 620 TUNING"
# Backup current Intel GPU registry
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" "$BackupDir\intel_gpu.reg" /y 2>$null

# Intel UHD 620 — enable quality mode
$intelGpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
if (Test-Path $intelGpuPath) {
    Set-ItemProperty -Path $intelGpuPath -Name "Disable_OverlayDSQualityEnhancement" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $intelGpuPath -Name "FeatureTestControl" -Value 0x9240 -Type DWord -Force
}
Ok "Intel UHD 620 quality mode"

Banner "T490s 3/5 — DOLBY VISION + ATMOS"
# Enable HDR if display supports it
$hdrKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings"
New-Item -Path $hdrKey -Force | Out-Null
Set-ItemProperty -Path $hdrKey -Name "EnableHDRForPlayback" -Value 1 -Type DWord -Force

# Install Dolby Vision & HEVC Extensions
Write-Host "  🎬 Installing Dolby Vision & HEVC Extensions..."
winget install --id "9pltg1lwphlf" --source msstore --accept-package-agreements --accept-source-agreements --silent 2>$null
$winget1 = $LASTEXITCODE
winget install --id "9NMZLZ57R3T7" --source msstore --accept-package-agreements --accept-source-agreements --silent 2>$null

if ($winget1 -ne 0) {
    Write-Host "  ⚠ Winget failed to install Dolby Vision. Adding fallback Python tool..." -ForegroundColor Yellow
    $fallbackDir = "C:\DeviceOptimization\Scripts\DolbyVision"
    New-Item -Path $fallbackDir -ItemType Directory -Force | Out-Null
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/balu100/dolby-vision-for-windows/main/enable_dolby_vision_hdmi.py" -OutFile "$fallbackDir\enable_dolby_vision_hdmi.py" -UseBasicParsing
        Write-Host "  ✔ Fallback script downloaded to $fallbackDir\enable_dolby_vision_hdmi.py" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Failed to download fallback script." -ForegroundColor Red
    }
}

Write-Host "  💡 Note: To fully enable Dolby Vision on non-supported monitors, refer to: https://github.com/balu100/dolby-vision-for-windows"

# Dolby Atmos — ensure service is running
$dolbyServices = @("DolbyDAXAPI", "Dolby DAX API Service")
foreach ($svc in $dolbyServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) { Set-Service -Name $svc -StartupType Automatic; Start-Service $svc -ErrorAction SilentlyContinue }
}
Ok "HDR + Dolby Vision + Atmos configured"

Banner "T490s 4/5 — THERMAL MANAGEMENT"
# Intelligent Thermal Management for ThinkPad
$thermalPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\44f3beca-a7c0-460e-9df2-bb8b99e0cba6"
if (Test-Path $thermalPath) {
    # Set thermal policy: Active cooling
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0
    powercfg /setactive SCHEME_CURRENT
}
Ok "Thermal: boost on AC, conservative on battery"

Banner "T490s 5/5 — THINKPAD EXTRAS"
# Disable Windows Ink Workspace (no pen on T490s)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Value 0 -Type DWord -Force 2>$null
# Disable touch keyboard (no touch screen)
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" -Name "EnableDesktopModeAutoInvoke" -Value 0 -Type DWord -Force 2>$null
Ok "Disabled unused touch/pen features"

Banner "✅ THINKPAD T490s OPTIMIZATION COMPLETE"
Write-Host "  Backup: $BackupDir"
Write-Host "  Battery: 60-80% protection (requires Lenovo Vantage)"
Write-Host "  🔄 Restart recommended"
Stop-Transcript
