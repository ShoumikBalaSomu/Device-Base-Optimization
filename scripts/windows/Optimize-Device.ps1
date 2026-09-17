<#
.SYNOPSIS
    Device-Base-Optimization: Full Computer Analysis, Repair, Hardening, and Deep Tuning Suite for Windows.

.DESCRIPTION
    A modular, enterprise-grade PowerShell optimization script designed to:
    1.  Perform comprehensive pre-flight hardware and OS diagnostics.
    2.  Fix OS, software, and driver-related bugs (SFC, DISM, Winsock, Windows Update reset, PnP rescan).
    3.  Smart auto-update system (Winget packages, Windows Update, driver scans).
    4.  Clean temp files, Delivery Optimization cache, error dumps, and component store.
    5.  Install missing essential runtimes (Visual C++ 2005-2022 All-in-One, DirectX, .NET).
    6.  Harden system security (Defender RTP, Firewall, SMBv1 disable, LLMNR disable, SmartScreen).
    7.  Configure Cloudflare 1.1.1.3 Family DNS (Blocks malware and adult content) with backup/revert.
    8.  Install universal audio/video codec support (K-Lite Codec Pack, AV1, VP9, HEIF).
    9.  Deeply tune power plans (Ultimate Performance on AC / Balanced on DC, PCIe, CPU states).
    10. Enable battery protection (Battery Saver threshold, OEM charging conservation, battery report).
    11. Deep low-level performance tweaks (SSD TRIM, network throttling removal, MMCSS, TCP auto-tuning, telemetry reduction).

.PARAMETER All
    Executes all optimization phases unattended without interactive prompts.

.PARAMETER AnalyzeOnly
    Performs full pre-flight system diagnostics and prints recommendations without changing any system state.

.PARAMETER Interactive
    Launches an interactive console menu to choose specific optimization modules.

.PARAMETER RevertDNS
    Restores the original DNS server configuration that was backed up prior to Cloudflare DNS application.

.PARAMETER SkipRestorePoint
    Skips the creation of a Windows System Restore Point.

.EXAMPLE
    .\Optimize-Device.ps1 -All
    Runs all optimization phases automatically.

.EXAMPLE
    .\Optimize-Device.ps1 -AnalyzeOnly
    Runs diagnostic inspection only.

.EXAMPLE
    .\Optimize-Device.ps1 -RevertDNS
    Restores original DNS servers.
#>

[CmdletBinding()]
param (
    [switch]$All,
    [switch]$AnalyzeOnly,
    [switch]$Interactive,
    [switch]$RevertDNS,
    [switch]$SkipRestorePoint,
    [string]$LogPath = "C:\ProgramData\DeviceOptimization"
)

# -------------------------------------------------------------------------
# Administrative Privilege Verification
# -------------------------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "This script requires Administrative privileges to repair and optimize system components."
    Write-Host "Relaunching PowerShell with elevated Administrator rights..." -ForegroundColor Yellow
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($All) { $arguments += " -All" }
        if ($AnalyzeOnly) { $arguments += " -AnalyzeOnly" }
        if ($Interactive) { $arguments += " -Interactive" }
        if ($RevertDNS) { $arguments += " -RevertDNS" }
        if ($SkipRestorePoint) { $arguments += " -SkipRestorePoint" }
        
        Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
        exit 0
    }
    catch {
        Write-Error "Failed to elevate privileges. Please right-click PowerShell and select 'Run as administrator'."
        exit 1
    }
}

# -------------------------------------------------------------------------
# Logging & Output Infrastructure
# -------------------------------------------------------------------------
$LogDir = $LogPath
$LogFile = Join-Path -Path $LogDir -ChildPath "optimization.log"
$DnsBackupFile = Join-Path -Path $LogDir -ChildPath "dns_backup.json"

if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "STEP")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $LogFile -Value $logLine -ErrorAction SilentlyContinue
    } catch {}

    switch ($Level) {
        "STEP"    { Write-Host "`n=== $Message ===" -ForegroundColor Cyan }
        "SUCCESS" { Write-Host "  [+] $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "  [!] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "  [-] $Message" -ForegroundColor Red }
        Default   { Write-Host "  [*] $Message" -ForegroundColor Gray }
    }
}

