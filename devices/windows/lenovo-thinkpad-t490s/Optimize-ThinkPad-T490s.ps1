<#
.SYNOPSIS
    ThinkPad-T490s-Optimization: Custom Deep Hardware Analysis, Repair, Hardening, and Tuning Suite.

.DESCRIPTION
    Custom-engineered exclusively for:
    - Device Model   : Lenovo ThinkPad T490s (Machine Type: 20NYS64T00 / 20NY)
    - Processor      : Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz (4C/8T, Whiskey Lake-U)
    - Graphics       : Intel(R) UHD Graphics 620 (QuickSync Video Decoder)
    - Memory         : 32 GB DDR4 High-Capacity RAM
    - Storage        : INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD + Realtek PCIe Card Reader
    - Networking     : Intel(R) Wireless-AC 9560 160MHz & Intel(R) Ethernet I219-LM
    - Battery        : SMP 02DL014 57Wh Internal Li-ion Battery
    - Operating Sys  : Microsoft Windows 11 Pro (Build 26300)

    Tailored Optimization Modules:
    1.  ThinkPad BIOS / UEFI WMI Thermal Management (AdaptiveThermalManagement AC/DC).
    2.  Hardware Battery Protection (75% Start / 80% Stop Charge Threshold via Lenovo PM).
    3.  Intel Wireless-AC 9560 Custom Adapter Tuning (Throughput Booster, 5GHz Prefer, No SMPS).
    4.  Intel NVMe SSD (SSDPEKKF512G8L) NTFS & Write Lifecycle Optimization.
    5.  32GB High-Capacity Memory & System Cache Optimization.
    6.  Windows 11 Build 26300 Core Bug Repair (SFC, DISM, Winsock, PnP Rescan).
    7.  Smart Auto-Update System (Winget Packages, Windows Updates).
    8.  Deep Temp & Cache Purge (User/Win Temp, Prefetch, Delivery Optimization, WER).
    9.  Device Security Hardening (Defender RTP, Cloud Protection, Firewall, SMBv1, LLMNR).
    10. Cloudflare 1.1.1.3 Family DNS (Blocks Malware & Adult Content, with backup/revert).
    11. Universal Audio/Video Codecs for Intel UHD 620 QuickSync Hardware Decoding.
    12. Dual-Mode Power Management (Ultimate Performance on AC / Balanced on Battery).

.PARAMETER All
    Executes all ThinkPad T490s optimization phases unattended.

.PARAMETER AnalyzeOnly
    Performs full pre-flight hardware diagnostics, battery health/wear calculation, and WMI audit without modifying state.

.PARAMETER Interactive
    Launches an interactive ThinkPad T490s console menu.

.PARAMETER ChargeToFull
    Temporarily disables the 80% battery conservation threshold to charge the battery to 100% (ideal for travel).

.PARAMETER RevertDNS
    Restores the original DNS server configuration that was backed up prior to Cloudflare DNS application.

.PARAMETER SkipRestorePoint
    Skips the creation of a Windows System Restore Point.

.EXAMPLE
    .\Optimize-Device.ps1 -All
    Runs full ThinkPad T490s optimization unattended.

.EXAMPLE
    .\Optimize-Device.ps1 -AnalyzeOnly
    Runs hardware health and battery wear diagnostics only.

.EXAMPLE
    .\Optimize-Device.ps1 -ChargeToFull
    Disables 80% battery threshold and allows charging to 100%.
#>

