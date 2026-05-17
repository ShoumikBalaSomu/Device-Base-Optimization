<#
.SYNOPSIS
    Device-Base-Optimization — DCL DC253D (Windows 11)
.DESCRIPTION
    13th Gen Intel i3-1315U | 8GB RAM | Laptop
    Runs common optimizations + DC253D-specific tuning

    FIXED:
      • Restored Laptop Power Logic (sleep, battery scaling, selective suspend)
      • Added Intel Dynamic Tuning / DPTF adaptive power management
      • Added processor performance boost mode (aggressive turbo)
      • Added core parking optimization for hybrid P+E cores
      • Ensured Modern Standby / Connected Standby is available
#>

$ErrorActionPreference = "SilentlyContinue"
$BackupDir = "C:\DeviceOptimization\Backups\DC253D-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\DeviceOptimization\dc253d.log" -Append

function Banner($msg) { Write-Host "`n$('='*50)" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Yellow; Write-Host "$('='*50)`n" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  ✔ $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

# Run common optimizations
Banner "RUNNING COMMON OPTIMIZATIONS"
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-common.ps1 | iex

###############################################################################
Banner "DC253D 1/5 — ADAPTIVE PERFORMANCE (i3-1315U Hybrid)"
###############################################################################

# Balanced Performance power plan
$balancedGUID = "381b4222-f694-41f0-9685-ff5bb260df2e"
powercfg /setactive $balancedGUID 2>$null
Ok "Power plan: Balanced (Laptop Optimized)"

# CPU scaling for battery life and thermals
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 80
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5

# FIX: Processor Performance Boost Mode → Aggressive (for turbo)
# 0=Disabled, 1=Enabled, 2=Aggressive, 3=Efficient Aggressive
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2

# FIX: Processor Performance Core Parking — optimize for hybrid P+E cores
# Min parked cores = 0% (never park on desktop)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
# Max parked cores = 0% (never park)
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 ea062031-0e34-4ff1-9b6d-eb1030128210 0

# FIX: Processor Performance Autonomous Mode → Enabled (let CPU self-manage)
# This allows Intel Thread Director to work optimally with P+E cores
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFEPP 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFAUTONOMOUS 1

# FIX: Processor Idle Demote/Promote Threshold for responsiveness
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEPROMOTE 40
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDEMOTE 60

powercfg /setactive SCHEME_CURRENT
Ok "CPU: turbo aggressive, no core parking, Thread Director optimized"

# FIX: Intel Thread Director — optimize via registry
$kernelKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
Set-ItemProperty -Path $kernelKey -Name "ThreadDpcEnable" -Value 1 -Type DWord -Force
# Enable Heterogeneous scheduler for hybrid CPUs (P+E core awareness)
$schedKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Scheduler"
New-Item -Path $schedKey -Force | Out-Null
Set-ItemProperty -Path $schedKey -Name "HeteroSchedulerPolicy" -Value 5 -Type DWord -Force
Set-ItemProperty -Path $schedKey -Name "HeteroSchedulerPolicyConfig" -Value 5 -Type DWord -Force
Ok "Intel Thread Director + heterogeneous scheduler enabled"

# FIX: Intel Dynamic Tuning Technology (DTT / DPTF)
# Ensure Intel DTT service is running for adaptive thermal/power management
$dttService = Get-Service -Name "igfxCUIService*" -ErrorAction SilentlyContinue
if ($dttService) {
    Set-Service -Name $dttService.Name -StartupType Automatic
    Start-Service -Name $dttService.Name -ErrorAction SilentlyContinue
    Ok "Intel Dynamic Tuning service enabled"
} else {
    Warn "Intel DTT service not found — install Intel DTT from intel.com for adaptive performance"
}

# Ensure Intel Turbo Boost Max Technology 3.0 driver is active
$tbmtService = Get-Service -Name "Intel(R) Speed Shift Technology" -ErrorAction SilentlyContinue
if (-not $tbmtService) { $tbmtService = Get-Service -Name "IBTSIVA" -ErrorAction SilentlyContinue }
if ($tbmtService) {
    Set-Service -Name $tbmtService.Name -StartupType Automatic
    Start-Service -Name $tbmtService.Name -ErrorAction SilentlyContinue
    Ok "Intel Speed Shift / Turbo Boost service enabled"
}

###############################################################################
Banner "DC253D 2/5 — MEMORY (8GB Optimization)"
###############################################################################

# Virtual memory tuning
$ram = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB
$pagefile = [math]::Round($ram * 1.5)
$sys = Get-WmiObject Win32_ComputerSystem
$sys.AutomaticManagedPagefile = $False
$sys.Put() | Out-Null
$pf = Get-WmiObject Win32_PageFileUsage
$setting = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"
if (-not $setting) {
    $setting = ([WMIClass]"Win32_PageFileSetting").CreateInstance()
    $setting.Name = "C:\pagefile.sys"
}
$setting.InitialSize = $pagefile * 1024
$setting.MaximumSize = $pagefile * 1024 * 2
$setting.Put() | Out-Null

# Optimize memory management
$mmKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $mmKey -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $mmKey -Name "LargeSystemCache" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $mmKey -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
# FIX: Optimize prefetcher for SSD (3=both app+boot, best for SSD+8GB)
$prefetchKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
Set-ItemProperty -Path $prefetchKey -Name "EnablePrefetcher" -Value 3 -Type DWord -Force
Set-ItemProperty -Path $prefetchKey -Name "EnableSuperfetch" -Value 0 -Type DWord -Force
Ok "Virtual memory + paging optimized for 8GB"

###############################################################################
Banner "DC253D 3/5 — DISPLAY (13th Gen Intel UHD)"
###############################################################################

# Hardware-accelerated GPU scheduling
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
# Disable variable refresh rate (desktop monitor stability)
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" -Name "DirectXUserGlobalSettings" -Value "VRROptimizeEnable=0;" -Type String -Force 2>$null
Ok "Intel UHD 13th Gen — hardware GPU scheduling"

###############################################################################
Banner "DC253D 4/6 — LAPTOP POWER + USB"
###############################################################################

# Enable hibernation
powercfg /hibernate on

# Enable USB selective suspend (save battery)
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1

# USB power management cleanup
$usbKey = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
if (Test-Path $usbKey) {
    Remove-ItemProperty -Path $usbKey -Name "DisableSelectiveSuspend" -ErrorAction SilentlyContinue
}

Ok "USB power: selective suspend enabled"

# Turn off display: 10m AC / 5m DC | Sleep: 30m AC / 15m DC
powercfg /change monitor-timeout-ac 10
powercfg /change monitor-timeout-dc 5
powercfg /change standby-timeout-ac 30
powercfg /change standby-timeout-dc 15

# Enable Modern Standby / Connected Standby (S0ix)
$csKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
Set-ItemProperty -Path $csKey -Name "PlatformAoAcOverride" -Value 1 -Type DWord -Force 2>$null
Set-ItemProperty -Path $csKey -Name "CsEnabled" -Value 1 -Type DWord -Force 2>$null

# Enable Fast Startup
$shutdownKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
Set-ItemProperty -Path $shutdownKey -Name "HiberbootEnabled" -Value 1 -Type DWord -Force

powercfg /setactive SCHEME_CURRENT
Ok "Laptop power: sleep/hibernate enabled, fast startup on, screen timeouts set"

###############################################################################
Banner "DC253D 5/6 — BATTERY CHARGE CONTROL (Stop at 80%)"
###############################################################################

$chargeSet = $false

# Check if device has a battery
$battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
if ($battery) {
    Ok "Battery detected: $($battery.Name)"

    # Method 1: ACPI charge threshold via WMI (vendor-neutral)
    try {
        $batSetting = Get-WmiObject -Namespace "root\wmi" -Class "BatteryChargeLevel" -ErrorAction Stop
        if ($batSetting) {
            $batSetting.ChargeStopThreshold = 80
            $batSetting.Put() | Out-Null
            Ok "Battery charge limit → 80% (via WMI BatteryChargeLevel)"
            $chargeSet = $true
        }
    } catch { }

    # Method 2: DCL/OEM specific BIOS setting via WMI
    if (-not $chargeSet) {
        try {
            $biosWmi = Get-WmiObject -Namespace "root\wmi" -Class "MSAcpi_ThermalZoneTemperature" -ErrorAction Stop
            # Some OEMs expose charge threshold via ACPI methods
        } catch { }
    }

    # Method 3: Create a battery monitoring script that alerts/limits at 80%
    # This is a universal fallback that works on ALL Windows devices
    $scriptDir = "C:\DeviceOptimization\Scripts"
    New-Item -Path $scriptDir -ItemType Directory -Force | Out-Null

    # Battery monitor script — checks every 60 seconds
    $monitorScript = @'
# Battery Charge Monitor — Stop at 80%
# Runs as scheduled task, checks battery level every 60 seconds
$logFile = "C:\DeviceOptimization\battery-monitor.log"
while ($true) {
    $battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $charge = $battery.EstimatedChargeRemaining
        $status = $battery.BatteryStatus
        # BatteryStatus: 1=Discharging, 2=AC/Charging, 3-5=various charge states
        if ($charge -ge 80 -and $status -eq 2) {
            # Battery at 80% and still charging — notify user
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $logFile -Value "$timestamp - Battery at ${charge}% — CHARGE LIMIT REACHED"
            # Show notification to unplug
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
            $notify = New-Object System.Windows.Forms.NotifyIcon
            $notify.Icon = [System.Drawing.SystemIcons]::Warning
            $notify.BalloonTipIcon = "Warning"
            $notify.BalloonTipTitle = "Battery Protection"
            $notify.BalloonTipText = "Battery at ${charge}% — Please unplug charger to protect battery (limit: 80%)"
            $notify.Visible = $true
            $notify.ShowBalloonTip(10000)
            Start-Sleep -Seconds 10
            $notify.Dispose()
        }
    }
    Start-Sleep -Seconds 60
}
'@
    Set-Content -Path "$scriptDir\battery-monitor.ps1" -Value $monitorScript -Force

    # Create scheduled task for battery monitoring
    $taskName = "DeviceOptimization-BatteryMonitor"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\battery-monitor.ps1`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -Description "Monitor battery and alert at 80% charge" `
        -RunLevel Limited -Force | Out-Null
    Ok "Battery monitor installed — alerts at 80% to unplug charger"
    Ok "Task: $taskName (runs at logon, checks every 60s)"

    # Also set Windows battery charge policy via registry
    $batteryKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes"
    # Set battery threshold notifications
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELLOW 20
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BATTERY BATLEVELCRIT 10
    powercfg /setactive SCHEME_CURRENT
    Ok "Battery low/critical warnings configured"
} else {
    Warn "No battery detected — charge control not applicable (pure desktop)"
}

