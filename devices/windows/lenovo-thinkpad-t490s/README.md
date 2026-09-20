# Lenovo ThinkPad T490s (`20NYS64T00`) Ultra-Deep Optimization Profile 🚀
### 100% Autonomous "Run-Once & Forget" Hardware & Battery Engine

A fully autonomous, zero-interaction performance optimization and battery protection engine custom-built for the **Lenovo ThinkPad T490s** running **Windows 11 (Build 26300+)**.

---

## ⚡ 1-Click "Run-Once & Forget" (Zero Interaction)

You only need to run this **once**. It automatically executes all 18 optimization sectors, locks your battery protection, and installs a persistent background watchdog service that maintains peak performance and battery health forever.

### 🚀 Option 1: Instant 1-Line PowerShell Command (Zero Download / Zero Git)
Copy and paste this single line into **PowerShell** (Standard or Administrator) and press Enter:
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/lenovo-thinkpad-t490s/Optimize-ThinkPad-T490s.ps1 | iex
```
*(Automatically prompts for UAC elevation if needed, counts down 5 seconds, and completes 100% autonomously!)*

### 📦 Option 2: Double-Click Launcher (Local File)
Simply double-click **`Run-Once.cmd`** in this folder:
```text
devices/windows/lenovo-thinkpad-t490s/Run-Once.cmd
```
*(Accept the standard Windows UAC administrator prompt, and everything runs automatically!)*

### 💻 Option 3: From Elevated PowerShell (Local Clone)
```powershell
cd "devices\windows\lenovo-thinkpad-t490s"
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1
```

---

## 🤖 The Autonomous Background Watchdog (`ThinkPad-Watchdog`)

Once executed, the script registers a silent, 0%-overhead Windows Scheduled Task (`ThinkPad-Autonomous-Optimization`) that runs in the background to maintain your machine permanently:

1. **Continuous Battery Preservation**:
   - Locks the **75% start / 80% stop** charging threshold in the Lenovo Power Management Driver (`PWRMGRV`).
   - Even if Windows Update, Lenovo Vantage, or a driver reset wipes your settings, the watchdog immediately re-enforces the threshold to protect your SMP 57Wh battery cells.
2. **Dynamic Power State Auto-Switching**:
   - **Plugged into AC Charger**: Automatically enables **Maximum Performance**, sets Intel SpeedShift EPP to `0`, unparks all 8 cores, and maximizes boost clocks.
   - **Unplugged (On Battery)**: Automatically sets Intel SpeedShift EPP to `60` with dynamic boost scaling, ensuring fluid 60fps responsiveness during active multitasking without 800MHz/1.9GHz lockup, while sipping minimal milliwatts at idle for **8–10+ hours** runtime.
3. **Silent Weekly Maintenance**:
   - Periodically triggers volume ReTrim on the Intel NVMe SSD.
   - Purges temp caches silently in the background every 7 days.

---

## 💻 Hardware Target Specifications

| Component | Target Hardware Specification | Detection / Interface |
|---|---|---|
| **Chassis / Model** | Lenovo ThinkPad T490s (Machine Type: `20NYS64T00`) | `(Get-CimInstance Win32_ComputerSystem).Model` |
| **Processor** | Intel(R) Core(TM) i7-8665U @ 1.90GHz (4C/8T, Whiskey Lake-U) | Intel SpeedShift (HWP) + WMI BIOS |
| **Graphics** | Intel(R) UHD Graphics 620 (QuickSync Hardware Decoder) | DirectX 12, WDDM 3.1, HAGS Mode 2 |
| **Display Panel** | **LG Display LP140WFA-SPD4** (14.0" FHD IPS 400-nit Low Power) | 100% sRGB non-touch; DPST disabled |
| **System Memory** | 32 GB DDR4 High-Capacity RAM | Zero-compression kernel memory engine |
| **Primary Storage** | INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD | PCIe 3.0 x4, APST latency zeroing on AC |
| **Secondary Storage** | Realtek PCIe Card Reader (32 GB SD slot) | SCSI block bus |
| **Wi-Fi Adapter** | Intel(R) Wireless-AC 9560 160MHz (802.11ac dual-band) | Throughput Booster + TCP NoDelay |
| **Ethernet Adapter** | Intel(R) Ethernet Connection (6) I219-LM Gigabit | NetAdapter RSS + Nagle Disable |
| **Battery** | SMP 02DL014 (ThinkPad 57Wh Internal Li-ion) | Lenovo Power Management Driver (`PWRMGRV`) |
| **UEFI Firmware** | Lenovo ThinkPad BIOS: `N2JETB0W (1.88)` | `root\wmi:Lenovo_BiosSetting` |
| **Operating System** | Microsoft Windows 11 Pro (Build 26300+) | Win32PrioritySeparation 0x26 + MMCSS High |

---

## 🔬 The 20 Ultra-Deep Optimization Sectors

1. **CPU SpeedShift EPP & Core Unparking**: SpeedShift EPP set to `0` on AC (instant clock scaling) and all 8 logical threads unparked on charger.
2. **32GB RAM Architecture**: Windows Memory Compression disabled (`Disable-MMAgent -MemoryCompression`), eliminating CPU decompression micro-stutter; kernel locked in physical RAM (`DisablePagingExecutive = 1`).
3. **Storage & NVMe Engine**: NVMe APST transition timeout set to `0` on AC; NTFS tunneling cache disabled; 8.3 filenames and `LastAccess` flash wear writes suppressed.
4. **GPU & DWM Snappiness Engine**: Hardware-Accelerated GPU Scheduling (HAGS Mode 2) enabled; `MenuShowDelay = 0` for instant desktop UI popups; DirectX shader cache purged.
5. **Low-Latency Network Stack**: Nagle's algorithm disabled (`TCPNoDelay = 1`); delayed ACKs disabled (`TcpAckFrequency = 1`) to eliminate 200ms packet buffering delay; BBR/Cubic TCP congestion provider.
6. **ThinkPad WMI BIOS Thermal & Thunderbolt Maxima**: EC configured for `AdaptiveThermalManagementAC,MaximizePerformance`, `ThunderboltSecurityLevel,UserAuthorization` (aligning with Windows 11 Kernel DMA Protection), and `PreBootForThunderboltDevice,Disable` (eliminating Event 9006 boot timeouts) committed directly to ThinkPad NVRAM.
7. **Kernel Scheduler Quantum**: `Win32PrioritySeparation = 38` (Hex `0x26`: short variable quanta with 3:1 foreground boost) for esports-grade input responsiveness.
8. **Services Demand-Start & Absent HW Debloat**: Non-essential and absent hardware services (`WbioSrvc`, `SCardSvr`, `MapsBroker`, `WerSvc`, `RetailDemo`, `DiagTrack`) converted to Manual (Demand-Start) to guarantee 0% idle CPU waste.
9. **Continuous Battery Preservation & High-Efficiency Mode**: Permanent 75%-80% threshold enforcement + dynamic EPP 60 energy-efficient battery scaling.
10. **Security & DNS Hardening**: Defender RTP, Firewall active on all profiles, and Cloudflare 1.1.1.3 Family DNS with automated backup.
11. **Display Quality & Visual Clarity Engine**: Disables Intel DPST (Display Power Saving Technology / Adaptive Contrast Dimming via `FeatureTestControl = 0x8210`) to eliminate washed-out dark scenes and sudden stepping; activates ClearType 2.0 RGB subpixel rendering (`Gamma 1400`) for pinpoint font sharpness.
12. **High-Fidelity Audio, Microphone Calibration & Dolby Engine**: Calibrates Microphone Array volume to 95% (+20dB gain) with dual-array beamforming and acoustic echo cancellation; fixes the stuck `LidClose: 0` Dolby DAX registry bug restoring full open-lid acoustic bandwidth; disables communication ducking (`UserDuckingPreference = 3`); elevates MMCSS Audio Task priority (`Priority 6, High Scheduling, SFIO High, Latency Sensitive`).
13. **Peripheral & Bus Latency Engine**: PCIe Link State Power Management (ASPM) set to `Off` on AC to eliminate NVMe SSD and Wi-Fi bus latency spikes; USB Selective Suspend disabled on AC to stop external drive/DAC disconnects; Intel UHD 620 iGPU set to Maximum Performance (1.15GHz boost).
14. **Input Precision & Responsiveness Engine**: Enforces 1:1 linear pointer tracking without artificial acceleration curves (`MouseSpeed = 0`, `MouseThreshold = 0`); minimizes keyboard repeat delay (`KeyboardDelay = 0`, `KeyboardSpeed = 31`); removes tap delays on Precision Touchpad.
15. **Privacy, Diagnostics & Telemetry Hardening**: Reduces Windows Diagnostic Data from Full (Level 3) to Basic (Level 1); disables Advertising ID and tailored diagnostics; purges Activity History feed; suppresses Windows Error Reporting UI freezes.
16. **Desktop Environment & Shell Snappiness**: Window minimize/maximize animation delay disabled (`MinAnimate = 0`); Bing search in Start Menu disabled for instantaneous local-only file/app search.
17. **Gaming & Network Bandwidth Engine**: Background GameDVR video capture disabled (saves GPU/RAM cycles); Windows Game Mode active; 20% QoS reserved network bandwidth unlocked (`NonBestEffortLimit = 0`); modern BBR2/Cubic TCP congestion provider active.
18. **ThinkPad OEM Driver Shield & Crash Safety**: Protects ThinkPad OEM drivers against generic Windows Update downgrades (`ExcludeWUDriversInQualityUpdate = 1`); enforces MiniDump crash control to prevent 32GB RAM from thrashing the SSD during system halts.
19. **Webcam Video Stream Fidelity & 50Hz Anti-Flicker**: Locks camera power line anti-flicker frequency to 50 Hz matching regional mains electricity (stopping horizontal strobing/banding and shutter speed drops); activates Media Foundation GPU Hardware MFT acceleration for zero-CPU video processing; tunes SunplusIT camera driver low-light compensation and eliminates snapshot freeze delays.
20. **OS Integrity, Component Store & Audio Bus Repair**: Verifies Windows DISM component store health; purges stalled MSI installer transaction locks; zeroes Intel SST and Realtek audio controller power-gating idle latency on AC to eliminate stream start/stop pops.

---

## 🚀 Advanced Command-Line Switches (Optional)

* **Read-Only System Audit**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -AnalyzeOnly
  ```
* **Travel Mode (Temporarily Charge to 100%)**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ChargeToFull
  ```
* **Interactive Menu**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Interactive
  ```
* **Rollback to Windows Stock Defaults**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Rollback
  ```