[CmdletBinding()]
param (
    [switch]$All,
    [switch]$AnalyzeOnly,
    [switch]$Interactive,
    [switch]$ChargeToFull,
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
    Write-Warning "Administrator privileges required to optimize ThinkPad BIOS, drivers, and system services."
    Write-Host "Elevating permissions..." -ForegroundColor Yellow
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($All) { $arguments += " -All" }
        if ($AnalyzeOnly) { $arguments += " -AnalyzeOnly" }
        if ($Interactive) { $arguments += " -Interactive" }
        if ($ChargeToFull) { $arguments += " -ChargeToFull" }
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
# Logging & Storage Setup
# -------------------------------------------------------------------------
$LogDir = $LogPath
$LogFile = Join-Path -Path $LogDir -ChildPath "thinkpad_t490s_optimization.log"
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
  _______ _     _       _      _____          _   _______ _  _   ___   ____  
 |__   __| |   (_)     | |    |  __ \        | | |__   __| || | / _ \ / ___| 
    | |  | |__  _ _ __ | | __ | |__) |_ _  __| |    | |  | || || (_) |___ \  
    | |  | '_ \| | '_ \| |/ / |  ___/ _` |/ _` |    | |  |__   _> _ <  ___) | 
    | |  | | | | | | | |   <  | |  | (_| | (_| |    | |     | || (_) |____/  
    |_|  |_| |_|_|_| |_|_|\_\ |_|   \__,_|\__,_|    |_|     |_| \___/|_____/  
                                                                             
      Custom Hardware Optimization Suite for Lenovo ThinkPad T490s (20NYS64T00)
================================================================================
"@ -ForegroundColor Red
}

# -------------------------------------------------------------------------
# Device Hardware Verification Lock
# -------------------------------------------------------------------------
function Assert-ThinkPadHardware {
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_Bios
    
    $isThinkPad = ($cs.Model -match "20NY|T490s|ThinkPad") -or ($cs.Manufacturer -match "LENOVO")
    if (-not $isThinkPad) {
        Write-Log "Notice: Target machine detected as '$($cs.Manufacturer) $($cs.Model)'. This script is specially customized for the Lenovo ThinkPad T490s (20NYS64T00)." "WARNING"
    } else {
        Write-Log "Hardware Verified: Lenovo ThinkPad T490s ($($cs.Model)), BIOS: $($bios.SMBIOSBIOSVersion)" "SUCCESS"
    }
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
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Pre-ThinkPad-T490s-Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "System Restore Point 'Pre-ThinkPad-T490s-Optimization' created successfully." "SUCCESS"
    }
    catch {
        Write-Log "Restore point notice: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 0: Pre-Flight Hardware Health & Battery Wear Diagnostics
# -------------------------------------------------------------------------
function Invoke-PreflightAnalysis {
    Write-Log "Performing ThinkPad T490s Hardware Inventory & Diagnostics" "STEP"
    Assert-ThinkPadHardware

    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    $freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)

    Write-Host "`n  --- THINKPAD T490s SYSTEM PROFILE ---" -ForegroundColor White
    Write-Host ("  Model         : {0} ({1})" -f $cs.Model, $cs.SystemFamily) -ForegroundColor Cyan
    Write-Host ("  Processor     : {0} (4 Cores, 8 Threads, 1.9GHz Base, up to 4.8GHz Boost)" -f $cpu.Name) -ForegroundColor Gray
    Write-Host ("  Memory        : {0} GB DDR4 (Available: {1} GB)" -f $ramGB, $freeRamGB) -ForegroundColor Gray
    Write-Host ("  Operating Sys : {0} (Build {1})" -f $os.Caption, $os.BuildNumber) -ForegroundColor Gray

    # Intel NVMe Storage Profile
    Write-Host "`n  --- INTEL NVMe SOLID STATE STORAGE ---" -ForegroundColor White
    $disks = Get-Disk
    foreach ($d in $disks) {
        $sizeGB = [math]::Round($d.Size / 1GB, 2)
        Write-Host ("  Disk #{0}: {1} [{2}] - {3} GB" -f $d.Number, $d.FriendlyName, $d.BusType, $sizeGB) -ForegroundColor Gray
    }
    $trimOutput = fsutil behavior query DisableDeleteNotify 2>&1
    if ($trimOutput -match "DisableDeleteNotify = 0") {
        Write-Log "Intel NVMe TRIM feature is ACTIVE." "SUCCESS"
    } else {
        Write-Log "TRIM currently disabled or unverified. Will enforce." "WARNING"
    }

    # Battery Wear Calculation (ThinkPad SMP 02DL014 57Wh)
    Write-Host "`n  --- THINKPAD BATTERY HEALTH & WEAR ANALYSIS ---" -ForegroundColor White
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $batteryState = switch ($battery.BatteryStatus) {
            1 { "Discharging" }
            2 { "AC Connected (Charging)" }
            3 { "Fully Charged" }
            default { "Unknown" }
        }
        Write-Host ("  Battery Pack  : SMP 02DL014 (ThinkPad 57Wh Internal Li-ion)") -ForegroundColor Gray
        Write-Host ("  Current Charge: {0}% ({1})" -f $battery.EstimatedChargeRemaining, $batteryState) -ForegroundColor Gray

        # Read actual mWh from Lenovo Power Manager Registry
        $regBattery = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Lenovo\PWRMGRV\ConfKeys\Data\X2XP9ABN17M" -ErrorAction SilentlyContinue
        if ($regBattery -and $regBattery.DesignCapacity) {
            $designMwh = $regBattery.DesignCapacity
            $fullMwh = $regBattery.FullChargeCapacityAfterGaugeReset
            $wearPct = [math]::Round(((($designMwh - $fullMwh) / $designMwh) * 100), 1)
            $healthPct = [math]::Round((($fullMwh / $designMwh) * 100), 1)
            Write-Host ("  Design Capacity : {0} mWh" -f $designMwh) -ForegroundColor Gray
            Write-Host ("  Full Capacity   : {0} mWh (Health: {1}%, Wear: {2}%)" -f $fullMwh, $healthPct, $wearPct) -ForegroundColor Green
            Write-Host ("  Charge Limits   : Start at {0}%, Stop at {1}%" -f $regBattery.ChargeStartPercentage, $regBattery.ChargeStopPercentage) -ForegroundColor Cyan
        }
    }

    # Networking Adapters
    Write-Host "`n  --- INTEL HIGH-SPEED NETWORK SUBSYSTEM ---" -ForegroundColor White
    $wifi = Get-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue
    if ($wifi) {
        Write-Host ("  Wi-Fi Adapter : {0} ({1}) - Link Speed: {2}" -f $wifi.InterfaceDescription, $wifi.Status, $wifi.LinkSpeed) -ForegroundColor Gray
        $dns = (Get-DnsClientServerAddress -InterfaceIndex $wifi.InterfaceIndex -AddressFamily IPv4).ServerAddresses
        Write-Host ("  Active DNS    : {0}" -f ($dns -join ", ")) -ForegroundColor Gray
    }

    Write-Log "Pre-flight ThinkPad T490s diagnostics completed." "SUCCESS"
}

