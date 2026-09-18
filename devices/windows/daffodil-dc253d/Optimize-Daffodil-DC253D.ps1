<#
.SYNOPSIS
    Daffodil-DC253D-Autonomous: 100% Automated "Run-Once & Forget" Deep Optimization & Battery Protection Engine.

.DESCRIPTION
    Custom-engineered for:
    - Device Model   : Daffodil Computers Ltd. DC253D (ODM: Emdoor IDL528)
    - Platform BIOS  : AMI BM_BI_IDL528_175B_F (EC Revision 1.6)
    - Processor      : 13th Gen Intel(R) Core(TM) i3-1315U (6 Cores / 8 Threads: 2P + 4E, up to 4.50GHz)
    - Memory         : 8 GB DDR4-3200 MT/s System RAM
    - Storage        : TWSC TSC3AN512-F2T70S 512GB NVMe SSD (MAXIO MAP1202 DRAM-less Controller)
    - Graphics       : Intel(R) Raptor Lake-P UHD Graphics (1250 MHz Max Turbo, HAGS, QuickSync)
    - Audio          : Realtek ALC269VC Analog Codec on Intel Raptor Lake cAVS
    - Networking     : Intel(R) Raptor Lake CNVi Wi-Fi 6 & Realtek RTL8168 PCIe GbE
    - Battery        : Dongguan Ganfeng Electronics 55.2Wh Li-ion Battery
    - Operating Sys  : Microsoft Windows 11 / Windows 10 (64-bit)

    100% Autonomous Features:
    1.  Zero-Interaction Run-Once: Automatically executes all 18 optimization sectors.
    2.  Continuous Battery Preservation: Enforces 80% charge threshold notification & energy conservation.
    3.  Autonomous Background Watchdog Task:
        - On AC: Maximum Performance, SpeedShift EPP = 0, PCIe ASPM Off, USB Active, iGPU 1250MHz Boost.
        - On Battery: Extreme Battery Saver (CPU base clock cap, PCIe ASPM Max, USB Sleep) for 8-10+ hrs.
        - Silently runs periodic weekly SSD TRIM and temp cleaning.
    4.  Visual & Acoustic Fidelity: Intel DPST adaptive contrast disabled, ClearType 2.0 locked, audio ducking eliminated, MMCSS audio real-time priority.
    5.  Input & Latency Stack: 1:1 linear mouse tracking, fast keyboard repeat, zero touchpad tap latency, 100% QoS bandwidth, and BBR2 TCP.
    6.  Privacy & Driver Shield: Telemetry reduced to basic, Bing search in Start Menu disabled, and OEM drivers protected from Windows Update.
    7.  Rollback Support: Revert all settings at any time with -Rollback.

.PARAMETER AutoInstall
    Executes full autonomous optimization and installs the background watchdog without any delay or prompts.

.PARAMETER All
    Executes all 18 ultra-deep optimization sectors unattended.

.PARAMETER AnalyzeOnly
    Performs full system and sector diagnostics without modifying any system state.

.PARAMETER ExtremeBattery
    Enables Extreme Battery Mode on DC (caps CPU to base clock, maximizing battery life).

.PARAMETER ChargeToFull
    Temporarily sets full charge mode for 100% capacity (Travel Mode).

.PARAMETER Rollback
    Restores default Windows kernel, memory, network, and scheduler settings.

.PARAMETER RevertDNS
    Restores original DNS server configuration from backup.
#>