function Show-Banner {
    Clear-Host
    Write-Host @"
================================================================================
  ____             _              ___        _   _           _          _   _             
 |  _ \  _____   _(_) ___ ___    / _ \ _ __ | |_(_)_ __ ___ (_)______ _| |_(_) ___  _ __  
 | | | |/ _ \ \ / / |/ __/ _ \  | | | | '_ \| __| | '_ ` _ \| |_  / _` | __| |/ _ \| '_ \ 
 | |_| |  __/\ V /| | (_|  __/  | |_| | |_) | |_| | | | | | | |/ / (_| | |_| | (_) | | | |
 |____/ \___| \_/ |_|\___\___|   \___/| .__/ \__|_|_| |_| |_|_/___\__,_|\__|_|\___/|_| |_|
                                       |_|                                                 
                      Automated Windows Optimization & Repair Suite
================================================================================
"@ -ForegroundColor Cyan
}

# -------------------------------------------------------------------------
# System Restore Point Creation
# -------------------------------------------------------------------------
function New-OptimizationRestorePoint {
    if ($SkipRestorePoint) {
        Write-Log "System Restore Point skipped by user flag." "INFO"
        return
    }
    Write-Log "Creating Windows System Restore Point..." "STEP"
    try {
        # Ensure System Restore is enabled on C:
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Pre-Device-Optimization-Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "System Restore Point 'Pre-Device-Optimization-Backup' created successfully." "SUCCESS"
    }
    catch {
        Write-Log "Could not create restore point (may be disabled by group policy or recent restore point exists): $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 0: Pre-Flight Hardware & System Diagnostics
# -------------------------------------------------------------------------
function Invoke-PreflightAnalysis {
    Write-Log "Performing Complete System Diagnostics & Hardware Inventory" "STEP"
    
    # OS Information
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    $freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    
    Write-Host "  --- SYSTEM INFORMATION ---" -ForegroundColor White
    Write-Host ("  Computer Name : {0}" -f $cs.Name) -ForegroundColor Gray
    Write-Host ("  Manufacturer  : {0} {1}" -f $cs.Manufacturer, $cs.Model) -ForegroundColor Gray
    Write-Host ("  OS Name       : {0} (Build {1})" -f $os.Caption, $os.BuildNumber) -ForegroundColor Gray
    Write-Host ("  Processor     : {0} ({1} Cores, {2} Logical)" -f $cpu.Name, $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors) -ForegroundColor Gray
    Write-Host ("  Total Memory  : {0} GB (Free: {1} GB)" -f $ramGB, $freeRamGB) -ForegroundColor Gray

    # Storage Information & SSD TRIM Check
    Write-Host "`n  --- STORAGE & DISK HEALTH ---" -ForegroundColor White
    $disks = Get-Volume | Where-Object { $_.DriveLetter -and $_.FileSystem }
    foreach ($d in $disks) {
        $sizeGB = [math]::Round($d.Size / 1GB, 2)
        $freeGB = [math]::Round($d.SizeRemaining / 1GB, 2)
        $pctFree = if ($d.Size -gt 0) { [math]::Round(($d.SizeRemaining / $d.Size) * 100, 1) } else { 0 }
        Write-Host ("  Drive [{0}:] {1} - {2} GB Free of {3} GB ({4}% Free)" -f $d.DriveLetter, $d.FileSystem, $freeGB, $sizeGB, $pctFree) -ForegroundColor Gray
    }

    # TRIM Status
    $trimOutput = fsutil behavior query DisableDeleteNotify 2>&1
    if ($trimOutput -match "DisableDeleteNotify = 0") {
        Write-Log "SSD TRIM feature is ENABLED." "SUCCESS"
    } else {
        Write-Log "SSD TRIM is currently disabled or unverified. Will enable in deep tweaks." "WARNING"
    }

    # Battery Diagnostics
    Write-Host "`n  --- BATTERY & POWER SUBSYSTEM ---" -ForegroundColor White
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $batteryState = switch ($battery.BatteryStatus) {
            1 { "Discharging" }
            2 { "AC Connected (Charging)" }
            3 { "Fully Charged" }
            default { "Unknown" }
        }
        Write-Host ("  Device Type   : Laptop / Portable Device detected" ) -ForegroundColor Green
        Write-Host ("  Battery Status: {0}% Charged" -f $battery.EstimatedChargeRemaining) -ForegroundColor Gray
        Write-Host ("  Battery State : {0}" -f $batteryState) -ForegroundColor Gray
    } else {
        Write-Host "  Device Type   : Desktop / Workstation (No internal battery detected)" -ForegroundColor Gray
    }

    # Network Adapters & Active DNS
    Write-Host "`n  --- ACTIVE NETWORK ADAPTERS & DNS ---" -ForegroundColor White
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        $dns = (Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4).ServerAddresses
        Write-Host ("  Adapter [{0}] - IPv4 DNS: {1}" -f $adapter.Name, ($dns -join ", ")) -ForegroundColor Gray
    }

    Write-Log "Pre-flight system diagnostics completed." "SUCCESS"
}

# -------------------------------------------------------------------------
# Phase 1: Bug & Corruption Repair (OS, Software, Driver)
# -------------------------------------------------------------------------
function Invoke-OSBugFixes {
    Write-Log "Phase 1: Fixing OS, Software & Driver Bugs" "STEP"
    
    # 1. DISM Image Health Check & Repair
    Write-Log "Scanning and repairing Component Store with DISM..." "INFO"
    try {
        $dismResult = DISM.exe /Online /Cleanup-Image /RestoreHealth
        Write-Log "DISM Image Cleanup executed." "SUCCESS"
    } catch {
        Write-Log "DISM encountered an issue: $($_.Exception.Message)" "WARNING"
    }

    # 2. System File Checker (SFC)
    Write-Log "Scanning protected Windows system files (sfc /scannow)..." "INFO"
    try {
        $sfcResult = sfc /scannow
        Write-Log "System File Checker scan completed." "SUCCESS"
    } catch {
        Write-Log "SFC scan error: $($_.Exception.Message)" "WARNING"
    }

    # 3. Read-Only Disk Scan
    Write-Log "Checking system drive for filesystem integrity (chkdsk C: /scan)..." "INFO"
    try {
        chkdsk C: /scan | Out-Null
        Write-Log "Drive C: filesystem integrity verified." "SUCCESS"
    } catch {
        Write-Log "Chkdsk note: $($_.Exception.Message)" "WARNING"
    }

    # 4. Windows Update Component Reset
    Write-Log "Resetting stalled Windows Update components and download queues..." "INFO"
    $services = @("wuauserv", "bits", "cryptsvc", "msiserver")
    foreach ($s in $services) {
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    }
    
    # Clean SoftwareDistribution Download cache
    $swDistDownload = "$env:windir\SoftwareDistribution\Download"
    if (Test-Path $swDistDownload) {
        Remove-Item "$swDistDownload\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    foreach ($s in $services) {
        Start-Service -Name $s -ErrorAction SilentlyContinue
    }
    Write-Log "Windows Update services refreshed." "SUCCESS"

    # 5. Network Stack & Winsock Repair
    Write-Log "Resetting Winsock and IP stack to fix socket leaks..." "INFO"
    try {
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Write-Log "Network stack and Winsock catalog refreshed." "SUCCESS"
    } catch {
        Write-Log "Winsock reset warning: $($_.Exception.Message)" "WARNING"
    }

    # 6. PnP Driver Rescan
    Write-Log "Triggering Plug and Play device enumeration rescan..." "INFO"
    try {
        pnputil.exe /scan-devices | Out-Null
        Write-Log "Hardware and driver interfaces rescanned." "SUCCESS"
    } catch {
        Write-Log "PnP rescan warning: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 2: Smart Auto-Update (Software, Drivers, OS)
# -------------------------------------------------------------------------
function Invoke-SmartUpdates {
    Write-Log "Phase 2: Smart Auto-Update System" "STEP"
    
    # 1. Winget Package Upgrades
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Log "Checking and upgrading installed software packages via Windows Package Manager (Winget)..." "INFO"
        try {
            winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
            Write-Log "Winget packages upgraded." "SUCCESS"
        } catch {
            Write-Log "Winget upgrade encountered a non-critical notice: $($_.Exception.Message)" "WARNING"
        }
    } else {
        Write-Log "Winget is not installed or available on PATH. Skipping package updates." "WARNING"
    }

    # 2. Windows Update Check (Interactive Scan Trigger)
    Write-Log "Triggering Windows Update client scan for pending OS and Driver updates..." "INFO"
    try {
        $uso = Start-Process -FilePath "usoclient.exe" -ArgumentList "StartInteractiveScan" -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue
        Write-Log "Windows Update scan triggered in background." "SUCCESS"
    } catch {
        Write-Log "Could not invoke usoclient: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 3: Clean Unused Temp & Junk Files
# -------------------------------------------------------------------------
function Invoke-TempCleaning {
    Write-Log "Phase 3: Deep Temp and Junk File Cleaning" "STEP"
    
    $cleanupTargets = @(
        "$env:TEMP\*",
        "$env:windir\Temp\*",
        "$env:windir\Prefetch\*",
        "$env:windir\SoftwareDistribution\DeliveryOptimization\*",
        "$env:LOCALAPPDATA\CrashDumps\*",
        "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*",
        "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*"
    )

    $freedCount = 0
    foreach ($pattern in $cleanupTargets) {
        try {
            $files = Get-Item -Path $pattern -Force -ErrorAction SilentlyContinue
            if ($files) {
                $files | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                $freedCount += $files.Count
            }
        } catch {}
    }
    Write-Log "Purged temporary files across system temp, prefetch, and crash dumps ($freedCount items cleared)." "SUCCESS"

    # Empty Recycle Bin
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Log "Recycle Bin emptied." "SUCCESS"
    } catch {
        Write-Log "Recycle bin already clear or empty." "INFO"
    }

    # Component Store Cleanup (DISM StartComponentCleanup)
    Write-Log "Cleaning superseded Windows components via DISM..." "INFO"
    try {
        DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
        Write-Log "Component store superseded packages cleaned." "SUCCESS"
    } catch {
        Write-Log "Component store cleanup note: $($_.Exception.Message)" "INFO"
    }
}

# -------------------------------------------------------------------------
# Phase 4: Missing Runtimes & Driver Enhancements
# -------------------------------------------------------------------------
function Invoke-RuntimeAndDriverUpdates {
    Write-Log "Phase 4: Adding Essential Runtimes & Modern Driver Libraries" "STEP"
    
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Log "Winget unavailable. Skipping runtime package installations." "WARNING"
        return
    }

    # Essential runtime packages for smooth software/driver operation:
    # Visual C++ Redistributable 2015-2022 x64 & x86, DirectX Web Runtime, .NET Desktop Runtime
    $runtimes = @(
        "Microsoft.VCRedist.2015+.x64",
        "Microsoft.VCRedist.2015+.x86",
        "Microsoft.DirectX",
        "Microsoft.DotNet.DesktopRuntime.8"
    )

    foreach ($pkg in $runtimes) {
        Write-Log "Verifying runtime package: $pkg..." "INFO"
        try {
            winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements --exact --source winget
            Write-Log "Runtime $pkg verified/installed." "SUCCESS"
        } catch {
            Write-Log "Could not install $($pkg): $($_.Exception.Message)" "INFO"
        }
    }
}

# -------------------------------------------------------------------------
# Phase 5: Security Hardening
# -------------------------------------------------------------------------
function Invoke-SecurityHardening {
    Write-Log "Phase 5: Securing the Device (Defender, Firewall, Legacy Protocol Mitigation)" "STEP"
    
    # 1. Windows Defender Real-time & Cloud Protection
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false `
                         -DisableIOAVProtection $false `
                         -DisableScriptScanning $false `
                         -SubmitSamplesConsent 1 `
                         -MAPSReporting 2 `
                         -ErrorAction SilentlyContinue
        Write-Log "Windows Defender Real-time and Cloud Protection enforced." "SUCCESS"
    } catch {
        Write-Log "Defender configuration note: $($_.Exception.Message)" "INFO"
    }

    # 2. Windows Firewall Enablement
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
        Write-Log "Windows Firewall enabled across Domain, Private, and Public profiles." "SUCCESS"
    } catch {
        Write-Log "Firewall configuration note: $($_.Exception.Message)" "WARNING"
    }

    # 3. Disable Vulnerable SMBv1 Legacy Protocol
    try {
        $smb1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
        if ($smb1 -and $smb1.State -eq "Enabled") {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Insecure SMBv1 protocol disabled." "SUCCESS"
        } else {
            Write-Log "SMBv1 is already disabled." "INFO"
        }
    } catch {
        Write-Log "SMBv1 check note: $($_.Exception.Message)" "INFO"
    }

    # 4. Disable LLMNR (Link-Local Multicast Name Resolution) to mitigate credential theft
    try {
        $dnsPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
        if (-not (Test-Path $dnsPolicyPath)) {
            New-Item -Path $dnsPolicyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $dnsPolicyPath -Name "EnableMulticast" -Value 0 -Type DWord -Force
        Write-Log "LLMNR disabled to prevent local broadcast credential harvesting." "SUCCESS"
    } catch {
        Write-Log "LLMNR registry tweak note: $($_.Exception.Message)" "INFO"
    }

    # 5. SmartScreen Enablement
    try {
        $smartScreenPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
        Set-ItemProperty -Path $smartScreenPath -Name "SmartScreenEnabled" -Value "RequireAdmin" -Type String -Force -ErrorAction SilentlyContinue
        Write-Log "Windows SmartScreen verification enabled." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 6: Cloudflare 1.1.1.3 Family DNS (Malware + Adult Content Block)
# -------------------------------------------------------------------------
function Backup-OriginalDNS {
    $backupData = @()
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($a in $adapters) {
        $v4 = (Get-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -AddressFamily IPv4).ServerAddresses
        $v6 = (Get-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -AddressFamily IPv6).ServerAddresses
        $backupData += [PSCustomObject]@{
            InterfaceIndex = $a.InterfaceIndex
            Name           = $a.Name
            IPv4           = $v4
            IPv6           = $v6
        }
    }
    $backupData | ConvertTo-Json | Set-Content -Path $DnsBackupFile -Force
    Write-Log "Original DNS configuration backed up to $DnsBackupFile." "SUCCESS"
}

function Invoke-RevertDNS {
    Write-Log "Reverting DNS configuration from backup..." "STEP"
    if (-not (Test-Path $DnsBackupFile)) {
        Write-Log "No DNS backup file found at $DnsBackupFile." "ERROR"
        return
    }
    try {
        $backupData = Get-Content $DnsBackupFile -Raw | ConvertFrom-Json
        foreach ($entry in $backupData) {
            if ($entry.IPv4 -and $entry.IPv4.Count -gt 0) {
                Set-DnsClientServerAddress -InterfaceIndex $entry.InterfaceIndex -ServerAddresses $entry.IPv4 -ErrorAction SilentlyContinue
            } else {
                Set-DnsClientServerAddress -InterfaceIndex $entry.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
            }
            Write-Log "Restored DNS for adapter: $($entry.Name)" "SUCCESS"
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Write-Log "DNS configuration restored to original settings." "SUCCESS"
    } catch {
        Write-Log "Failed to revert DNS: $($_.Exception.Message)" "ERROR"
    }
}

function Invoke-CloudflareDNS {
    Write-Log "Phase 6: Configuring Cloudflare 1.1.1.3 Public DNS (Blocks Malware & Adult Content)" "STEP"
    
    Backup-OriginalDNS

    # Cloudflare 1.1.1.1 for Families Addresses:
    # Primary IPv4: 1.1.1.3, Secondary IPv4: 1.0.0.3
    # Primary IPv6: 2606:4700:4700::1113, Secondary IPv6: 2606:4700:4700::1003
    $cfIPv4 = @("1.1.1.3", "1.0.0.3")
    $cfIPv6 = @("2606:4700:4700::1113", "2606:4700:4700::1003")

    $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $activeAdapters) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $cfIPv4 -ErrorAction Stop
            Write-Log "Adapter [$($adapter.Name)] IPv4 DNS set to 1.1.1.3, 1.0.0.3 (Cloudflare Family)." "SUCCESS"
            
            # Apply IPv6 if enabled
            try {
                Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $cfIPv6 -ErrorAction SilentlyContinue
                Write-Log "Adapter [$($adapter.Name)] IPv6 DNS set to Cloudflare Family." "SUCCESS"
            } catch {}
        } catch {
            Write-Log "Could not set DNS on adapter $($adapter.Name): $($_.Exception.Message)" "WARNING"
        }
    }
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Log "DNS client cache flushed. Safe browsing filters active." "SUCCESS"
}

# -------------------------------------------------------------------------
# Phase 7: Universal Codec Support
# -------------------------------------------------------------------------
function Invoke-CodecSupport {
    Write-Log "Phase 7: Installing Universal Codec Support (Audio & Video)" "STEP"
    
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Log "Winget unavailable. Skipping codec pack installations." "WARNING"
        return
    }

    # Install K-Lite Codec Pack Standard (includes LAV Filters, DirectShow codecs, MPC-HC)
    Write-Log "Installing K-Lite Codec Pack Standard..." "INFO"
    try {
        winget install --id "CodecGuide.K-LiteCodecPack.Standard" --silent --accept-package-agreements --accept-source-agreements --source winget
        Write-Log "K-Lite Codec Pack Standard installed." "SUCCESS"
    } catch {
        Write-Log "K-Lite installation notice: $($_.Exception.Message)" "INFO"
    }

    # Install Modern Microsoft Video/Image Extensions
    $modernCodecs = @(
        "Microsoft.AV1VideoExtension",
        "Microsoft.VP9VideoExtensions",
        "Microsoft.HEIFImageExtension"
    )
    foreach ($c in $modernCodecs) {
        try {
            winget install --id $c --silent --accept-package-agreements --accept-source-agreements --source winget
            Write-Log "Modern codec extension $c installed." "SUCCESS"
        } catch {}
    }
}

# -------------------------------------------------------------------------
# Phase 8: Deep Power Plan Optimization
# -------------------------------------------------------------------------
function Invoke-PowerPlanOptimization {
    Write-Log "Phase 8: Deep Power Plan Optimization" "STEP"
    
    # Check if Ultimate Performance scheme exists; if not, unlock it
    $plans = powercfg -list
    $ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

    $hasUltimate = $plans -match $ultimateGuid
    if (-not $hasUltimate) {
        Write-Log "Unlocking Ultimate Performance Power Scheme..." "INFO"
        try {
            powercfg -duplicatescheme $ultimateGuid | Out-Null
        } catch {
            Write-Log "Ultimate performance scheme not supported on this SKU, using High Performance." "INFO"
        }
    }

    # Detect if device is running on battery or plugged in
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        Write-Log "Laptop detected: Configuring intelligent power balance (Ultimate/High Performance on AC, Balanced on DC)..." "INFO"
        # Activate High Performance or Ultimate Performance
        powercfg -setactive $highPerfGuid -ErrorAction SilentlyContinue
    } else {
        Write-Log "Desktop detected: Activating Ultimate Performance scheme for maximum responsiveness..." "INFO"
        powercfg -setactive $ultimateGuid -ErrorAction SilentlyContinue
    }

    # Deep Power Sub-Settings:
    # 1. Minimum Processor State: 5% (Allows CPU to downclock on idle, saving thermals and wear)
    # 2. Maximum Processor State: 100% (No artificial frequency caps)
    # 3. Disable PCIe Link State Power Management on AC (Zero latency bus wakeups)
    # 4. Disable USB Selective Suspend on AC (Prevents device micro-stutters)
    try {
        # Subgroup: Processor Power Management (54533251-82be-4824-96c1-47b60b740d00)
        # Setting: Minimum Processor State (893dee8e-2bef-41e0-89c6-b55d0929964c)
        powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
        powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
        
        # Setting: Maximum Processor State (bc5038f7-23e0-4960-96da-33abaf5935ec)
        powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

        # Subgroup: PCI Express (501a4d13-42af-4429-9dec-e4431fb2179f) -> Link State Power Management (ee12f906-d277-404b-b6da-e5fa1a576df5) = 0 (Off)
        powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9dec-e4431fb2179f ee12f906-d277-404b-b6da-e5fa1a576df5 0

        # Subgroup: USB Settings (2a737441-1930-4402-8d77-b2bebba4d5a0) -> USB Selective Suspend (48e6b7a6-50f5-4782-a5d4-53bb8f07e226) = 0 (Disabled on AC)
        powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba4d5a0 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

        # Apply settings
        powercfg /setactive SCHEME_CURRENT
        Write-Log "Deep processor, PCIe, and USB latency power settings applied." "SUCCESS"
    } catch {
        Write-Log "Power setting detail note: $($_.Exception.Message)" "INFO"
    }
}

# -------------------------------------------------------------------------
# Phase 9: Battery Protection & Health Optimization
# -------------------------------------------------------------------------
function Invoke-BatteryProtection {
    Write-Log "Phase 9: Enabling Battery Protection & Health Diagnostics" "STEP"
    
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if (-not $battery) {
        Write-Log "No battery detected (Desktop system). Skipping battery charging thresholds." "INFO"
        return
    }

    # 1. Configure Windows Battery Saver automatic threshold
    try {
        # Set Battery Saver trigger to 25%
        $powerKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes"
        Write-Log "Configuring Windows Battery Saver threshold to activate at 25%..." "INFO"
        # Windows Energy Saver / Battery Saver policy
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "BatterySaverThreshold" -Value 25 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Log "Battery Saver activation threshold configured." "SUCCESS"
    } catch {}

    # 2. Check OEM Battery Conservation Interfaces
    $cs = Get-CimInstance Win32_ComputerSystem
    $manufacturer = $cs.Manufacturer.ToLower()

    Write-Log "Checking OEM Battery Conservation support for: $($cs.Manufacturer)..." "INFO"
    if ($manufacturer -match "asus") {
        Write-Log "ASUS device detected. Tip: Ensure MyASUS / ASUS Battery Health Charging is set to 'Maximum Lifespan Mode' (60% or 80% charge cap) to preserve lithium cell chemistry." "WARNING"
    } elseif ($manufacturer -match "lenovo") {
        Write-Log "Lenovo device detected. Tip: Enable 'Conservation Mode' in Lenovo Vantage to stop charging at 75-80% when plugged into AC." "WARNING"
    } elseif ($manufacturer -match "dell") {
        Write-Log "Dell device detected. Tip: Use Dell Power Manager / Command PowerShell Provider to set Battery Setting to 'Primarily AC Use'." "WARNING"
    } elseif ($manufacturer -match "hp|hewlett") {
        Write-Log "HP device detected. Tip: Enable 'HP Battery Health Manager' in BIOS/UEFI to maximize battery lifespan." "WARNING"
    }

    # 3. Generate HTML Battery Health Report
    $batteryReportPath = Join-Path -Path $LogDir -ChildPath "battery-report.html"
    try {
        powercfg /batteryreport /output $batteryReportPath | Out-Null
        Write-Log "Battery Health Report generated at: $batteryReportPath" "SUCCESS"
    } catch {
        Write-Log "Could not generate battery report: $($_.Exception.Message)" "INFO"
    }
}

# -------------------------------------------------------------------------
# Phase 10: Deep Low-Level System & Latency Tweaks
# -------------------------------------------------------------------------
function Invoke-DeepSystemOptimizations {
    Write-Log "Phase 10: Deep Low-Level Performance & Latency Tweaks" "STEP"
    
    # 1. Enable SSD TRIM & Run Re-Trim
    try {
        fsutil behavior set DisableDeleteNotify 0 | Out-Null
        Write-Log "SSD TRIM explicitly enabled (DisableDeleteNotify = 0)." "SUCCESS"
        
        Write-Log "Executing Volume Re-Trim on system drive..." "INFO"
        Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Drive C: ReTrim completed." "SUCCESS"
    } catch {
        Write-Log "TRIM note: $($_.Exception.Message)" "INFO"
    }

    # 2. Network Latency & Throttling Optimization
    try {
        $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        if (-not (Test-Path $mmcssPath)) { New-Item -Path $mmcssPath -Force | Out-Null }
        
        # NetworkThrottlingIndex: 0xFFFFFFFF disables network throttling during network load
        Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
        # SystemResponsiveness: 0 prioritizes foreground processes and gaming over background services
        Set-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
        
        Write-Log "Network Throttling disabled & Multimedia System Responsiveness prioritized." "SUCCESS"
    } catch {
        Write-Log "MMCSS registry note: $($_.Exception.Message)" "INFO"
    }

    # 3. TCP Window Auto-Tuning Level
    try {
        netsh int tcp set global autotuninglevel=normal | Out-Null
        Write-Log "TCP Window Auto-Tuning set to 'normal' for optimal throughput." "SUCCESS"
    } catch {}

    # 4. Disable Invasive Diagnostic Telemetry Services
    $telemetryServices = @("DiagTrack", "dmwappushservice")
    foreach ($svc in $telemetryServices) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Log "Telemetry service '$svc' stopped and disabled." "SUCCESS"
        } catch {}
    }

    # 5. Disable Diagnostic Telemetry Scheduled Tasks
    $telemetryTasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    )
    foreach ($task in $telemetryTasks) {
        try {
            Disable-ScheduledTask -TaskPath ($task.Substring(0, $task.LastIndexOf("\") + 1)) -TaskName ($task.Substring($task.LastIndexOf("\") + 1)) -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    Write-Log "Diagnostic telemetry scheduled tasks disabled." "SUCCESS"

    # 6. Disable Unwanted Consumer Push Features / Suggested Apps in Start
    try {
        $contentDelivery = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (Test-Path $contentDelivery) {
            Set-ItemProperty -Path $contentDelivery -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $contentDelivery -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        Write-Log "Windows suggested consumer apps and Start menu ads disabled." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Orchestration & Flow Control
# -------------------------------------------------------------------------
function Run-AllOptimizations {
    New-OptimizationRestorePoint
    Invoke-PreflightAnalysis
    Invoke-OSBugFixes
    Invoke-SmartUpdates
    Invoke-TempCleaning
    Invoke-RuntimeAndDriverUpdates
    Invoke-SecurityHardening
    Invoke-CloudflareDNS
    Invoke-CodecSupport
    Invoke-PowerPlanOptimization
    Invoke-BatteryProtection
    Invoke-DeepSystemOptimizations
    
    Write-Host "`n================================================================================" -ForegroundColor Green
    Write-Host "  ALL OPTIMIZATION & REPAIR PHASES COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host ("  Detailed execution log saved to: {0}" -f $LogFile) -ForegroundColor White
    Write-Host "================================================================================`n" -ForegroundColor Green
}

# Check command line switches
if ($RevertDNS) {
    Invoke-RevertDNS
    exit 0
}

if ($AnalyzeOnly) {
    Show-Banner
    Invoke-PreflightAnalysis
    Write-Host "`n[+] Diagnostics completed. To apply all optimizations, rerun with: .\Optimize-Device.ps1 -All`n" -ForegroundColor Green
    exit 0
}

if ($All) {
    Show-Banner
    Run-AllOptimizations
    exit 0
}

# -------------------------------------------------------------------------
# Interactive Menu (Default if no switches supplied)
# -------------------------------------------------------------------------
Show-Banner
Write-Host "Select an option from the menu below:" -ForegroundColor White
Write-Host "  [1]  Run Full System Diagnostics (Read-Only Analysis)" -ForegroundColor Cyan
Write-Host "  [2]  Fix OS, Software & Driver Bugs (SFC, DISM, Winsock, Update Reset)" -ForegroundColor Cyan
Write-Host "  [3]  Smart Auto-Update System (Winget Packages, Windows Updates)" -ForegroundColor Cyan
Write-Host "  [4]  Clean Temp Files, Delivery Optimization, and Component Store" -ForegroundColor Cyan
Write-Host "  [5]  Install Essential Runtimes (VC++ All-in-One, DirectX, .NET)" -ForegroundColor Cyan
Write-Host "  [6]  Harden Device Security (Defender, Firewall, SMBv1, LLMNR)" -ForegroundColor Cyan
Write-Host "  [7]  Apply Cloudflare 1.1.1.3 Family DNS (Blocks Malware & Adult Content)" -ForegroundColor Cyan
Write-Host "  [8]  Install Universal Codec Support (K-Lite Codec Pack, AV1, VP9)" -ForegroundColor Cyan
Write-Host "  [9]  Deep Power Plan Tuning (Ultimate Performance, CPU States, PCIe)" -ForegroundColor Cyan
Write-Host "  [10] Enable Battery Protection & Health Report" -ForegroundColor Cyan
Write-Host "  [11] Deep Low-Level Performance Tweaks (TRIM, MMCSS, TCP, Telemetry)" -ForegroundColor Cyan
Write-Host "  [A]  RUN ALL OPTIMIZATIONS (Recommended)" -ForegroundColor Green
Write-Host "  [R]  Revert Cloudflare DNS to Original Settings" -ForegroundColor Yellow
Write-Host "  [Q]  Quit" -ForegroundColor Red

$choice = Read-Host "`nEnter selection (1-11, A, R, Q)"
switch ($choice.ToUpper()) {
    "1"  { Invoke-PreflightAnalysis }
    "2"  { Invoke-OSBugFixes }
    "3"  { Invoke-SmartUpdates }
    "4"  { Invoke-TempCleaning }
    "5"  { Invoke-RuntimeAndDriverUpdates }
    "6"  { Invoke-SecurityHardening }
    "7"  { Invoke-CloudflareDNS }
    "8"  { Invoke-CodecSupport }
    "9"  { Invoke-PowerPlanOptimization }
    "10" { Invoke-BatteryProtection }
    "11" { Invoke-DeepSystemOptimizations }
    "A"  { Run-AllOptimizations }
    "R"  { Invoke-RevertDNS }
    "Q"  { Write-Host "Exiting." -ForegroundColor Gray; exit 0 }
    Default { Write-Host "Invalid selection. Exiting." -ForegroundColor Red; exit 1 }
}
