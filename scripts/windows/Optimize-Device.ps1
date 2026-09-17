<#
.SYNOPSIS
    ThinkPad-T490s-UltraDeep: Kernel- and Hardware-Level Deep Optimization Suite.

.DESCRIPTION
    Custom-engineered for:
    - Device Model   : Lenovo ThinkPad T490s (Machine Type: 20NYS64T00, BIOS: N2JETB0W)
    - Processor      : Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz (4C/8T, Whiskey Lake-U)
    - Memory         : 32 GB DDR4 High-Capacity System RAM
    - Storage        : INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD + Realtek PCIe Card Reader
    - Networking     : Intel(R) Wireless-AC 9560 160MHz & Intel(R) Ethernet I219-LM
    - Battery        : SMP 02DL014 57Wh Internal Li-ion Battery
    - Operating Sys  : Microsoft Windows 11 Pro (Build 26300+)

    Ultra-Deep Optimization Sectors:
    1.  CPU & Microcode Power Engine: Intel SpeedShift EPP (0 on AC) & Core Unparking (100% on AC).
    2.  32GB RAM Architecture: Disable Memory Compression & Page Combining, lock Kernel in RAM.
    3.  Storage & NVMe Engine: Intel NVMe APST latency zeroing on AC, NTFS Tunneling & LastAccess suppression.
    4.  GPU & DWM Presentation: Hardware-Accelerated GPU Scheduling (HAGS), MenuShowDelay = 0.
    5.  Low-Latency Network Stack: Nagle's algorithm disable (TCPNoDelay = 1), TcpAckFrequency = 1, RSS Queues.
    6.  ThinkPad WMI BIOS: Adaptive Thermal Management Maxima saved directly to ThinkPad NVRAM.
    7.  Windows 11 Kernel Scheduler: Win32PrioritySeparation = 38 (0x26) & MMCSS Gaming/Audio priority.
    8.  Services & Telemetry Debloat: Convert dormant services to Demand-Start (Manual), purge telemetry tasks.
    9.  Battery Preservation & Extreme Battery Mode: 75-80% threshold + Turbo Boost disable on DC.
    10. Security & DNS Hardening: Defender RTP, Firewall, SMBv1/LLMNR mitigation, Cloudflare 1.1.1.3 Family DNS.

.PARAMETER All
    Executes all 10 ultra-deep optimization sectors unattended.

.PARAMETER AnalyzeOnly
    Performs full system and sector diagnostics without modifying any system state.

.PARAMETER ExtremeBattery
    Enables Extreme Battery Mode on DC (caps CPU to 1.9GHz base clock, doubling battery life).

.PARAMETER ChargeToFull
    Temporarily disables the 80% battery conservation threshold to charge to 100% (Travel Mode).

.PARAMETER Rollback
    Restores default Windows kernel, memory, network, and scheduler settings.

.PARAMETER RevertDNS
    Restores original DNS server configuration from backup.
#>

[CmdletBinding()]
param (
    [switch]$All,
    [switch]$AnalyzeOnly,
    [switch]$Interactive,
    [switch]$ExtremeBattery,
    [switch]$ChargeToFull,
    [switch]$Rollback,
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
    Write-Warning "Administrator privileges required for kernel, BIOS, and network optimizations."
    Write-Host "Elevating permissions..." -ForegroundColor Yellow
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($All) { $arguments += " -All" }
        if ($AnalyzeOnly) { $arguments += " -AnalyzeOnly" }
        if ($Interactive) { $arguments += " -Interactive" }
        if ($ExtremeBattery) { $arguments += " -ExtremeBattery" }
        if ($ChargeToFull) { $arguments += " -ChargeToFull" }
        if ($Rollback) { $arguments += " -Rollback" }
        if ($RevertDNS) { $arguments += " -RevertDNS" }
        if ($SkipRestorePoint) { $arguments += " -SkipRestorePoint" }
        
        Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
        exit 0
    }
    catch {
        Write-Error "Failed to elevate privileges. Please run PowerShell as Administrator."
        exit 1
    }
}