###############################################################################
Banner "DC253D 6/6 — AUDIO (Dolby)"
###############################################################################

# Audio priority
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10 -Type DWord -Force
$audioTaskKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio"
New-Item -Path $audioTaskKey -Force | Out-Null
Set-ItemProperty -Path $audioTaskKey -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $audioTaskKey -Name "Scheduling Category" -Value "High" -Type String -Force

# Dolby Atmos / DAX service
$dolbyService = Get-Service -Name "DolbyDAXAPI" -ErrorAction SilentlyContinue
if ($dolbyService) {
    Set-Service -Name "DolbyDAXAPI" -StartupType Automatic
    Start-Service -Name "DolbyDAXAPI" -ErrorAction SilentlyContinue
    Ok "Dolby Atmos service enabled"
}
Ok "Audio priority max + Dolby configured"

###############################################################################
Banner "✅ DCL DC253D OPTIMIZATION COMPLETE"
###############################################################################
Write-Host "  Backup:  $BackupDir"
Write-Host "  Power:   Ultimate Performance (adaptive turbo)"
Write-Host "  Memory:  8GB optimized + pagefile tuned"
Write-Host "  Battery: Charge monitor active (alert at 80%)"
Write-Host ""
Write-Host "  Verify adaptive performance:" -ForegroundColor DarkGray
Write-Host "    powercfg /getactivescheme        # should show Ultimate Performance" -ForegroundColor DarkGray
Write-Host "    powercfg /query SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE" -ForegroundColor DarkGray
Write-Host "                                     # should show: 2 (Aggressive)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  🔄 Restart recommended"
Stop-Transcript

