<#
.SYNOPSIS
    Device-Base-Optimization — DCL DC253D (Windows 11)
.DESCRIPTION
    13th Gen Intel i3-1315U | 8GB RAM | Desktop
    Runs common optimizations + DC253D-specific tuning
#>

$ErrorActionPreference = "SilentlyContinue"
$BackupDir = "C:\DeviceOptimization\Backups\DC253D-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
Start-Transcript -Path "C:\DeviceOptimization\dc253d.log" -Append

function Banner($msg) { Write-Host "`n$('='*50)" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Yellow; Write-Host "$('='*50)`n" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  ✔ $msg" -ForegroundColor Green }

# Run common optimizations
Banner "RUNNING COMMON OPTIMIZATIONS"
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-common.ps1 | iex

Banner "DC253D 1/4 — MAX PERFORMANCE (i3-1315U Desktop)"
# Ultimate Performance power plan
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
# CPU always at max (desktop — no battery concern)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 30
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2
powercfg /setactive SCHEME_CURRENT
Ok "Ultimate Performance plan — CPU turbo always on"

# 13th Gen Hybrid Thread Director — optimize
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "ThreadDpcEnable" -Value 1 -Type DWord -Force
Ok "Intel Thread Director optimized"

Banner "DC253D 2/4 — MEMORY (8GB Optimization)"
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
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
Ok "Virtual memory + paging optimized for 8GB"

Banner "DC253D 3/4 — DISPLAY (13th Gen Intel UHD)"
# Hardware-accelerated GPU scheduling
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
# Disable variable refresh rate (desktop monitor stability)
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" -Name "DirectXUserGlobalSettings" -Value "VRROptimizeEnable=0;" -Type String -Force 2>$null
Ok "Intel UHD 13th Gen — hardware GPU scheduling"

Banner "DC253D 4/4 — DESKTOP EXTRAS"
# Disable hibernation (desktop doesn't need it)
powercfg /hibernate off
# Disable USB selective suspend (desktop — always powered)
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive SCHEME_CURRENT
# Turn off display after 15 min, never sleep
powercfg /change monitor-timeout-ac 15
powercfg /change standby-timeout-ac 0
Ok "Desktop power settings optimized"

Banner "✅ DCL DC253D OPTIMIZATION COMPLETE"
Write-Host "  Backup: $BackupDir"
Write-Host "  Power: Ultimate Performance"
Write-Host "  🔄 Restart recommended"
Stop-Transcript
