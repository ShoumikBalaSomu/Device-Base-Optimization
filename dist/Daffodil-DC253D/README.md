# ⚡ Daffodil Computers Ltd. DC253D - Windows Optimization Profile

> **Target Hardware**: Daffodil Computers Ltd. DC253D (ODM: Emdoor IDL528)  
> **Platform BIOS**: AMI BM_BI_IDL528_175B_F (EC Revision 1.6)  
> **Processor**: 13th Gen Intel® Core™ i3-1315U (6 Cores / 8 Threads: 2 P-Cores + 4 E-Cores, up to 4.50 GHz Turbo, Raptor Lake-U)  
> **Graphics**: Intel® Raptor Lake-P UHD Graphics (1250 MHz Max Turbo, HAGS Mode 2)  
> **Memory**: 8.0 GiB DDR4-3200 MT/s Single Channel (Kimtigo)  
> **Storage**: TWSC TSC3AN512-F2T70S (512GB) / MAXIO MAP1202 DRAM-less NVMe Controller  
> **Audio**: Realtek ALC269 High Definition Audio Codec (MMCSS Priority 6, Zero Ducking)  
> **Camera**: Chicony USB2.0 FHD UVC WebCam (FrameServer Stabilized)  
> **Touchpad**: Synaptics Precision Touchpad over Intel Serial IO I2C (`ACPI\SYNA360`)  
> **Network**: Intel Wi-Fi 6 AX101 (CNVi) + Realtek RTL8168 PCIe Gigabit Ethernet  
> **Battery**: Dongguan Ganfeng Electronics 55.2Wh Li-ion Battery (80% Protection Ceiling)  
> **Operating System**: Microsoft Windows 11 Pro (64-bit)

---

## 🚀 Instant 1-Line Execution (Autonomous Run-Once)

Open PowerShell as Administrator and run:

```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/daffodil-dc253d/Optimize-Daffodil-DC253D.ps1 | iex
```

Or double-click `Run-Once.cmd` (auto-elevates to Administrator).

---

## 🛠️ Hardware Bug Fixes & Driver Restoration

1. **Synaptics Precision Touchpad (I2C Bus Restoration)**:
   - **Root Cause**: Missing Intel Serial IO I2C Host Controllers (`PCI\VEN_8086&DEV_51E8`, `DEV_51E9`) and GPIO (`ACPI\INTC1055`) prevented the I2C bus from enumerating the touchpad.
   - **Fix**: Automatically retrieves and installs official Intel Serial IO and Chipset drivers (`iaLPSS2_I2C_ADL` & `iaLPSS2_GPIO2_ADL`), bringing the Synaptics Precision Touchpad (`ACPI\SYNA360`) online with full multi-finger gesture support.
2. **Chicony FHD UVC Camera**:
   - **Root Cause**: Windows Camera Frame Server (`FrameServer`) inactive and Media Foundation platform mode incompatibility causing video timeouts/black screens.
   - **Fix**: Configured `EnableFrameServerMode = 0`, started `FrameServer` service on Automatic, granted capability consent in Privacy settings, and purged disconnected phantom camera devices.
3. **Realtek ALC269 Audio & Microphone**:
   - **Root Cause**: 80% communication ducking, default MMCSS thread priority leading to buffer crackles under CPU load.
   - **Fix**: Eradicated communication ducking (`UserDuckingPreference = 3`), elevated MMCSS Audio scheduling priority to 6 (High Scheduling, High SFIO), zeroed SystemResponsiveness, and calibrated studio format.

---

## 🔬 21-Sector Architecture Overview