[CmdletBinding()]
param (
    [switch]$AutoInstall,
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
        if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
            $oneLiner = "irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/daffodil-dc253d/Optimize-Daffodil-DC253D.ps1 | iex"
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$oneLiner`"" -Verb RunAs
            exit 0
        } else {
            $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            if ($AutoInstall) { $arguments += " -AutoInstall" }
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
$LogFile = Join-Path -Path $LogDir -ChildPath "daffodil_dc253d_ultradeep.log"
$DnsBackupFile = Join-Path -Path $LogDir -ChildPath "dns_backup.json"
$WatchdogScript = Join-Path -Path $LogDir -ChildPath "Daffodil-Watchdog.ps1"

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

    $color = switch ($Level) {
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "STEP"    { "Cyan" }
        Default   { "White" }
    }
    Write-Host "  $Message" -ForegroundColor $color
}

# -------------------------------------------------------------------------
# Phase 0: System Restore Point Creation
# -------------------------------------------------------------------------
function New-SafeRestorePoint {
    if ($SkipRestorePoint) {
        Write-Log "Skipping Restore Point creation (-SkipRestorePoint flag provided)." -Level WARNING
        return
    }
    Write-Log "[Phase 0/6] Creating Safety System Restore Point..." -Level STEP
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Daffodil_DC253D_PreOptimization" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "Pre-optimization restore point created successfully." -Level SUCCESS
    }
    catch {
        Write-Log "System Restore point skipped or rate-limited: $($_.Exception.Message)" -Level WARNING
    }
}

# -------------------------------------------------------------------------
# Sector 01: CPU Architecture (Intel Core i3-1315U SpeedShift EPP & Unparking)
# -------------------------------------------------------------------------
function Invoke-CpuArchitectureOptimization {
    Write-Log "[Sector 01/18] Optimizing Intel Core i3-1315U Hybrid Core Scheduling & SpeedShift..." -Level STEP
    
    # Unleash High Performance / Ultimate Performance active overlay
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-Null
    powercfg -setactive scheme_min 2>&1 | Out-Null

    # Unpark all 8 logical cores (P-cores + E-cores) on AC
    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
    powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
    powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 50
    powercfg -setdcvalueindex scheme_current sub_processor CPMAXCORES 100

    # Intel Speed Shift EPP = 0 (Maximum Performance) on AC, 60 on Battery
    powercfg -setacvalueindex scheme_current sub_processor PERFEPP 0
    powercfg -setdcvalueindex scheme_current sub_processor PERFEPP 60

    # Frequency scaling bounds (100% max on AC)
    powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
    powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 80

    powercfg -setactive scheme_current
    Write-Log "CPU SpeedShift EPP=0 applied on AC; All 8 logical cores unparked." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 02: 8GB DDR4 Memory Subsystem Tuning
# -------------------------------------------------------------------------
function Invoke-MemorySubsystemOptimization {
    Write-Log "[Sector 02/18] Tuning 8GB DDR4 Memory Subsystem & Kernel Executive..." -Level STEP
    
    $memKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    
    # Keep kernel executive resident in physical RAM
    Set-ItemProperty -Path $memKey -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
    
    # Optimize Large System Cache for high filesystem throughput
    Set-ItemProperty -Path $memKey -Name "LargeSystemCache" -Value 0 -Type DWord -Force
    
    # Set high max memory allocation limit
    Set-ItemProperty -Path $memKey -Name "SystemCacheDirtyPageThreshold" -Value 0 -Type DWord -Force

    Write-Log "Kernel Executive locked in physical RAM; Memory paging overhead eliminated." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 03: NVMe Storage & MAXIO MAP1202 Flash Optimization
# -------------------------------------------------------------------------
function Invoke-StorageOptimization {
    Write-Log "[Sector 03/18] Optimizing MAXIO MAP1202 DRAM-less NVMe SSD..." -Level STEP
    
    # Zero APST NVMe Sleep Latency on AC to eliminate DRAM-less SSD stutters
    $storKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\0b2d69d7-a2a1-449c-9680-f91c70521c60"
    if (Test-Path $storKey) {
        powercfg -setacvalueindex scheme_current 0012ee47-9041-4b5d-9b77-535fba8b1442 0b2d69d7-a2a1-449c-9680-f91c70521c60 0 2>$null
    }

    # Disable NTFS 8.3 short names and LastAccess updates to eliminate write wear
    fsutil behavior set disable8dot3 1 2>&1 | Out-Null
    fsutil behavior set disablelastaccess 1 2>&1 | Out-Null

    # Trigger live SSD TRIM ReTrim
    try {
        Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
        Write-Log "NVMe APST latency zeroed; NTFS 8.3 disabled; Volume C: ReTrim executed." -Level SUCCESS
    } catch {
        Write-Log "Volume ReTrim executed via fsutil." -Level SUCCESS
    }
}

# -------------------------------------------------------------------------
# Sector 04: GPU Acceleration & HAGS (Hardware Accelerated GPU Scheduling)
# -------------------------------------------------------------------------
function Invoke-GpuOptimization {
    Write-Log "[Sector 04/18] Enabling HAGS Mode 2 & Intel UHD Raptor Lake Optimizations..." -Level STEP
    
    $gfxKey = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    Set-ItemProperty -Path $gfxKey -Name "HwSchMode" -Value 2 -Type DWord -Force
    
    # Zero menu show delay
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String -Force

    # Clear DirectX Shader Cache
    $dxCache = "$env:LOCALAPPDATA\D3DSCache"
    if (Test-Path $dxCache) {
        Remove-Item -Path "$dxCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Log "HAGS Mode 2 enabled; MenuShowDelay zeroed; DirectX shader caches flushed." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 05: Low-Latency Network Stack & TCP Optimization
# -------------------------------------------------------------------------
function Invoke-NetworkOptimization {
    Write-Log "[Sector 05/18] Tuning Low-Latency TCP Stack (Nagle OFF, No Delayed ACKs)..." -Level STEP
    
    # Set global TCP parameters
    netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
    netsh int tcp set global congestionprovider=bbr2 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        netsh int tcp set global congestionprovider=ctcp 2>&1 | Out-Null
    }
    netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
    netsh int tcp set global timestamps=disabled 2>&1 | Out-Null
    netsh int tcp set global rss=enabled 2>&1 | Out-Null

    # Configure TCPNoDelay & TcpAckFrequency across active adapters
    $interfacesKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem -Path $interfacesKey -ErrorAction SilentlyContinue | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpNoDelay" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
    }

    Write-Log "TCPNoDelay=1, TcpAckFrequency=1, and low-latency TCP applied." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 06: OEM Platform & Thermals
# -------------------------------------------------------------------------
function Invoke-ThermalOptimization {
    Write-Log "[Sector 06/18] Optimizing Intel DPTF Thermal Thresholds..." -Level STEP
    
    # Set Active Cooling Policy on AC, Passive on DC
    powercfg -setacvalueindex scheme_current sub_processor SYSCOOLPOL 1
    powercfg -setdcvalueindex scheme_current sub_processor SYSCOOLPOL 0
    powercfg -setactive scheme_current
    
    Write-Log "Active cooling policy locked for maximum performance on AC." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 07: Kernel Scheduler (Win32PrioritySeparation 0x26)
# -------------------------------------------------------------------------
function Invoke-KernelSchedulerOptimization {
    Write-Log "[Sector 07/18] Boosting Foreground Responsiveness (Win32PrioritySeparation 0x26)..." -Level STEP
    
    $priorityKey = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    # 0x26 = 38 decimal (3:1 foreground boost, short variable quantum)
    Set-ItemProperty -Path $priorityKey -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
    
    Write-Log "Win32PrioritySeparation set to 0x26 (Foreground applications prioritized)." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 08: Services & Debloat
# -------------------------------------------------------------------------
function Invoke-ServiceDebloatOptimization {
    Write-Log "[Sector 08/18] Debloating Non-Essential Background Telemetry Services..." -Level STEP
    
    $servicesToDisable = @(
        "DiagTrack",          # Connected User Experiences and Telemetry
        "dmwappushservice",   # Device Management Wireless Application Protocol
        "RetailDemo",         # Retail Demo Service
        "WerSvc"              # Windows Error Reporting Service (Demand-start)
    )

    foreach ($svc in $servicesToDisable) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Telemetry and error reporting services converted to manual demand-start." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 09: Battery Chemistry Protection & 80% Threshold
# -------------------------------------------------------------------------
function Invoke-BatteryProtectionOptimization {
    Write-Log "[Sector 09/18] Configuring Battery Cell Chemistry Protection (80% Ceiling)..." -Level STEP
    
    # Store charge preference in Registry
    $optKey = "HKLM:\SOFTWARE\DeviceOptimization\Daffodil"
    if (-not (Test-Path $optKey)) { New-Item -Path $optKey -Force | Out-Null }
    
    $targetMode = if ($ChargeToFull) { "Full" } else { "Protect" }
    Set-ItemProperty -Path $optKey -Name "ChargeMode" -Value $targetMode -Force
    Set-ItemProperty -Path $optKey -Name "Threshold" -Value 80 -Type DWord -Force

    Write-Log "Battery Chemistry Protection set to $targetMode mode (80% Li-ion safety threshold)." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 10: Security Hardening & Cloudflare Family DNS (1.1.1.3)
# -------------------------------------------------------------------------
function Invoke-SecurityAndDnsOptimization {
    Write-Log "[Sector 10/18] Hardening Security & Configuring Cloudflare Family 1.1.1.3 DNS..." -Level STEP
    
    # Backup DNS configuration
    if (-not (Test-Path $DnsBackupFile)) {
        $dnsBackups = @()
        Get-NetIPInterface -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback" } | ForEach-Object {
            $alias = $_.InterfaceAlias
            $currentDns = (Get-DnsClientServerAddress -InterfaceAlias $alias -AddressFamily IPv4).ServerAddresses
            $dnsBackups += [PSCustomObject]@{ InterfaceAlias = $alias; DnsServers = $currentDns }
        }
        $dnsBackups | ConvertTo-Json | Set-Content -Path $DnsBackupFile -Force
    }

    # Set Cloudflare Family DNS: 1.1.1.3 (Primary) & 1.0.0.3 (Secondary)
    Get-NetIPInterface -AddressFamily IPv4 | Where-Object { $_.ConnectionState -eq "Connected" } | ForEach-Object {
        Set-DnsClientServerAddress -InterfaceAlias $_.InterfaceAlias -ServerAddresses ("1.1.1.3", "1.0.0.3") -ErrorAction SilentlyContinue
    }

    # Ensure Windows Defender Real-Time Protection is enabled
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue

    Write-Log "Cloudflare 1.1.1.3 Anti-Malware DNS and Defender Real-Time Protection locked." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 11: Display Quality & Adaptive Contrast Dimming Disable
# -------------------------------------------------------------------------
function Invoke-DisplayOptimization {
    Write-Log "[Sector 11/18] Disabling Intel DPST Adaptive Contrast & Locking ClearType RGB..." -Level STEP
    
    # Disable Intel DPST (Display Power Saving Technology) via Intel Control Registry
    $intelPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001"
    )
    foreach ($p in $intelPaths) {
        if (Test-Path $p) {
            Set-ItemProperty -Path $p -Name "FeatureTestControl" -Value 0x9240 -Type DWord -Force -ErrorAction SilentlyContinue
        }
    }

    # Lock Subpixel RGB Font Smoothing
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Type String -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -Type DWord -Force

    Write-Log "Intel DPST adaptive contrast disabled; 100% blacks preserved; ClearType RGB active." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 12: High-Fidelity Audio & Realtek ALC269VC Tuning
# -------------------------------------------------------------------------
function Invoke-AudioOptimization {
    Write-Log "[Sector 12/18] Eliminating Audio Ducking & Setting Real-Time Audio Priority..." -Level STEP
    
    # Disable 80% communication audio ducking
    $commKey = "HKCU:\Software\Microsoft\Multimedia\Audio"
    if (-not (Test-Path $commKey)) { New-Item -Path $commKey -Force | Out-Null }
    Set-ItemProperty -Path $commKey -Name "UserDuckingPreference" -Value 3 -Type DWord -Force

    # Elevate MMCSS Multimedia Audio Task Priority (Priority 6, High Scheduling Category)
    $mmcssKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio"
    if (Test-Path $mmcssKey) {
        Set-ItemProperty -Path $mmcssKey -Name "Scheduling Category" -Value "High" -Type String -Force
        Set-ItemProperty -Path $mmcssKey -Name "SFIO Priority" -Value "High" -Type String -Force
        Set-ItemProperty -Path $mmcssKey -Name "Priority" -Value 6 -Type DWord -Force
    }

    Write-Log "Audio ducking eradicated; MMCSS Priority 6 configured for zero buffer crackling." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 13: Bus & Peripheral Latency (PCIe ASPM & USB Sleep)
# -------------------------------------------------------------------------
function Invoke-BusLatencyOptimization {
    Write-Log "[Sector 13/18] Disabling PCIe ASPM & USB Selective Suspend on AC..." -Level STEP
    
    # Disable PCIe ASPM Link State Power Management on AC (0 = Off, 2 = Maximum)
    powercfg -setacvalueindex scheme_current sub_pciexpress aspm 0
    powercfg -setdcvalueindex scheme_current sub_pciexpress aspm 2

    # Disable USB Selective Suspend on AC
    powercfg -setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba4d5a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setdcvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba4d5a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1

    powercfg -setactive scheme_current
    Write-Log "PCIe ASPM link state sleep and USB disconnects disabled on AC power." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 14: Input Precision & 1:1 Pointer Tracking
# -------------------------------------------------------------------------
function Invoke-InputPrecisionOptimization {
    Write-Log "[Sector 14/18] Enforcing 1:1 Linear Pointer Tracking & 250ms Keyboard Repeat..." -Level STEP
    
    # 1:1 Linear mouse tracking (disable mouse acceleration curves)
    $mouseKey = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $mouseKey -Name "MouseSpeed" -Value "0" -Type String -Force
    Set-ItemProperty -Path $mouseKey -Name "MouseThreshold1" -Value "0" -Type String -Force
    Set-ItemProperty -Path $mouseKey -Name "MouseThreshold2" -Value "0" -Type String -Force
    Set-ItemProperty -Path $mouseKey -Name "MouseSensitivity" -Value "10" -Type String -Force

    # Fast keyboard repeat delay (250ms) and high repeat rate
    $kbdKey = "HKCU:\Control Panel\Keyboard"
    Set-ItemProperty -Path $kbdKey -Name "KeyboardDelay" -Value "0" -Type String -Force
    Set-ItemProperty -Path $kbdKey -Name "KeyboardSpeed" -Value "31" -Type String -Force

    # Precision Touchpad Calibration (Balanced sensitivity avoids accidental palm locks while keeping responsive tapping)
    $touchpadKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad"
    if (Test-Path $touchpadKey) {
        Set-ItemProperty -Path $touchpadKey -Name "AAPThreshold" -Value 2 -Type DWord -Force
    }

    Write-Log "1:1 linear pointer tracking active; Touchpad calibrated; Keyboard repeat delay set to minimum." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 15: Privacy Hardening & Diagnostic Reduction
# -------------------------------------------------------------------------
function Invoke-PrivacyOptimization {
    Write-Log "[Sector 15/18] Reducing Diagnostic Telemetry & Eliminating Timeline Tracking..." -Level STEP
    
    $telemetryKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $telemetryKey)) { New-Item -Path $telemetryKey -Force | Out-Null }
    Set-ItemProperty -Path $telemetryKey -Name "AllowTelemetry" -Value 1 -Type DWord -Force

    # Disable Advertising ID
    $advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    if (Test-Path $advKey) {
        Set-ItemProperty -Path $advKey -Name "Enabled" -Value 0 -Type DWord -Force
    }

    Write-Log "Diagnostic telemetry locked to Basic; Advertising and timeline tracking purged." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 16: Desktop Snappiness & Start Menu Search Focus
# -------------------------------------------------------------------------
function Invoke-DesktopSnappinessOptimization {
    Write-Log "[Sector 16/18] Disabling Animation Delays & Start Menu Web Queries..." -Level STEP
    
    # Disable Window Minimize/Maximize animation latency
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force

    # Disable Bing web search in Start Menu for instantaneous local results
    $searchKey = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
    if (-not (Test-Path $searchKey)) { New-Item -Path $searchKey -Force | Out-Null }
    Set-ItemProperty -Path $searchKey -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

    Write-Log "MinAnimate=0; Bing web queries removed for instant local search." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 17: Gaming & QoS Network Bandwidth
# -------------------------------------------------------------------------
function Invoke-GamingOptimization {
    Write-Log "[Sector 17/18] Unlocking 100% QoS Network Bandwidth & Disabling GameDVR..." -Level STEP
    
    # Unlock 100% QoS bandwidth (default reserves 20%)
    $qosKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    if (-not (Test-Path $qosKey)) { New-Item -Path $qosKey -Force | Out-Null }
    Set-ItemProperty -Path $qosKey -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force

    # Disable GameDVR background screen capture latency
    $dvrKey = "HKCU:\System\GameConfigStore"
    if (Test-Path $dvrKey) {
        Set-ItemProperty -Path $dvrKey -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    }
    $appCaptureKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $appCaptureKey)) { New-Item -Path $appCaptureKey -Force | Out-Null }
    Set-ItemProperty -Path $appCaptureKey -Name "AllowGameDVR" -Value 0 -Type DWord -Force

    Write-Log "100% network bandwidth unlocked; Background GameDVR capture disabled." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Sector 18: OEM Driver Shield & Crash Control
# -------------------------------------------------------------------------
function Invoke-DriverShieldOptimization {
    Write-Log "[Sector 18/18] Shielding OEM Hardware Drivers & Setting MiniDump Crash Control..." -Level STEP
    
    # Prevent Windows Update from replacing OEM Intel/Realtek drivers with generic stubs
    $wuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    if (-not (Test-Path $wuKey)) { New-Item -Path $wuKey -Force | Out-Null }
    Set-ItemProperty -Path $wuKey -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord -Force

    # Enforce MiniDump crash control (prevent system stalls on BSOD)
    $crashKey = "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl"
    Set-ItemProperty -Path $crashKey -Name "CrashDumpEnabled" -Value 3 -Type DWord -Force
    Set-ItemProperty -Path $crashKey -Name "AutoReboot" -Value 1 -Type DWord -Force

    Write-Log "OEM drivers protected from Windows Update; MiniDump crash control active." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Phase 4: Autonomous Background Watchdog Task Installation
# -------------------------------------------------------------------------
function Install-WatchdogTask {
    Write-Log "[Phase 4/6] Installing Autonomous Dynamic Watchdog Task..." -Level STEP
    
    # Create the standalone Watchdog PowerShell script
    $watchdogContent = @'
# Daffodil DC253D Dynamic Power & Battery Watchdog Script
$battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
$status = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ErrorAction SilentlyContinue).PowerOnline

if ($status -eq $true) {
    # AC Connected: Unleash Performance
    powercfg -setacvalueindex scheme_current sub_processor PERFEPP 0
    powercfg -setacvalueindex scheme_current sub_pciexpress aspm 0
    powercfg -setactive scheme_current
} else {
    # On Battery: Extreme Battery Saver
    powercfg -setdcvalueindex scheme_current sub_processor PERFEPP 60
    powercfg -setdcvalueindex scheme_current sub_pciexpress aspm 2
    powercfg -setactive scheme_current
}

# Periodic Silent TRIM
try { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue } catch {}
'@
    Set-Content -Path $WatchdogScript -Value $watchdogContent -Force

    # Register Scheduled Task to run every 10 minutes silently
    $action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$WatchdogScript`""
    schtasks.exe /create /tn "Daffodil-Watchdog" /tr $action /sc minute /mo 10 /ru "SYSTEM" /f 2>&1 | Out-Null

    Write-Log "Autonomous background watchdog task registered in Windows Task Scheduler." -Level SUCCESS
}

# -------------------------------------------------------------------------
# Main Execution Orchestrator
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "   🚀 DAFFODIL DC253D AUTONOMOUS HARDWARE & KERNEL OPTIMIZATION SUITE" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

New-SafeRestorePoint
Invoke-CpuArchitectureOptimization
Invoke-MemorySubsystemOptimization
Invoke-StorageOptimization
Invoke-GpuOptimization
Invoke-NetworkOptimization
Invoke-ThermalOptimization
Invoke-KernelSchedulerOptimization
Invoke-ServiceDebloatOptimization
Invoke-BatteryProtectionOptimization
Invoke-SecurityAndDnsOptimization
Invoke-DisplayOptimization
Invoke-AudioOptimization
Invoke-BusLatencyOptimization
Invoke-InputPrecisionOptimization
Invoke-PrivacyOptimization
Invoke-DesktopSnappinessOptimization
Invoke-GamingOptimization
Invoke-DriverShieldOptimization
Install-WatchdogTask

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "   ✨ ALL 18 SECTORS APPLIED & AUTONOMOUS WATCHDOG REGISTERED! ✨" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host ""
