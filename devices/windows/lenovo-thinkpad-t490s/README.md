# Lenovo ThinkPad T490s (`20NYS64T00`) Ultra-Deep Hardware Optimization Profile 🚀

An engineered, kernel- and hardware-level performance optimization engine designed specifically for the **Lenovo ThinkPad T490s** running **Windows 11 (Build 26300+)**.

---

## 💻 Hardware Target Specifications

| Component | Target Hardware Specification | Detection / Interface |
|---|---|---|
| **Chassis / Model** | Lenovo ThinkPad T490s (Machine Type: `20NYS64T00`) | `(Get-CimInstance Win32_ComputerSystem).Model` |
| **Processor** | Intel(R) Core(TM) i7-8665U @ 1.90GHz (4C/8T, Whiskey Lake-U) | Intel SpeedShift (HWP) + WMI BIOS |
| **Graphics** | Intel(R) UHD Graphics 620 (QuickSync Hardware Decoder) | DirectX 12, WDDM 3.1, HAGS Mode 2 |
| **System Memory** | 32 GB DDR4 High-Capacity RAM | Zero-compression kernel memory engine |
| **Primary Storage** | INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD | PCIe 3.0 x4, APST latency zeroing on AC |
| **Secondary Storage** | Realtek PCIe Card Reader (32 GB SD slot) | SCSI block bus |
| **Wi-Fi Adapter** | Intel(R) Wireless-AC 9560 160MHz (802.11ac dual-band) | Throughput Booster + TCP NoDelay |
| **Ethernet Adapter** | Intel(R) Ethernet Connection (6) I219-LM Gigabit | NetAdapter RSS + Nagle Disable |
| **Battery** | SMP 02DL014 (ThinkPad 57Wh Internal Li-ion) | Lenovo Power Management Driver (`PWRMGRV`) |
| **UEFI Firmware** | Lenovo ThinkPad BIOS: `N2JETB0W (1.88)` | `root\wmi:Lenovo_BiosSetting` |
| **Operating System** | Microsoft Windows 11 Pro (Build 26300+) | Win32PrioritySeparation 0x26 + MMCSS High |

---

## ⚡ Quick Execution Guide

In an elevated **PowerShell (Run as Administrator)**:

```powershell
cd "devices\windows\lenovo-thinkpad-t490s"
```