| Sector | Target | Applied Optimization |
|---|---|---|
| **01. CPU SpeedShift** | Intel Core i3-1315U | SpeedShift EPP set to 0 on AC, 60 on Battery; unparks all 8 logical cores. |
| **02. Memory Subsystem** | 8GB DDR4-3200 | Locks Kernel Executive in physical RAM (`DisablePagingExecutive = 1`); preserves memory compression for 8GB single-channel stability. |
| **03. NVMe Storage** | MAXIO MAP1202 DRAM-less | Zero APST latency on AC; disables NTFS 8.3 & LastAccess flash wear; executes live ReTrim. |
| **04. GPU & DWM** | Intel UHD Raptor Lake | Hardware Accelerated GPU Scheduling (`HwSchMode = 2`); MenuShowDelay = 0; flushes DirectX shader cache. |
| **05. Network Stack** | Intel AX101 Wi-Fi + GbE | Nagle disabled (`TcpNoDelay = 1`); delayed ACKs eliminated (`TcpAckFrequency = 1`); BBR2 / CUBIC congestion control. |
| **06. OEM Thermals** | Platform Cooling | Enforces Active cooling policy on AC (`SYSCOOLPOL = 1`) and Passive on DC. |
| **07. Kernel Scheduler** | Windows Kernel | `Win32PrioritySeparation = 0x26` (3:1 foreground priority boost for maximum application responsiveness). |
| **08. Services & Debloat** | Background Daemons | Disables DiagTrack, RetailDemo, dmwappushservice; sets WerSvc to manual. |
| **09. Battery Protection** | Ganfeng 55.2Wh | Locks 80% charge threshold monitoring and Li-ion chemistry preservation. |
| **10. Security & DNS** | Network Stack | Cloudflare Family 1.1.1.3 Anti-Malware DNS; enforces Windows Defender Real-Time Protection. |
| **11. Display Quality** | 1080p FHD IPS Panel | Intel DPST adaptive contrast dimming disabled (FeatureTestControl 0x9240); locks ClearType Subpixel RGB font smoothing. |
| **12. High-Fidelity Audio** | Realtek ALC269 | Eliminates 80% communication ducking; sets MMCSS Audio priority to 6 (High Scheduling). |
| **13. Bus Latency** | PCIe & USB 3.2 | Disables PCIe ASPM on AC (Max on Battery); disables USB Selective Suspend on AC to prevent DAC disconnects. |
| **14. Input Precision** | Precision Touchpad | Enforces 1:1 linear pointer tracking; calibrated Precision Touchpad sensitivity (prevents palm locks); keyboard repeat delay 250ms. |
| **15. Privacy Hardening** | Windows Telemetry | Diagnostic data restricted to Basic (Level 1); advertising ID and timeline tracking purged; MiniDump crash control enforced. |
| **16. Desktop Snappiness** | Windows Shell | Window animation delay removed (`MinAnimate = 0`); Bing web search disabled in Start Menu for instant local search. |
| **17. Gaming & Throughput** | Windows QoS | Unlocks 100% QoS network bandwidth (`NonBestEffortLimit = 0`); disables background GameDVR capture. |
| **18. OEM Driver Shield** | Intel/Realtek Drivers | Prevents Windows Update from overwriting OEM drivers; enables MiniDump crash control. |
| **19. Webcam Optimization** | Chicony FHD WebCam | Hardware MFT GPU acceleration enabled; 50Hz power line anti-flicker frequency locked. |
| **20. OS Integrity & Latency** | Realtek Audio Bus | Audio bus power-gating latency zeroed (eliminates popping on stream start); stalled installer locks purged. |
| **21. Hardware Mitigations** | Raptor Lake-U Architecture | Fast Startup disabled to eliminate sleep desync; Windows Copilot/Recall/AI emulated hooks purged; Auto HDR & VRR disabled on 60Hz SDR panel. |

---

## 🤖 Autonomous Background Watchdog Task

The script registers a persistent background Scheduled Task (`Daffodil-Watchdog`) running silently under `SYSTEM` authority:
* **On AC**: Unleashes Maximum Performance profile (EPP 0, PCIe ASPM 0, full iGPU boost).
* **On Battery**: Activates Extreme Battery Saver (EPP 75, CPU base clock cap, PCIe ASPM 2, USB Sleep) targeting 8–10+ hours battery endurance.
* **Battery Chemistry Guard**: Alerts user with audio chime and notification when battery reaches 80% on AC to prevent Li-ion cell degradation.
* **Weekly TRIM**: Silently runs weekly NVMe SSD ReTrim on volume `C:`.

---

## 🔄 Rollback

To restore default system configuration at any time:

```powershell
.\Optimize-Daffodil-DC253D.ps1 -Rollback
```