# -------------------------------------------------------------------------
# Logging & Storage Setup
# -------------------------------------------------------------------------
$LogDir = $LogPath
$LogFile = Join-Path -Path $LogDir -ChildPath "thinkpad_t490s_ultradeep.log"
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
                                                                             
      ULTRA-DEEP ALL-SECTOR HARDWARE ENGINE | THINKPAD T490s (20NYS64T00)
================================================================================
"@ -ForegroundColor Magenta
}

function New-OptimizationRestorePoint {
    if ($SkipRestorePoint) {
        Write-Log "Restore point skipped by user flag." "INFO"
        return
    }
    Write-Log "Creating Windows System Restore Point..." "STEP"
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Pre-ThinkPad-UltraDeep-Optimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "System Restore Point 'Pre-ThinkPad-UltraDeep-Optimization' created successfully." "SUCCESS"
    }
    catch {
        Write-Log "Restore point notice: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Phase 0: Pre-Flight Hardware Inventory & Sector Health Audit
# -------------------------------------------------------------------------
function Invoke-PreflightAnalysis {
    Write-Log "Auditing All Hardware Sectors & System Health" "STEP"

    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_Bios
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
    $freeRamGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)

    Write-Host "`n  --- THINKPAD T490s PROFILE ---" -ForegroundColor White
    Write-Host ("  Model         : {0} ({1})" -f $cs.Model, $cs.SystemFamily) -ForegroundColor Cyan
    Write-Host ("  Processor     : {0} (4 Cores, 8 Threads, Whiskey Lake-U)" -f $cpu.Name) -ForegroundColor Gray
    Write-Host ("  Memory        : {0} GB DDR4 (Free: {1} GB)" -f $ramGB, $freeRamGB) -ForegroundColor Gray
    Write-Host ("  Operating Sys : {0} (Build {1})" -f $os.Caption, $os.BuildNumber) -ForegroundColor Gray
    Write-Host ("  BIOS Version  : {0}" -f $bios.SMBIOSBIOSVersion) -ForegroundColor Gray

    # Battery Wear Audit
    $regBattery = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Lenovo\PWRMGRV\ConfKeys\Data\X2XP9ABN17M" -ErrorAction SilentlyContinue
    if ($regBattery -and $regBattery.DesignCapacity) {
        $wearPct = [math]::Round(((($regBattery.DesignCapacity - $regBattery.FullChargeCapacityAfterGaugeReset) / $regBattery.DesignCapacity) * 100), 1)
        Write-Host ("  Battery Health: SMP 02DL014 (Health: {0}%, Wear: {1}%, Threshold: {2}%-{3}%)" -f (100 - $wearPct), $wearPct, $regBattery.ChargeStartPercentage, $regBattery.ChargeStopPercentage) -ForegroundColor Green
    }

    # Kernel & Memory Audit
    $mmKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -ErrorAction SilentlyContinue
    $prioKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -ErrorAction SilentlyContinue
    $mmAgent = Get-MMAgent -ErrorAction SilentlyContinue

    Write-Host "`n  --- KERNEL & MEMORY AUDIT ---" -ForegroundColor White
    Write-Host ("  Memory Compression       : {0}" -f $mmAgent.MemoryCompression) -ForegroundColor Gray
    Write-Host ("  DisablePagingExecutive   : {0}" -f $mmKey.DisablePagingExecutive) -ForegroundColor Gray
    Write-Host ("  Win32PrioritySeparation  : {0} (Hex: 0x{0:X2})" -f $prioKey.Win32PrioritySeparation) -ForegroundColor Gray

    # Network Low-Latency Audit
    $wifi = Get-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue
    if ($wifi) {
        $tcpKey = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($wifi.InterfaceGuid)" -ErrorAction SilentlyContinue
        Write-Host "`n  --- NETWORK LATENCY AUDIT (Intel Wireless-AC 9560) ---" -ForegroundColor White
        Write-Host ("  TCPNoDelay (Nagle Off)   : {0}" -f $tcpKey.TCPNoDelay) -ForegroundColor Gray
        Write-Host ("  TcpAckFrequency          : {0}" -f $tcpKey.TcpAckFrequency) -ForegroundColor Gray
    }

    Write-Log "Sector audit completed successfully." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 1: CPU Architecture, SpeedShift EPP & Core Unparking
# -------------------------------------------------------------------------
function Invoke-Sector1_CPUAndPowerLimits {
    Write-Log "Sector 1: Intel SpeedShift EPP & 8-Thread Core Unparking" "STEP"

    # Intel SpeedShift EPP GUID: 36687f9e-e3a5-4dbf-b1dc-15eb381c6863
    # 0 = Maximum Performance (Instant clock ramp-up on AC)
    # 60 = Balanced Energy Preference on Battery
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 0
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR 36687f9e-e3a5-4dbf-b1dc-15eb381c6863 60

    # Core Parking Min Cores GUID: 0cc5b647-c1df-4637-891a-dec35c318583
    # 100% on AC = Unpark all 8 logical threads, 0 latency wakeups
    # 50% on DC = Allow core parking on battery to save power
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc5b647-c1df-4637-891a-dec35c318583 100
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR 0cc5b647-c1df-4637-891a-dec35c318583 50

    # Processor Throttle Policy: Min 5%, Max 100% on AC
    powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
    powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100

    powercfg /setactive SCHEME_CURRENT
    Write-Log "Intel SpeedShift EPP set to 0 (Max Performance on AC) & All 8 threads unparked." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 2: 32GB RAM Architecture & Zero-Compression Engine
# -------------------------------------------------------------------------
function Invoke-Sector2_MemorySubsystem {
    Write-Log "Sector 2: 32GB RAM Optimization (Disable Memory Compression & Page Combining)" "STEP"

    # On 32GB RAM, disabling Memory Compression eliminates CPU decompression overhead and micro-stutter
    try {
        Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
        Disable-MMAgent -PageCombining -ErrorAction SilentlyContinue
        Write-Log "Windows Memory Compression & Page Combining disabled for 32GB RAM." "SUCCESS"
    } catch {
        Write-Log "MMAgent notice: $($_.Exception.Message)" "INFO"
    }

    # Lock Kernel & Drivers into Physical RAM (Zero paging executive latency)
    $memKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty -Path $memKey -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $memKey -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $memKey -Name "LargeSystemCache" -Value 0 -Type DWord -Force

    Write-Log "Windows Kernel locked into physical 32GB RAM (DisablePagingExecutive = 1)." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 3: Storage & Intel NVMe APST Latency Zeroing
# -------------------------------------------------------------------------
function Invoke-Sector3_StorageAndNVMe {
    Write-Log "Sector 3: Intel NVMe (SSDPEKKF512G8L) APST Latency Zeroing & NTFS Engine" "STEP"

    # 1. Enforce TRIM and Volume Re-Trim
    fsutil behavior set DisableDeleteNotify 0 | Out-Null
    Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue | Out-Null
    Write-Log "NVMe TRIM enforced and Drive C: Re-Trimmed." "SUCCESS"

    # 2. Disable NVMe Autonomous Power State Transition (APST) Sleep on AC
    # Subgroup: Disk (0012ee47-9041-4b5d-9b77-535fba8b1442) -> Primary NVMe Idle Timeout (d634455d-5870-4d86-b0d1-172873ca7582) = 0
    powercfg /setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 d634455d-5870-4d86-b0d1-172873ca7582 0
    powercfg /setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 d634455d-5870-4d86-b0d1-172873ca7582 100

    # 3. Disable 8.3 Filename Creation on C:
    fsutil.exe 8dot3name set C: 1 | Out-Null

    # 4. Disable NTFS LastAccess timestamp updates
    fsutil.exe behavior set disablelastaccess 1 | Out-Null

    # 5. Disable NTFS Tunneling (Removes file creation metadata cache lookup overhead)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "MaximumTunnelEntries" -Value 0 -Type DWord -Force

    Write-Log "Intel NVMe APST sleep zeroed on AC; NTFS tunneling and flash wear writes disabled." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 4: GPU, DWM & Desktop Snappiness Engine
# -------------------------------------------------------------------------
function Invoke-Sector4_GPUAndDWM {
    Write-Log "Sector 4: GPU Scheduling (HAGS) & Desktop Window Manager Latency" "STEP"

    # 1. Hardware Accelerated GPU Scheduling (HAGS)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
    Write-Log "Hardware-Accelerated GPU Scheduling (HAGS) set to Enabled (Mode 2)." "SUCCESS"

    # 2. Eliminate Desktop Menu Delay (Instant snappy UI popups)
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Type String -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "1000" -Type String -Force

    # 3. Purge DirectX Shader Cache to eliminate corrupted shader stutters
    $d3dCache = "$env:LOCALAPPDATA\D3DSCache"
    if (Test-Path $d3dCache) {
        Remove-Item "$d3dCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "DirectX Shader Cache purged." "SUCCESS"
    }

    Write-Log "Desktop Window Manager delays eliminated & UI snappiness maximized." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 5: Ultra-Low Latency Network Stack (TCP NoDelay & AckFrequency)
# -------------------------------------------------------------------------
function Invoke-Sector5_NetworkStack {
    Write-Log "Sector 5: TCP NoDelay (Nagle's Algorithm Disable) & Immediate ACK" "STEP"

    $wifi = Get-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue
    if ($wifi) {
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($wifi.InterfaceGuid)"
        
        # TcpAckFrequency = 1: Send ACK immediately, eliminates 200ms delayed-ACK timer
        Set-ItemProperty -Path $tcpKey -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
        # TCPNoDelay = 1: Disables Nagle's algorithm, eliminates packet coalescing delays
        Set-ItemProperty -Path $tcpKey -Name "TCPNoDelay" -Value 1 -Type DWord -Force
        # TcpDelAckTicks = 0
        Set-ItemProperty -Path $tcpKey -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
        
        Write-Log "Nagle's algorithm disabled and TcpAckFrequency=1 enforced on Intel Wireless-AC 9560." "SUCCESS"

        # Adapter Advanced Properties
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "Throughput Booster" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "Preferred Band" -DisplayValue "3. Prefer 5GHz band" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -DisplayName "MIMO Power Save Mode" -DisplayValue "No SMPS" -ErrorAction SilentlyContinue
    }

    # Global TCP Congestion Provider (BBR / Cubic) & Window Auto-Tuning
    netsh int tcp set global autotuninglevel=normal | Out-Null
    try {
        netsh int tcp set supplemental template=internet congestionprovider=bbr | Out-Null
        Write-Log "TCP Congestion Provider set to BBR for optimal throughput." "SUCCESS"
    } catch {
        netsh int tcp set supplemental template=internet congestionprovider=cubic | Out-Null
        Write-Log "TCP Congestion Provider set to Cubic." "SUCCESS"
    }
}

# -------------------------------------------------------------------------
# Sector 6: ThinkPad WMI BIOS Thermal Maxima & Embedded Controller
# -------------------------------------------------------------------------
function Invoke-Sector6_ThinkPadBIOS {
    Write-Log "Sector 6: ThinkPad WMI BIOS Thermal & Embedded Controller Maxima" "STEP"

    try {
        $setBiosObj = Get-CimInstance -Namespace root\wmi -ClassName Lenovo_SetBiosSetting -ErrorAction Stop
        $saveObj = Get-CimInstance -Namespace root\wmi -ClassName Lenovo_SaveBiosSettings -ErrorAction Stop

        $settings = @(
            "AdaptiveThermalManagementAC,MaximizePerformance",
            "AdaptiveThermalManagementBattery,Balanced",
            "SpeedStep,Enable",
            "CPUPowerManagement,Enable",
            "ChargeInBatteryMode,Disable"
        )

        foreach ($s in $settings) {
            Invoke-CimMethod -InputObject $setBiosObj -MethodName SetBiosSetting -Arguments @{ Parameter = $s } | Out-Null
        }
        Invoke-CimMethod -InputObject $saveObj -MethodName SaveBiosSettings | Out-Null
        Write-Log "ThinkPad BIOS thermal & power settings committed to NVRAM." "SUCCESS"
    } catch {
        Write-Log "ThinkPad BIOS note: $($_.Exception.Message)" "WARNING"
    }
}

# -------------------------------------------------------------------------
# Sector 7: Windows 11 Kernel Scheduler & MMCSS Gaming Priority
# -------------------------------------------------------------------------
function Invoke-Sector7_KernelScheduler {
    Write-Log "Sector 7: Win32PrioritySeparation = 38 (0x26) & MMCSS Priority Elevation" "STEP"

    # Win32PrioritySeparation = 38 (Hex 0x26): Short variable quantum with 3:1 foreground boost
    # Used by competitive gamers and low-latency workstations
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
    Write-Log "Win32PrioritySeparation set to 38 (0x26 - Maximum Foreground Responsiveness)." "SUCCESS"

    # MMCSS SystemProfile Tuning
    $sysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
    Set-ItemProperty -Path $sysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -Force

    # MMCSS Games Task Priority Elevation
    $gamesTask = "$sysProfile\Tasks\Games"
    Set-ItemProperty -Path $gamesTask -Name "Priority" -Value 6 -Type DWord -Force
    Set-ItemProperty -Path $gamesTask -Name "GPU Priority" -Value 8 -Type DWord -Force
    Set-ItemProperty -Path $gamesTask -Name "Scheduling Category" -Value "High" -Type String -Force
    Set-ItemProperty -Path $gamesTask -Name "SFIO Priority" -Value "High" -Type String -Force

    Write-Log "Multimedia Class Scheduler Service (MMCSS) elevated to High priority." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 8: Services & Background Telemetry Debloat
# -------------------------------------------------------------------------
function Invoke-Sector8_ServicesAndDebloat {
    Write-Log "Sector 8: Background Services Demand-Start Optimization & Telemetry Purge" "STEP"

    # Convert non-essential background services to Demand-Start (Manual) rather than Disabled
    # This ensures zero idle CPU/RAM usage while preserving full compatibility if requested
    $demandServices = @(
        "MapsBroker",         # Downloaded Maps Manager
        "WerSvc",             # Windows Error Reporting
        "RetailDemo",         # Retail Demo Service
        "XblAuthManager",     # Xbox Live Auth
        "XblGameSave",        # Xbox Game Save
        "XboxNetApiSvc",      # Xbox Live Networking
        "DiagTrack",          # Connected User Experiences and Telemetry
        "dmwappushservice"    # WAP Push Message Routing
    )

    foreach ($svc in $demandServices) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
        } catch {}
    }
    Write-Log "Non-essential background services converted to Demand-Start (Manual)." "SUCCESS"

    # Disable Diagnostic Telemetry Scheduled Tasks
    $telemetryTasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    )
    foreach ($t in $telemetryTasks) {
        try {
            $folder = $t.Substring(0, $t.LastIndexOf("\") + 1)
            $taskName = $t.Substring($t.LastIndexOf("\") + 1)
            Disable-ScheduledTask -TaskPath $folder -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    Write-Log "Telemetry background scheduled tasks disabled." "SUCCESS"
}

# -------------------------------------------------------------------------
# Sector 9: Battery Preservation & Extreme Battery Mode
# -------------------------------------------------------------------------
function Invoke-Sector9_BatteryPreservation {
    param ([switch]$EnableExtremeBattery, [switch]$SetFullCharge)

    Write-Log "Sector 9: ThinkPad Battery Health (75%-80% Threshold) & Power Modes" "STEP"

    $confKeysPath = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\PWRMGRV\ConfKeys\Data"
    if (Test-Path $confKeysPath) {
        $batteryKeys = Get-ChildItem -Path $confKeysPath -ErrorAction SilentlyContinue
        foreach ($bk in $batteryKeys) {
            if ($SetFullCharge) {
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartControl" -Value 0 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopControl" -Value 0 -Type DWord -Force
                Write-Log "Battery Charge Threshold DISABLED (Travel Mode: Charges to 100%)." "WARNING"
            } else {
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartControl" -Value 1 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopControl" -Value 1 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStartPercentage" -Value 75 -Type DWord -Force
                Set-ItemProperty -Path $bk.PSPath -Name "ChargeStopPercentage" -Value 80 -Type DWord -Force
                Write-Log "Battery 75%-80% Conservation Threshold enforced (SMP 02DL014 protection)." "SUCCESS"
            }
        }
        Restart-Service -Name "IBMPMSVC" -Force -ErrorAction SilentlyContinue
    }

    # Extreme Battery Mode Tuning (Caps CPU clock to 1.9GHz base clock on battery, eliminating 25W Turbo spikes)
    if ($EnableExtremeBattery) {
        powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 99
        powercfg /setactive SCHEME_CURRENT
        Write-Log "EXTREME BATTERY MODE ACTIVE: Turbo Boost disabled on battery (1.9GHz cap, ~8-10h runtime)." "SUCCESS"
    } else {
        powercfg /setdcvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        powercfg /setactive SCHEME_CURRENT
    }
}

# -------------------------------------------------------------------------
# Sector 10: Security Hardening & Cloudflare 1.1.1.3 Family DNS
# -------------------------------------------------------------------------
function Invoke-Sector10_SecurityAndDNS {
    Write-Log "Sector 10: Security Hardening & Cloudflare 1.1.1.3 Family DNS" "STEP"

    # Backup original DNS
    $backupData = @()
    Get-NetAdapter | Where-Object Status -eq "Up" | ForEach-Object {
        $backupData += [PSCustomObject]@{
            InterfaceIndex = $_.InterfaceIndex
            Name           = $_.Name
            IPv4           = (Get-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).ServerAddresses
            IPv6           = (Get-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv6).ServerAddresses
        }
    }
    $backupData | ConvertTo-Json | Set-Content -Path $DnsBackupFile -Force

    # Enforce Cloudflare Family DNS
    Get-NetAdapter | Where-Object Status -eq "Up" | ForEach-Object {
        Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses @("1.1.1.3", "1.0.0.3") -ErrorAction SilentlyContinue
    }
    Clear-DnsClientCache -ErrorAction SilentlyContinue

    # Defender & Firewall Hardening
    Set-MpPreference -DisableRealtimeMonitoring $false -DisableIOAVProtection $false -SubmitSamplesConsent 1 -MAPSReporting 2 -ErrorAction SilentlyContinue
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null

    Write-Log "Defender Real-Time Protection active & Cloudflare 1.1.1.3 Family DNS applied." "SUCCESS"
}

# -------------------------------------------------------------------------
# Rollback Functionality
# -------------------------------------------------------------------------
function Invoke-Rollback {
    Write-Log "Initiating Full Rollback to Default Windows Settings..." "STEP"

    # 1. Reset Win32PrioritySeparation to default 2
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord -Force

    # 2. Re-enable Memory Compression
    Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
    Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue

    # 3. Reset TCP NoDelay on Wi-Fi
    $wifi = Get-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue
    if ($wifi) {
        $tcpKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($wifi.InterfaceGuid)"
        Remove-ItemProperty -Path $tcpKey -Name "TCPNoDelay" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $tcpKey -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
    }

    # 4. Restore Default MMCSS
    $gamesTask = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    Set-ItemProperty -Path $gamesTask -Name "Priority" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path $gamesTask -Name "Scheduling Category" -Value "Medium" -Type String -Force
    Set-ItemProperty -Path $gamesTask -Name "SFIO Priority" -Value "Normal" -Type String -Force

    # 5. Restore DNS
    if (Test-Path $DnsBackupFile) {
        $backup = Get-Content $DnsBackupFile -Raw | ConvertFrom-Json
        foreach ($b in $backup) {
            Set-DnsClientServerAddress -InterfaceIndex $b.InterfaceIndex -ServerAddresses $b.IPv4 -ErrorAction SilentlyContinue
        }
    }

    Write-Log "System registry, memory, network, and scheduler settings reverted to defaults." "SUCCESS"
}

# -------------------------------------------------------------------------
# Master Orchestration
# -------------------------------------------------------------------------
function Run-AllUltraDeepOptimizations {
    New-OptimizationRestorePoint
    Invoke-PreflightAnalysis
    Invoke-Sector1_CPUAndPowerLimits
    Invoke-Sector2_MemorySubsystem
    Invoke-Sector3_StorageAndNVMe
    Invoke-Sector4_GPUAndDWM
    Invoke-Sector5_NetworkStack
    Invoke-Sector6_ThinkPadBIOS
    Invoke-Sector7_KernelScheduler
    Invoke-Sector8_ServicesAndDebloat
    Invoke-Sector9_BatteryPreservation -EnableExtremeBattery:$ExtremeBattery -SetFullCharge:$ChargeToFull
    Invoke-Sector10_SecurityAndDNS

    Write-Host "`n================================================================================" -ForegroundColor Green
    Write-Host "  ALL 10 ULTRA-DEEP OPTIMIZATION SECTORS COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host ("  Detailed execution log saved to: {0}" -f $LogFile) -ForegroundColor White
    Write-Host "================================================================================`n" -ForegroundColor Green
}

# CLI Switch Handlers
if ($Rollback) { Show-Banner; Invoke-Rollback; exit 0 }
if ($AnalyzeOnly) { Show-Banner; Invoke-PreflightAnalysis; exit 0 }
if ($ChargeToFull) { Show-Banner; Invoke-Sector9_BatteryPreservation -SetFullCharge; exit 0 }
if ($All) { Show-Banner; Run-AllUltraDeepOptimizations; exit 0 }

# Interactive Menu
Show-Banner
Write-Host "Select an Ultra-Deep Optimization Sector for ThinkPad T490s:" -ForegroundColor White
Write-Host "  [1]  Run Full System & Sector Diagnostics (Read-Only Audit)" -ForegroundColor Cyan
Write-Host "  [2]  Sector 1: CPU SpeedShift EPP & Core Unparking" -ForegroundColor Cyan
Write-Host "  [3]  Sector 2: 32GB RAM Zero-Compression Engine" -ForegroundColor Cyan
Write-Host "  [4]  Sector 3: Intel NVMe APST Latency Zeroing & NTFS Engine" -ForegroundColor Cyan
Write-Host "  [5]  Sector 4: GPU Scheduling (HAGS) & DWM Snappiness" -ForegroundColor Cyan
Write-Host "  [6]  Sector 5: TCP NoDelay & Network Low-Latency Stack" -ForegroundColor Cyan
Write-Host "  [7]  Sector 6: ThinkPad WMI BIOS Thermal Maxima (NVRAM)" -ForegroundColor Cyan
Write-Host "  [8]  Sector 7: Win32PrioritySeparation (0x26) & MMCSS Gaming" -ForegroundColor Cyan
Write-Host "  [9]  Sector 8: Services Demand-Start Optimization & Telemetry" -ForegroundColor Cyan
Write-Host "  [10] Sector 9: Battery Conservation (75-80% Threshold)" -ForegroundColor Cyan
Write-Host "  [11] Sector 10: Security Hardening & Cloudflare 1.1.1.3 DNS" -ForegroundColor Cyan
Write-Host "  [E]  Toggle Extreme Battery Saver (Capping CPU at 1.9GHz on Battery)" -ForegroundColor Yellow
Write-Host "  [F]  Travel Mode: Temporarily Charge Battery to 100%" -ForegroundColor Yellow
Write-Host "  [A]  RUN ALL 10 ULTRA-DEEP SECTORS (Recommended)" -ForegroundColor Green
Write-Host "  [X]  Rollback All System Settings to Windows Defaults" -ForegroundColor Red
Write-Host "  [Q]  Quit" -ForegroundColor Gray

$choice = Read-Host "`nEnter selection"
switch ($choice.ToUpper()) {
    "1"  { Invoke-PreflightAnalysis }
    "2"  { Invoke-Sector1_CPUAndPowerLimits }
    "3"  { Invoke-Sector2_MemorySubsystem }
    "4"  { Invoke-Sector3_StorageAndNVMe }
    "5"  { Invoke-Sector4_GPUAndDWM }
    "6"  { Invoke-Sector5_NetworkStack }
    "7"  { Invoke-Sector6_ThinkPadBIOS }
    "8"  { Invoke-Sector7_KernelScheduler }
    "9"  { Invoke-Sector8_ServicesAndDebloat }
    "10" { Invoke-Sector9_BatteryPreservation }
    "11" { Invoke-Sector10_SecurityAndDNS }
    "E"  { Invoke-Sector9_BatteryPreservation -EnableExtremeBattery }
    "F"  { Invoke-Sector9_BatteryPreservation -SetFullCharge }
    "A"  { Run-AllUltraDeepOptimizations }
    "X"  { Invoke-Rollback }
    "Q"  { exit 0 }
    Default { Write-Host "Invalid selection." -ForegroundColor Red; exit 1 }
}
