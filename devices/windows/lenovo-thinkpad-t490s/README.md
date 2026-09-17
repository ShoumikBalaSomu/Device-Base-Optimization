# Lenovo ThinkPad T490s (`20NYS64T00`) Optimization Profile 🚀

A dedicated hardware analysis, bug repair, security hardening, and deep system tuning suite engineered specifically for the **Lenovo ThinkPad T490s**.

---

## 💻 Hardware Target Specifications

| Component | Hardware Specification | Detection Cmdlet |
|---|---|---|
| **Model & Chassis** | Lenovo ThinkPad T490s (Type `20NYS64T00`, BIOS: `N2JETB0W`) | `(Get-CimInstance Win32_ComputerSystem).Model` |
| **Processor** | Intel(R) Core(TM) i7-8665U @ 1.90GHz (4 Cores, 8 Threads, Whiskey Lake-U) | `Get-CimInstance Win32_Processor` |
| **Graphics** | Intel(R) UHD Graphics 620 (QuickSync Video Decoder) | `Get-CimInstance Win32_VideoController` |
| **Memory** | 32 GB DDR4 High-Capacity RAM | `(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory` |
| **Primary Storage** | INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD | `Get-Disk -Number 0` |
| **Secondary Storage** | Realtek PCIe Card Reader (32 GB SD slot) | `Get-Disk -Number 1` |
| **Wi-Fi Adapter** | Intel(R) Wireless-AC 9560 160MHz (802.11ac, up to 1.73 Gbps) | `Get-NetAdapter -Name "Wi-Fi"` |
| **Ethernet Adapter** | Intel(R) Ethernet Connection (6) I219-LM Gigabit | `Get-NetAdapter -Name "Ethernet"` |
| **Battery** | SMP 02DL014 (ThinkPad 57Wh Internal Li-ion Battery) | `Get-CimInstance Win32_Battery` |
| **Operating System** | Microsoft Windows 11 Pro (Build 26300+) | `Get-CimInstance Win32_OperatingSystem` |

---

## ⚡ Quick Execution Guide

In an elevated **PowerShell (Run as Administrator)**:

```powershell
# Navigate to this profile directory:
cd "C:\Users\shoum\Device-Base-Optimization\devices\windows\lenovo-thinkpad-t490s"
```

### 1. Hardware Diagnostics & Battery Wear Check (Safe / Read-Only)
Inspects the ThinkPad's battery wear level, NVMe TRIM state, Intel Wi-Fi parameters, and BIOS settings without modifying system state:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -AnalyzeOnly
```

### 2. Interactive Console Menu
Select individual modules:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Interactive
```

### 3. Full Unattended Optimization
Executes all 12 custom phases and takes an automated Windows System Restore Point:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -All
```

### 4. Travel Mode (Temporarily Charge to 100%)
Disables the 80% battery conservation threshold when you need maximum battery runtime for travel:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ChargeToFull
```

