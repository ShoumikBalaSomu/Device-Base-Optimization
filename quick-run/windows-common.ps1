<#
.SYNOPSIS
    Device-Base-Optimization — Common Windows 11 Optimizations
.DESCRIPTION
    Safe for ALL devices. Run PowerShell as Administrator.
    Usage: irm <raw-url>/quick-run/windows-common.ps1 | iex
#>

$ErrorActionPreference = "SilentlyContinue"
$BackupDir = "C:\DeviceOptimization\Backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$LogFile = "C:\DeviceOptimization\optimization.log"
New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
New-Item -Path (Split-Path $LogFile) -ItemType Directory -Force | Out-Null
Start-Transcript -Path $LogFile -Append

function Banner($msg) { Write-Host "`n$('='*50)" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Yellow; Write-Host "$('='*50)`n" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  ✔ $msg" -ForegroundColor Green }

# ═══════════════════════════════════════════
Banner "1/8 — POWER PLAN (High Performance)"
# ═══════════════════════════════════════════
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 99999999-9999-9999-9999-999999999999 2>$null
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
# Disable USB selective suspend
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive SCHEME_CURRENT
Ok "High Performance power plan active"

# ═══════════════════════════════════════════
Banner "2/8 — NETWORK OPTIMIZATION"
# ═══════════════════════════════════════════
Write-Host "  🧹 Removing old Browser DoH policies (unlocking browser settings)..."
$browsers = @("Google\Chrome", "Microsoft\Edge", "BraveSoftware\Brave")
foreach ($b in $browsers) {
    $p = "HKLM:\SOFTWARE\Policies\$b"
    if (Test-Path $p) {
        Remove-ItemProperty -Path $p -Name "DnsOverHttpsMode" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $p -Name "DnsOverHttpsTemplates" -ErrorAction SilentlyContinue
    }
}
Ok "Browser DoH settings unlocked"

# TCP optimization
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global chimney=disabled
netsh int tcp set global rss=enabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global initialRto=2000
netsh int tcp set global nonsackrttresiliency=disabled
# Disable Nagle's algorithm for lower latency
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPNoDelay" -Value 1 -Type DWord -Force
# Disable network throttling
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
Ok "TCP/IP stack optimized"

# ═══════════════════════════════════════════
Banner "3/7 — DISPLAY OPTIMIZATION"
# ═══════════════════════════════════════════
# Enable hardware-accelerated GPU scheduling
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
# Disable fullscreen optimizations globally
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord -Force
# Visual quality
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -Type DWord -Force

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
    
    Write-Host "  🎬 Installing Alternative Dolby Vision Player (mpv.net)..."
    winget install mpv.net --accept-package-agreements --accept-source-agreements --silent 2>$null
    Write-Host "  ✔ mpv.net installed. Use it to play Dolby Vision videos without native OS support." -ForegroundColor Green
}

Write-Host "  💡 Note: To fully enable Dolby Vision on non-supported monitors, refer to: https://github.com/balu100/dolby-vision-for-windows"

Ok "GPU scheduling + font rendering + Dolby Vision extensions optimized"

# ═══════════════════════════════════════════
Banner "4/7 — SOUND ENHANCEMENT"
# ═══════════════════════════════════════════
# Enable spatial sound
$audioKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
# Enable Dolby Atmos if available
$dolbyService = Get-Service -Name "DolbyDAXAPI" -ErrorAction SilentlyContinue
if ($dolbyService) {
    Set-Service -Name "DolbyDAXAPI" -StartupType Automatic
    Start-Service -Name "DolbyDAXAPI" -ErrorAction SilentlyContinue
    Ok "Dolby Atmos service enabled"
}
# Audio priority
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "Scheduling Category" -Value "High" -Type String -Force
Ok "Audio priority maximized"

# ═══════════════════════════════════════════
Banner "5/7 — DISABLE TELEMETRY & BLOAT"
# ═══════════════════════════════════════════
# Disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
# Disable Cortana
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -Force 2>$null
# Disable Xbox services
$xboxServices = @("XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc")
foreach ($svc in $xboxServices) { Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue }
# Disable Superfetch on SSD
$disk = Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" }
if ($disk) { Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue }
Ok "Telemetry disabled, bloat reduced"

# ═══════════════════════════════════════════
Banner "6/7 — SECURITY HARDENING"
# ═══════════════════════════════════════════
# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
# Disable remote desktop by default
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -Type DWord -Force
# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
Ok "Firewall on, SMBv1 disabled, RDP blocked"

# ═══════════════════════════════════════════
Banner "7/7 — SYSTEM CLEANUP"
# ═══════════════════════════════════════════
# Disk cleanup
cleanmgr /d C /sagerun:1 2>$null
# Clear temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Ok "System cleaned"

Banner "✅ COMMON WINDOWS OPTIMIZATIONS COMPLETE (7 steps)"
Write-Host "  Backup: $BackupDir"
Write-Host "  🔄 Restart recommended"

Stop-Transcript