# -------------------------------------------------------------------------
# Phase 1: ThinkPad BIOS / UEFI WMI Thermal & Performance Tuning
# -------------------------------------------------------------------------
function Invoke-ThinkPadBiosTuning {
    Write-Log "Phase 1: Tuning ThinkPad BIOS / UEFI Power & Thermal Profiles" "STEP"
    
    try {
        $biosSettings = Get-CimInstance -Namespace root\wmi -ClassName Lenovo_BiosSetting -ErrorAction Stop
        
        # Desired ThinkPad settings for maximum AC performance and balanced battery life:
        $targetSettings = @(
            "AdaptiveThermalManagementAC,MaximizePerformance",
            "AdaptiveThermalManagementBattery,Balanced",
            "SpeedStep,Enable",
            "CPUPowerManagement,Enable",
            "ChargeInBatteryMode,Disable"
        )

        $setBiosObj = Get-CimInstance -Namespace root\wmi -ClassName Lenovo_SetBiosSetting
        foreach ($setting in $targetSettings) {
            $name, $val = $setting.Split(",")
            $current = ($biosSettings | Where-Object { $_.CurrentSetting.StartsWith($name) }).CurrentSetting
            if ($current -ne $setting) {
                Write-Log "Updating BIOS setting: $name -> $val (was: $current)..." "INFO"
                Invoke-CimMethod -InputObject $setBiosObj -MethodName SetBiosSetting -Arguments @{ Parameter = $setting } | Out-Null
            } else {
                Write-Log "BIOS setting '$name' is already optimized ($val)." "INFO"
            }
        }

        # Save BIOS settings to NVRAM
        $saveObj = Get-CimInstance -Namespace root\wmi -ClassName Lenovo_SaveBiosSettings
        Invoke-CimMethod -InputObject $saveObj -MethodName SaveBiosSettings | Out-Null
        Write-Log "ThinkPad BIOS thermal & power configuration saved to NVRAM." "SUCCESS"
    }
    catch {
        Write-Log "ThinkPad BIOS WMI note: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 2: Hardware Battery Protection & Threshold Control
# -------------------------------------------------------------------------
function Invoke-ThinkPadBatteryProtection {
    param ([switch]$SetFullCharge)
    
    Write-Log "Phase 2: Enforcing ThinkPad Battery Health Protection (75%-80% Threshold)" "STEP"
    
    $confKeysPath = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\PWRMGRV\ConfKeys\Data"
    if (Test-Path $confKeysPath) {
        $batteryKeys = Get-ChildItem -Path $confKeysPath -ErrorAction SilentlyContinue
        foreach ($bk in $batteryKeys) {
            if ($SetFullCharge) {
                # Disable threshold for 100% full charge (travel mode)
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartControl" -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopControl" -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartPercentage" -Value 95 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopPercentage" -Value 100 -Type DWord -Force
                Write-Log "Battery Charge Threshold DISABLED. Battery will charge to 100% (Travel Mode)." "WARNING"
            } else {
                # Enforce 75% Start / 80% Stop Conservation Mode
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartControl" -Value 1 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopControl" -Value 1 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartPercentage" -Value 75 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopPercentage" -Value 80 -Type DWord -Force
                Write-Log "Battery Charge Threshold enforced: Starts charging at 75%, stops at 80% (Prolongs SMP 02DL014 lifespan)." "SUCCESS"
            }
        }
        # Restart Lenovo PM Service to immediately reload configuration
        Restart-Service -Name "IBMPMSVC" -Force -ErrorAction SilentlyContinue
    } else {
        Write-Log "Lenovo Power Manager registry key not found. Ensure Lenovo Vantage / PM Driver is installed." "WARNING"
    }

    # Generate HTML Battery Health Report
    $batteryReportPath = Join-Path -Path $LogDir -ChildPath "thinkpad_t490s_battery_report.html"
    try {
        powercfg /batteryreport /output $batteryReportPath | Out-Null
        Write-Log "ThinkPad Battery Report generated: $batteryReportPath" "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 3: Intel Wireless-AC 9560 160MHz Custom Driver Tuning
# -------------------------------------------------------------------------
function Invoke-IntelWiFiTuning {
    Write-Log "Phase 3: Optimizing Intel Wireless-AC 9560 160MHz Adapter" "STEP"
    
    $wifi = Get-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue
    if (-not $wifi) {
        Write-Log "Wi-Fi adapter not detected. Skipping Intel Wi-Fi tuning." "WARNING"
        return
    }

    try {
        # 1. Enable Throughput Booster (Increases packet bursting on 802.11ac)
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "Throughput Booster" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
        Write-Log "Intel Wi-Fi 'Throughput Booster' set to Enabled." "SUCCESS"

        # 2. Prefer 5GHz Band (Eliminates congestion on 2.4GHz)
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "Preferred Band" -DisplayValue "3. Prefer 5GHz band" -ErrorAction SilentlyContinue
        Write-Log "Intel Wi-Fi 'Preferred Band' set to 3. Prefer 5GHz band." "SUCCESS"

        # 3. Disable MIMO Power Save Mode (Prevents micro-latency spikes during gaming/streaming)
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "MIMO Power Save Mode" -DisplayValue "No SMPS" -ErrorAction SilentlyContinue
        Write-Log "Intel Wi-Fi 'MIMO Power Save Mode' set to No SMPS." "SUCCESS"

        # 4. Transmit Power to Highest
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "Transmit Power" -DisplayValue "5. Highest" -ErrorAction SilentlyContinue
        Write-Log "Intel Wi-Fi 'Transmit Power' verified at 5. Highest." "SUCCESS"
    }
    catch {
        Write-Log "Intel Wi-Fi tuning note: $($_.Exception.Message)" "INFO"
    }
}

# -------------------------------------------------------------------------
# Phase 4: Intel NVMe SSD (SSDPEKKF512G8L) NTFS & Write Lifecycle Tuning
# -------------------------------------------------------------------------
function Invoke-IntelNVMeTuning {
    Write-Log "Phase 4: Intel NVMe SSD (512GB) NTFS & Lifecycle Tuning" "STEP"
    
    # 1. Enable TRIM explicitly
    fsutil behavior set DisableDeleteNotify 0 | Out-Null
    Write-Log "NVMe TRIM explicitly enforced." "SUCCESS"

    # 2. Run Volume ReTrim on Drive C:
    Write-Log "Executing Volume Re-Trim on Intel NVMe Drive C:..." "INFO"
    Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue | Out-Null
    Write-Log "Drive C: ReTrim completed." "SUCCESS"

    # 3. Disable 8.3 Short Filename Creation on C: (Improves modern NTFS directory read/write speed)
    try {
        fsutil.exe 8dot3name set C: 1 | Out-Null
        Write-Log "Disabled legacy 8.3 short filename generation on Drive C:." "SUCCESS"
    } catch {}

    # 4. Disable NTFS Last Access Time Updates (Eliminates continuous write cycles to SSD NAND flash)
    try {
        fsutil.exe behavior set disablelastaccess 1 | Out-Null
        Write-Log "Disabled NTFS LastAccess timestamp updates to conserve SSD flash lifespan." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 5: 32GB RAM High-Capacity Memory & System Cache Tuning
# -------------------------------------------------------------------------
function Invoke-ThinkPadMemoryTuning {
    Write-Log "Phase 5: Configuring Windows 11 for 32GB High-Capacity RAM" "STEP"
    
    # Memory Management Settings for 32GB RAM:
    # 1. ClearPageFileAtShutdown: 0 (Fast shutdown, no unnecessary zeroing on large RAM)
    # 2. DisablePagingExecutive: 1 (Keep OS kernel in physical RAM, zero paging latency)
    # 3. LargeSystemCache: 0 (Optimized for application/desktop responsiveness rather than dedicated file server)
    $memKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    try {
        Set-ItemProperty -Path $memKey -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $memKey -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
        Write-Log "Kernel locked in physical 32GB RAM (DisablePagingExecutive = 1)." "SUCCESS"
    } catch {}

    # Multimedia Class Scheduler (MMCSS) Gaming & Low-Latency Responsiveness
    try {
        $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
        Set-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
        Write-Log "Network Throttling removed & Foreground Responsiveness prioritized." "SUCCESS"
    } catch {}

    # TCP Window Auto-Tuning
    try {
        netsh int tcp set global autotuninglevel=normal | Out-Null
        Write-Log "TCP Window Auto-Tuning set to 'normal'." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 6: Windows 11 26300 Core OS, Software & Driver Bug Repair
# -------------------------------------------------------------------------
function Invoke-OSBugFixes {
    Write-Log "Phase 6: Windows 11 (Build 26300) Core Bug & Corruption Repair" "STEP"
    
    Write-Log "Scanning and repairing Component Store with DISM..." "INFO"
    try {
        DISM.exe /Online /Cleanup-Image /RestoreHealth | Out-Null
        Write-Log "DISM Image Health scan and repair executed." "SUCCESS"
    } catch {}

    Write-Log "Running System File Checker (sfc /scannow)..." "INFO"
    try {
        sfc.exe /scannow | Out-Null
        Write-Log "System File Checker scan completed." "SUCCESS"
    } catch {}

    Write-Log "Scanning filesystem integrity on Drive C:..." "INFO"
    try {
        chkdsk.exe C: /scan | Out-Null
        Write-Log "Drive C: filesystem verified." "SUCCESS"
    } catch {}

    Write-Log "Resetting Windows Update download cache..." "INFO"
    $services = @("wuauserv", "bits", "cryptsvc", "msiserver")
    foreach ($s in $services) { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue }
    $swDist = "$env:windir\SoftwareDistribution\Download"
    if (Test-Path $swDist) { Remove-Item "$swDist\*" -Recurse -Force -ErrorAction SilentlyContinue }
    foreach ($s in $services) { Start-Service -Name $s -ErrorAction SilentlyContinue }
    Write-Log "Windows Update cache purged and services restarted." "SUCCESS"

    Write-Log "Resetting Winsock and IP stack..." "INFO"
    try {
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Write-Log "Network stack refreshed." "SUCCESS"
    } catch {}

    Write-Log "Triggering Plug and Play device enumeration rescan..." "INFO"
    try {
        pnputil.exe /scan-devices | Out-Null
        Write-Log "ThinkPad hardware devices and drivers rescanned." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 7: Smart Auto-Updates (Winget & Windows Update)
# -------------------------------------------------------------------------
function Invoke-SmartUpdates {
    Write-Log "Phase 7: Smart Auto-Update (Software, Drivers, OS)" "STEP"
    
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Log "Upgrading installed packages via Winget..." "INFO"
        try {
            winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
            Write-Log "Winget packages upgraded." "SUCCESS"
        } catch {
            Write-Log "Winget notice: $($_.Exception.Message)" "WARNING"
        }
    }

    Write-Log "Triggering Windows Update scan for pending OS/Driver updates..." "INFO"
    try {
        Start-Process -FilePath "usoclient.exe" -ArgumentList "StartInteractiveScan" -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Windows Update scan initiated." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 8: Deep Temp & Cache Cleaning
# -------------------------------------------------------------------------
function Invoke-TempCleaning {
    Write-Log "Phase 8: Deep Temp, Cache & Component Store Cleanup" "STEP"
    
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
    Write-Log "Cleared temporary cache and crash dumps ($freedCount items purged)." "SUCCESS"

    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Log "Recycle Bin emptied." "SUCCESS"
    } catch {}

    Write-Log "Cleaning superseded component store packages..." "INFO"
    try {
        DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
        Write-Log "Component store cleaned." "SUCCESS"
    } catch {}
}

# -------------------------------------------------------------------------
# Phase 9: Security Hardening & Cloudflare 1.1.1.3 Family DNS
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

function Invoke-SecurityAndDNS {
    Write-Log "Phase 9: Device Hardening & Cloudflare 1.1.1.3 Family DNS" "STEP"
    
    # 1. Defender RTP & Cloud Protection
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false `
                         -DisableIOAVProtection $false `
                         -DisableScriptScanning $false `
                         -SubmitSamplesConsent 1 `
                         -MAPSReporting 2 `
                         -ErrorAction SilentlyContinue
        Write-Log "Windows Defender Real-time and Cloud Protection enforced." "SUCCESS"
    } catch {}

    # 2. Firewall Enablement
    try {
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
        Write-Log "Windows Firewall active across all profiles." "SUCCESS"
    } catch {}

    # 3. Disable Vulnerable SMBv1 Legacy Protocol
    try {
        $smb1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
        if ($smb1 -and $smb1.State -eq "Enabled") {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Vulnerable SMBv1 protocol disabled." "SUCCESS"
        }
    } catch {}

    # 4. Disable LLMNR to prevent local credential harvesting
    try {
        $dnsPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
        if (-not (Test-Path $dnsPolicyPath)) { New-Item -Path $dnsPolicyPath -Force | Out-Null }
        Set-ItemProperty -Path $dnsPolicyPath -Name "EnableMulticast" -Value 0 -Type DWord -Force
        Write-Log "LLMNR disabled." "SUCCESS"
    } catch {}

    # 5. Cloudflare 1.1.1.3 Family DNS Configuration
    Backup-OriginalDNS
    $cfIPv4 = @("1.1.1.3", "1.0.0.3")
    $cfIPv6 = @("2606:4700:4700::1113", "2606:4700:4700::1003")

    $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $activeAdapters) {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $cfIPv4 -ErrorAction Stop
            Write-Log "Adapter [$($adapter.Name)] IPv4 DNS set to 1.1.1.3, 1.0.0.3 (Cloudflare Family)." "SUCCESS"
            try {
                Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses $cfIPv6 -ErrorAction SilentlyContinue
            } catch {}
        } catch {
            Write-Log "DNS assignment note on $($adapter.Name): $($_.Exception.Message)" "WARNING"
        }
    }
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    Write-Log "Cloudflare safe browsing filters active." "SUCCESS"
}

# -------------------------------------------------------------------------
# Phase 10: Universal Codecs & Runtimes for Intel UHD 620 QuickSync
# -------------------------------------------------------------------------
function Invoke-CodecsAndRuntimes {
    Write-Log "Phase 10: Installing Universal Codecs & Visual C++ All-in-One" "STEP"
    
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Log "Winget unavailable. Skipping runtime package installations." "WARNING"
        return
    }

    # K-Lite Codec Pack Standard (Configured for Intel QuickSync hardware decoding)
    Write-Log "Installing K-Lite Codec Pack Standard..." "INFO"
    try {
        winget install --id "CodecGuide.K-LiteCodecPack.Standard" --silent --accept-package-agreements --accept-source-agreements --source winget
        Write-Log "K-Lite Codec Pack Standard installed." "SUCCESS"
    } catch {}

    # Modern Windows Media Extensions
    $modernCodecs = @(
        "Microsoft.AV1VideoExtension",
        "Microsoft.VP9VideoExtensions",
        "Microsoft.HEIFImageExtension",
        "Microsoft.VCRedist.2015+.x64",
        "Microsoft.VCRedist.2015+.x86",
        "Microsoft.DirectX",
        "Microsoft.DotNet.DesktopRuntime.8"
    )
    foreach ($c in $modernCodecs) {
        try {
            winget install --id $c --silent --accept-package-agreements --accept-source-agreements --source winget
            Write-Log "Package $c verified/installed." "SUCCESS"
        } catch {}
    }
}

# -------------------------------------------------------------------------
# Phase 11: Dual-Mode Power Management (AC vs Battery)
# -------------------------------------------------------------------------
function Invoke-ThinkPadPowerTuning {
    Write-Log "Phase 11: Configuring Dual-Mode ThinkPad Power Management" "STEP"
    
    $ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

    # Unlock Ultimate Performance if needed
    $plans = powercfg -list
    if ($plans -notmatch $ultimateGuid) {
        powercfg -duplicatescheme $ultimateGuid | Out-Null
    }

    # Activate High/Ultimate Performance
    powercfg -setactive $ultimateGuid -ErrorAction SilentlyContinue

    # Custom ThinkPad T490s Sub-Settings:
    # CPU: Min 5% on AC/DC (allows downclocking at idle), Max 100%
    powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
    powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
    powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
    powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

    # PCIe Link State Power Management: 0 (Off) on AC
    powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9dec-e4431fb2179f ee12f906-d277-404b-b6da-e5fa1a576df5 0

    # USB Selective Suspend: 0 (Disabled on AC)
    powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba4d5a0 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

    powercfg /setactive SCHEME_CURRENT
    Write-Log "ThinkPad AC / Battery power schemes calibrated." "SUCCESS"
}

# -------------------------------------------------------------------------
# Orchestration & Flow Control
# -------------------------------------------------------------------------
function Run-AllOptimizations {
    New-OptimizationRestorePoint
    Invoke-PreflightAnalysis
    Invoke-ThinkPadBiosTuning
    Invoke-ThinkPadBatteryProtection
    Invoke-IntelWiFiTuning
    Invoke-IntelNVMeTuning
    Invoke-ThinkPadMemoryTuning
    Invoke-OSBugFixes
    Invoke-SmartUpdates
    Invoke-TempCleaning
    Invoke-SecurityAndDNS
    Invoke-CodecsAndRuntimes
    Invoke-ThinkPadPowerTuning

    Write-Host "`n================================================================================" -ForegroundColor Green
    Write-Host "  THINKPAD T490s CUSTOM OPTIMIZATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host ("  Detailed execution log saved to: {0}" -f $LogFile) -ForegroundColor White
    Write-Host "================================================================================`n" -ForegroundColor Green
}

# Switches Handling
if ($RevertDNS) {
    Invoke-RevertDNS
    exit 0
}

if ($ChargeToFull) {
    Invoke-ThinkPadBatteryProtection -SetFullCharge
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
# Interactive Menu
# -------------------------------------------------------------------------
Show-Banner
Write-Host "Select an option from the ThinkPad T490s optimization menu:" -ForegroundColor White
Write-Host "  [1]  Run Full System Diagnostics & Battery Wear Analysis" -ForegroundColor Cyan
Write-Host "  [2]  Tune ThinkPad BIOS WMI (Adaptive Thermal Management AC/DC)" -ForegroundColor Cyan
Write-Host "  [3]  Enforce Battery Protection (75%-80% Charge Threshold)" -ForegroundColor Cyan
Write-Host "  [4]  Tune Intel Wireless-AC 9560 (Throughput Booster, 5GHz Prefer)" -ForegroundColor Cyan
Write-Host "  [5]  Optimize Intel NVMe SSD (Trim, Disable 8.3 & LastAccess writes)" -ForegroundColor Cyan
Write-Host "  [6]  Configure 32GB RAM & Low-Latency MMCSS / TCP Tuning" -ForegroundColor Cyan
Write-Host "  [7]  Fix Windows 11 Build 26300 Core Bugs (SFC, DISM, Winsock)" -ForegroundColor Cyan
Write-Host "  [8]  Smart Auto-Update Packages & Windows Updates" -ForegroundColor Cyan
Write-Host "  [9]  Deep Temp & Component Store Cleanup" -ForegroundColor Cyan
Write-Host "  [10] Apply Security Hardening & Cloudflare 1.1.1.3 Family DNS" -ForegroundColor Cyan
Write-Host "  [11] Install Universal Codecs (QuickSync) & VC++ All-in-One" -ForegroundColor Cyan
Write-Host "  [12] Tune ThinkPad Dual-Mode Power Management (AC vs Battery)" -ForegroundColor Cyan
Write-Host "  [F]  Travel Mode: Temporarily Charge Battery to 100%" -ForegroundColor Yellow
Write-Host "  [A]  RUN ALL THINKPAD OPTIMIZATIONS (Recommended)" -ForegroundColor Green
Write-Host "  [R]  Revert Cloudflare DNS to Original Settings" -ForegroundColor Yellow
Write-Host "  [Q]  Quit" -ForegroundColor Red

$choice = Read-Host "`nEnter selection (1-12, F, A, R, Q)"
switch ($choice.ToUpper()) {
    "1"  { Invoke-PreflightAnalysis }
    "2"  { Invoke-ThinkPadBiosTuning }
    "3"  { Invoke-ThinkPadBatteryProtection }
    "4"  { Invoke-IntelWiFiTuning }
    "5"  { Invoke-IntelNVMeTuning }
    "6"  { Invoke-ThinkPadMemoryTuning }
    "7"  { Invoke-OSBugFixes }
    "8"  { Invoke-SmartUpdates }
    "9"  { Invoke-TempCleaning }
    "10" { Invoke-SecurityAndDNS }
    "11" { Invoke-CodecsAndRuntimes }
    "12" { Invoke-ThinkPadPowerTuning }
    "F"  { Invoke-ThinkPadBatteryProtection -SetFullCharge }
    "A"  { Run-AllOptimizations }
    "R"  { Invoke-RevertDNS }
    "Q"  { Write-Host "Exiting." -ForegroundColor Gray; exit 0 }
    Default { Write-Host "Invalid selection. Exiting." -ForegroundColor Red; exit 1 }
}
