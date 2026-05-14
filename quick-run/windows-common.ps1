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
Banner "3/8 — DNS SECURITY (System + Browser DoH)"
# ═══════════════════════════════════════════

## Layer 1: System DNS ##
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @("185.228.168.168","185.228.169.168","1.1.1.3","1.0.0.3") -ErrorAction SilentlyContinue
}
# Enable Windows DoH
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDoh" -Value 2 -Type DWord -Force 2>$null
# Register CleanBrowsing + Cloudflare Family as DoH providers
netsh dns add encryption server=185.228.168.168 dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=185.228.169.168 dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=1.1.1.3 dohtemplate=https://family.cloudflare-dns.com/dns-query 2>$null
ipconfig /flushdns | Out-Null
Ok "System DNS → CleanBrowsing Family Filter (DoH encrypted)"

## Layer 2: Browser DoH → CleanBrowsing ##
$dohUrl = "https://doh.cleanbrowsing.org/doh/family-filter/"

# Google Chrome
$chromeKey = "HKLM:\SOFTWARE\Policies\Google\Chrome"
New-Item -Path $chromeKey -Force | Out-Null
Set-ItemProperty -Path $chromeKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $chromeKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force

# Microsoft Edge
$edgeKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
New-Item -Path $edgeKey -Force | Out-Null
Set-ItemProperty -Path $edgeKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $edgeKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force

# Mozilla Firefox
$firefoxKey = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS"
New-Item -Path $firefoxKey -Force | Out-Null
Set-ItemProperty -Path $firefoxKey -Name "Enabled" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $firefoxKey -Name "ProviderURL" -Value $dohUrl -Type String -Force
Set-ItemProperty -Path $firefoxKey -Name "Locked" -Value 1 -Type DWord -Force

# Brave
$braveKey = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
New-Item -Path $braveKey -Force | Out-Null
Set-ItemProperty -Path $braveKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $braveKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force

Ok "Browser DoH → CleanBrowsing Family Filter (Chrome/Edge/Firefox/Brave)"

# ═══════════════════════════════════════════
Banner "4/8 — DISPLAY OPTIMIZATION"
# ═══════════════════════════════════════════
# Enable hardware-accelerated GPU scheduling
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
# Disable fullscreen optimizations globally
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord -Force
# Visual quality
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -Type DWord -Force
Ok "GPU scheduling + font rendering optimized"

# ═══════════════════════════════════════════
Banner "5/8 — SOUND ENHANCEMENT"
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
Banner "6/8 — DISABLE TELEMETRY & BLOAT"
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
Banner "7/8 — SECURITY HARDENING"
# ═══════════════════════════════════════════
# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
# Disable remote desktop by default
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -Type DWord -Force
# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
Ok "Firewall on, SMBv1 disabled, RDP blocked"

# ═══════════════════════════════════════════
Banner "8/8 — SYSTEM CLEANUP"
# ═══════════════════════════════════════════
# Disk cleanup
cleanmgr /d C /sagerun:1 2>$null
# Clear temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Ok "System cleaned"

Banner "✅ COMMON WINDOWS OPTIMIZATIONS COMPLETE"
Write-Host "  Backup: $BackupDir"
Write-Host "  🔄 Restart recommended"

Stop-Transcript