### 5. Revert DNS
Restores your original DNS servers backed up prior to applying Cloudflare Family DNS:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -RevertDNS
```

---

## 🛠️ Detailed Optimization Modules

### Phase 1: ThinkPad BIOS / UEFI WMI Thermal Management
* Queries `root\wmi:Lenovo_BiosSetting` to configure the ThinkPad's Embedded Controller:
  - `AdaptiveThermalManagementAC` → `MaximizePerformance` (unleashes maximum sustained boost clocks on charger).
  - `AdaptiveThermalManagementBattery` → `Balanced` (maintains cool thermals and fan silence on battery).
  - `ChargeInBatteryMode` → `Disable` (prevents external USB accessories from depleting laptop battery while asleep).
* Commits changes permanently to ThinkPad NVRAM via `(Get-CimInstance root\wmi:Lenovo_SaveBiosSettings).SaveBiosSettings()`.

### Phase 2: Hardware Battery Protection & Health Report
* Configures the Lenovo Power Management Driver (`PWRMGRV`) to start charging at **75%** and stop at **80%**.
* Eliminates continuous high-voltage chemical stress on the SMP 02DL014 57Wh battery cells when docked or plugged in.
* Evaluates real-time battery wear:
  $$\text{Wear Percentage} = \frac{\text{Design Capacity (57,020 mWh)} - \text{Full Capacity (46,460 mWh)}}{\text{Design Capacity (57,020 mWh)}} \times 100 \approx 18.5\%$$
* Generates an HTML battery health report at `C:\ProgramData\DeviceOptimization\thinkpad_t490s_battery_report.html`.

### Phase 3: Intel Wireless-AC 9560 160MHz Network Tuning
* `Throughput Booster` → `Enabled` (increases frame bursting on 802.11ac Wi-Fi).
* `Preferred Band` → `3. Prefer 5GHz band` (eliminates degradation on congested 2.4GHz bands).
* `MIMO Power Save Mode` → `No SMPS` on AC power (eliminates micro-stutters and latency spikes during gaming and conferencing).
* `Transmit Power` → Enforces `5. Highest`.

### Phase 4: Intel NVMe SSD (SSDPEKKF512G8L) Write Life Optimization
* Enforces TRIM explicitly (`fsutil behavior set DisableDeleteNotify 0`) and triggers volume ReTrim on Drive `C:`.
* Disables legacy 8.3 short filename generation (`fsutil 8dot3name set C: 1`) to eliminate NTFS directory lookup overhead.
* Disables NTFS `LastAccess` timestamp updates (`fsutil behavior set disablelastaccess 1`) to prevent continuous unnecessary NAND flash write cycles.

### Phase 5: 32GB RAM High-Capacity Memory Tuning
* Locks the Windows kernel into physical RAM (`DisablePagingExecutive = 1`) to eliminate paging latency.
* Disables network throttling during network activity (`NetworkThrottlingIndex = 0xFFFFFFFF`).
* Prioritizes foreground responsiveness (`SystemResponsiveness = 0`).
* Configures TCP Window Auto-Tuning to `normal`.

### Phase 6: Windows 11 Build 26300 Core Bug Repair
* Runs `DISM /Online /Cleanup-Image /RestoreHealth` for component store corruption repair.
* Runs `sfc /scannow` for protected system file verification.
* Checks filesystem integrity with `chkdsk C: /scan`.
* Resets stalled Windows Update download queues and refreshes Winsock & IP stack.
* Triggers Plug & Play device rescan (`pnputil /scan-devices`).

### Phase 7: Smart Auto-Updates
* Updates all installed packages via Winget (`winget upgrade --all --silent`).
* Triggers background Windows Update scan for pending OS and driver patches.

### Phase 8: Deep Temp & Component Store Purge
* Cleans User/Windows Temp, Prefetch, Delivery Optimization cache, and Windows Error Reporting dumps.
* Empties Recycle Bin and purges superseded component store packages (`DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase`).

### Phase 9: Security Hardening & Cloudflare 1.1.1.3 Family DNS
* Enforces Windows Defender Real-Time Protection and Cloud Reporting.
* Enables Windows Firewall across Domain, Private, and Public profiles.
* Disables vulnerable legacy SMBv1 protocol and LLMNR.
* Applies **Cloudflare 1.1.1.3 Family DNS** (malware and adult content protection) to Wi-Fi and Ethernet adapters with automated backup.

### Phase 10: Universal Media Codecs for Intel UHD 620 QuickSync
* Installs K-Lite Codec Pack Standard (LAV filters configured for Intel QuickSync hardware decoding).
* Installs Microsoft AV1, VP9, and HEIF extensions.
* Installs Visual C++ 2015–2022 All-in-One (x86/x64) and .NET Desktop Runtime 8.

### Phase 11: Dual-Mode Power Management
* Configures **Ultimate Performance** scheme on AC power with 0% PCIe latency and disabled USB selective suspend.
* Preserves 6–8+ hours battery runtime on DC power.

---

## 📜 Logging & Rollback
* **Restore Point**: An automated restore point named `Pre-ThinkPad-T490s-Optimization` is created before changes.
* **Log File**: `C:\ProgramData\DeviceOptimization\thinkpad_t490s_optimization.log`
* **DNS Backup**: `C:\ProgramData\DeviceOptimization\dns_backup.json`