### 1. Pre-Flight Sector Health & Battery Wear Audit (Safe / Read-Only)
Audits the current status of all 10 sectors (SpeedShift, Memory Compression, Win32PrioritySeparation, Nagle's algorithm, Battery health):
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -AnalyzeOnly
```

### 2. Run All 10 Ultra-Deep Sectors Unattended
Executes full hardware and kernel optimizations with an automated Windows System Restore Point:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -All
```

### 3. Extreme Battery Mode (Longest Travel Runtime)
Caps the CPU at its cool 1.9GHz base clock on battery (eliminating 25W Turbo spikes), extending runtime to **8–10+ hours**:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ExtremeBattery
```

### 4. Travel Mode (Temporarily Charge to 100%)
Bypasses the 80% conservation threshold when you need maximum battery capacity on the road:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ChargeToFull
```

### 5. Rollback to Windows Defaults
Restores default Windows values (`Win32PrioritySeparation = 2`, `MemoryCompression = True`, default TCP parameters):
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Rollback
```

---

## 🔬 Deep Breakdown of the 10 Optimization Sectors

### Sector 1: CPU Architecture, Intel SpeedShift EPP & Core Unparking
* **SpeedShift EPP (`PERFEPP`)**: Configured to **`0` on AC** (`36687f9e-e3a5-4dbf-b1dc-15eb381c6863`), forcing the Intel i7-8665U into instantaneous clock frequency scaling without ramping latency. Configured to `60` on DC for balanced efficiency.
* **Core Unparking (`CPMINCORES`)**: Set to **`100%` on AC**, unparking all 8 logical execution threads for zero-latency wakeups. Set to `50%` on battery.

### Sector 2: 32GB RAM Architecture & Zero-Compression Engine
* **Memory Compression Disabled**: `Disable-MMAgent -MemoryCompression` and `Disable-MMAgent -PageCombining`. On 32GB RAM with 21+ GB free, Windows memory compression consumes CPU cycles compressing unused pages. Disabling it frees CPU cycles and prevents micro-stutters.
* **Kernel Locked in Physical RAM**: `DisablePagingExecutive = 1` locks the Windows kernel and executive drivers in RAM, preventing paging to disk.

### Sector 3: Storage & Intel NVMe APST Latency Zeroing
* **Zero APST Sleep Transitions**: NVMe primary idle timeout set to `0` on AC power (`d634455d-5870-4d86-b0d1-172873ca7582`), preventing the Intel SSDPEKKF512G8L from entering low-power D3/L1.2 sleep states during heavy I/O bursts.
* **NTFS Tunneling Cache Disabled**: `MaximumTunnelEntries = 0` removes legacy file creation metadata cache lookup overhead.
* **Flash Wear Reduction**: Enforces TRIM, triggers volume ReTrim, disables legacy 8.3 filename generation, and disables NTFS `LastAccess` timestamp updates.

### Sector 4: GPU, DWM & Desktop Snappiness Engine
* **Hardware-Accelerated GPU Scheduling (HAGS)**: Enables `HwSchMode = 2` in `GraphicsDrivers` for offloading frame scheduling directly to Intel UHD 620 hardware.
* **Instant UI Popups**: Sets `MenuShowDelay = 0` and reduces hung application timeouts to 1000ms.
* **Shader Cache Purge**: Clears `%LOCALAPPDATA%\D3DSCache` to eliminate corrupted shader stutters.

### Sector 5: Low-Latency Network Stack (Nagle's Algorithm Disable)
* **Nagle's Algorithm Disabled (`TCPNoDelay = 1`)**: Eliminates packet buffering delay on Intel Wireless-AC 9560. Packets are transmitted immediately without waiting 200ms to fill a packet segment.
* **Immediate ACK (`TcpAckFrequency = 1`)**: Disables delayed ACKs, cutting interactive ping in gaming, remote desktop, SSH, and video conferencing.
* **TCP Congestion Provider**: Enforces `BBR` or `Cubic` pacing for higher throughput.
* **Throughput Booster & 5GHz Preference**: Forces 5GHz channel preference and enables Throughput Booster.

### Sector 6: ThinkPad WMI BIOS Thermal Maxima
* Interacts directly with `root\wmi:Lenovo_BiosSetting` to configure the Embedded Controller:
  - `AdaptiveThermalManagementAC` → `MaximizePerformance`
  - `AdaptiveThermalManagementBattery` → `Balanced`
  - `ChargeInBatteryMode` → `Disable`
* Commits changes permanently to ThinkPad NVRAM via `(Get-CimInstance root\wmi:Lenovo_SaveBiosSettings).SaveBiosSettings()`.

### Sector 7: Windows 11 Kernel Scheduler (Win32PrioritySeparation 0x26)
* **`Win32PrioritySeparation = 38` (Hex `0x26`)**: Configures the thread scheduler for short, variable quanta with a **3:1 foreground boost**. Gives active games, browsers, and IDEs top CPU priority over background processes.
* **MMCSS Games Task Elevation**: Sets `Priority = 6` (High), `GPU Priority = 8`, and `Scheduling Category = High` in Multimedia Class Scheduler Service.

### Sector 8: Services & Background Telemetry Debloat
* **Demand-Start (Manual) Conversion**: Converts non-essential services (`MapsBroker`, `WerSvc`, `RetailDemo`, `XblAuthManager`, `DiagTrack`) to Manual, ensuring 0% idle CPU usage while preserving full compatibility if launched.
* **Telemetry Purge**: Disables diagnostic scheduled tasks (`Microsoft Compatibility Appraiser`, `ProgramDataUpdater`, `Consolidator`, `UsbCeip`).

### Sector 9: Battery Preservation & Extreme Battery Mode
* **75%–80% Hardware Threshold**: Protects the SMP 02DL014 57Wh battery cells in the Lenovo Power Management Driver (`PWRMGRV`).
* **Extreme Battery Profile**: Disables Turbo Boost on battery (`bc5038f7-23e0-4960-96da-33abaf5935ec = 99`), capping clock speed to 1.9GHz base clock and extending battery runtime to 8–10+ hours.

### Sector 10: Security Hardening & Cloudflare 1.1.1.3 Family DNS
* Enforces Windows Defender Real-Time Protection and Cloud Reporting.
* Enables Windows Firewall across Domain, Private, and Public profiles.
* Disables vulnerable legacy SMBv1 and LLMNR.
* Applies Cloudflare 1.1.1.3 Family DNS with automated backup to `C:\ProgramData\DeviceOptimization\dns_backup.json`.

---

## 📜 Logging & Rollback
* **Restore Point**: Automated restore point named `Pre-ThinkPad-UltraDeep-Optimization` is taken before any modifications.
* **Log File**: `C:\ProgramData\DeviceOptimization\thinkpad_t490s_ultradeep.log`
* **Rollback Switch**: Run with `-Rollback` or menu option `[X]` to revert all registry and network settings to default Windows behavior.
