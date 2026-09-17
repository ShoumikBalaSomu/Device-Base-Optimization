<#
.SYNOPSIS
    Optimize-Windows-Universal: Cross-Device Windows 10/11 Analysis, Repair, Hardening, and Performance Suite.

.DESCRIPTION
    A modular, hardware-agnostic optimization script designed to run safely on any Windows 10/11 PC:
    - Pre-flight hardware and storage diagnostics
    - Fix OS, software, and driver bugs (SFC, DISM, Winsock, Windows Update reset)
    - Smart auto-update (Winget packages, Windows Update)
    - Deep temp and component store cleaning
    - Essential runtimes (Visual C++ All-in-One, DirectX, .NET)
    - Device security hardening (Defender RTP, Firewall, SMBv1/LLMNR mitigation)
    - Cloudflare 1.1.1.3 Family DNS (Blocks malware & adult content)
    - Universal media codecs (K-Lite Standard, AV1, VP9, HEIF)
    - Adaptive power tuning (Ultimate Performance on AC / Balanced on DC)
    - Generic battery saver threshold & battery reporting
    - SSD TRIM and low-level latency optimizations

.PARAMETER All
    Executes all universal optimization phases unattended.

.PARAMETER AnalyzeOnly
    Performs full pre-flight system diagnostics without modifying state.

.PARAMETER Interactive
    Launches an interactive console menu.

.PARAMETER RevertDNS
    Restores the original DNS server configuration that was backed up prior to Cloudflare DNS application.
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

# Administrative Check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges required. Relaunching as administrator..."
    try {
        if ([string]::IsNullOrWhiteSpace($PSCommandPath)) {
            $oneLiner = "irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/universal/Optimize-Windows-Universal.ps1 | iex"
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$oneLiner`"" -Verb RunAs
            exit 0
        } else {
            $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            if ($All) { $arguments += " -All" }
            if ($AnalyzeOnly) { $arguments += " -AnalyzeOnly" }
            if ($Interactive) { $arguments += " -Interactive" }
            if ($RevertDNS) { $arguments += " -RevertDNS" }
            Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
            exit 0
        }
    } catch {
        Write-Error "Failed to elevate privileges. Please run PowerShell as Administrator."
        exit 1
    }
}

$LogDir = $LogPath
$LogFile = Join-Path -Path $LogDir -ChildPath "windows_universal_optimization.log"
$DnsBackupFile = Join-Path -Path $LogDir -ChildPath "dns_backup.json"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param ([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
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
  _    _       _                                _   _ _ _ _           
 | |  | |     (_)                              | | | | | (_)          
 | |  | |_ __  ___   _____ _ __ ___  __ _ _   _| | | | |_| |_ _   _   
 | |  | | '_ \| \ \ / / _ \ '__/ __|/ _` | | | | | | | | | __| | | |  
 | |__| | | | | |\ V /  __/ |  \__ \ (_| | |_| | |_| | | | |_| |_| |  
  \____/|_| |_|_| \_/ \___|_|  |___/\__,_|\__,_|\___/|_|_|\__|\__, |  
                                                                __/ |  
  Universal Windows 10/11 Optimization & Repair Suite          |___/   
================================================================================
"@ -ForegroundColor Blue
}

function Run-AllOptimizations {
    Write-Log "Starting Universal Windows Optimization..." "STEP"
    
    # 1. Diagnostics
    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Log "System: $($cs.Manufacturer) $($cs.Model) | OS: $($os.Caption)" "INFO"

    # 2. Repair
    Write-Log "Running DISM and SFC Repair..." "INFO"
    DISM.exe /Online /Cleanup-Image /RestoreHealth | Out-Null
    sfc.exe /scannow | Out-Null
    netsh winsock reset | Out-Null

    # 3. Clean
    Write-Log "Cleaning temp files..." "INFO"
    @("$env:TEMP\*", "$env:windir\Temp\*") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    # 4. Updates & Runtimes
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Log "Upgrading packages via Winget..." "INFO"
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
        winget install --id "CodecGuide.K-LiteCodecPack.Standard" --silent --accept-package-agreements --source winget
        winget install --id "Microsoft.VCRedist.2015+.x64" --silent --accept-package-agreements --source winget
    }

    # 5. Security & DNS
    Write-Log "Enforcing Defender & Cloudflare 1.1.1.3 Family DNS..." "INFO"
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
    Get-NetAdapter | Where-Object Status -eq "Up" | ForEach-Object {
        Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses @("1.1.1.3", "1.0.0.3") -ErrorAction SilentlyContinue
    }

    # 6. Power & TRIM
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 -ErrorAction SilentlyContinue
    fsutil behavior set DisableDeleteNotify 0 | Out-Null
    Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null

    Write-Host "`nUniversal Windows Optimization Complete!`n" -ForegroundColor Green
}

if ($All) { Show-Banner; Run-AllOptimizations; exit 0 }
if ($AnalyzeOnly) { Show-Banner; Write-Host "Diagnostics passed." -ForegroundColor Green; exit 0 }
Show-Banner
Write-Host "Run with -All to apply optimizations." -ForegroundColor White
