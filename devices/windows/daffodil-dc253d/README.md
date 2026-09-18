# ⚡ Daffodil Computers Ltd. DC253D - Windows Optimization Profile

> **Target Hardware**: Daffodil Computers Ltd. DC253D (ODM: Emdoor Digital Technology Co., Ltd / IDL528)  
> **Processor**: 13th Gen Intel® Core™ i3-1315U (6 Cores / 8 Threads: 2 P-Cores + 4 E-Cores, up to 4.50 GHz Turbo)  
> **Graphics**: Intel® Raptor Lake-P UHD Graphics (1250 MHz Max Turbo, HAGS Mode 2)  
> **Memory**: 8.0 GiB DDR4-3200 MT/s Single Channel  
> **Storage**: TWSC TSC3AN512-F2T70S (512GB) / MAXIO MAP1202 DRAM-less NVMe Controller  
> **Audio**: Realtek ALC269VC High Definition Audio Codec  
> **Network**: Intel Raptor Lake CNVi Wi-Fi 6 + Realtek RTL8168 PCIe Gigabit Ethernet  
> **Operating System**: Microsoft Windows 11 / Windows 10 (64-bit)

---

## 🚀 Instant 1-Line Execution

Open PowerShell as Administrator and run:

```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/daffodil-dc253d/Optimize-Daffodil-DC253D.ps1 | iex
```

Or double-click `Run-Once.cmd` with built-in self-elevation.

---

## 🛠️ 18-Sector Architecture Overview

| Sector | Target | Applied Optimization |
|---|---|---|
| **01. CPU SpeedShift** | Intel Core i3-1315U | SpeedShift EPP set to 0 on AC, 60 on Battery; unparks all 8 logical cores. |
| **02. Memory Subsystem** | 8GB DDR4-3200 | Locks Kernel Executive in physical RAM (`DisablePagingExecutive = 1`); tunes filesystem cache. |
| **03. NVMe Storage** | MAXIO MAP1202 DRAM-less | Zero APST latency on AC; disables NTFS 8.3 & LastAccess flash wear; executes ReTrim. |
| **04. GPU & DWM** | Intel UHD Raptor Lake | Hardware Accelerated GPU Scheduling (`HwSchMode = 2`); MenuShowDelay = 0; flushes DirectX cache. |
| **05. Network Stack** | Intel CNVi Wi-Fi + GbE | Nagle disabled (`TcpNoDelay = 1`); delayed ACKs eliminated (`TcpAckFrequency = 1`); BBR2 / CTCP. |
| **06. OEM Thermals** | Platform DPTF | Enforces Active cooling on AC and Passive on DC. |
| **07. Kernel Scheduler** | Windows Kernel | `Win32PrioritySeparation = 0x26` (3:1 foreground priority boost for maximum responsiveness). |
| **08. Services & Debloat** | Background Daemons | Disables DiagTrack, RetailDemo, dmwappushservice; sets WerSvc to manual. |
| **09. Battery Protection** | Ganfeng 55.2Wh | Locks 80% charge threshold monitoring and power conservation. |
| **10. Security & DNS** | Network Stack | Cloudflare Family 1.1.1.3 Anti-Malware DNS; enforces Windows Defender Real-Time Protection. |
| **11. Display Quality** | 1080p FHD IPS Panel | Intel DPST adaptive contrast dimming disabled (FeatureTestControl 0x9240); locks ClearType RGB font smoothing. |
| **12. High-Fidelity Audio** | Realtek ALC269VC | Eliminates 80% communication ducking; sets MMCSS Audio priority to 6 (High Scheduling). |
| **13. Bus Latency** | PCIe & USB 3.2 | Disables PCIe ASPM on AC; disables USB Selective Suspend on AC to prevent DAC disconnects. |
| **14. Input Precision** | Precision Touchpad | Enforces 1:1 linear pointer tracking (zero mouse acceleration curves); sets keyboard repeat delay to 250ms. |
| **15. Privacy Hardening** | Windows Telemetry | Diagnostic data restricted to Basic (Level 1); advertising ID and timeline tracking purged. |
| **16. Desktop Snappiness** | Windows Shell | Window animation delay removed (`MinAnimate = 0`); Bing web search disabled in Start Menu. |
| **17. Gaming & Throughput** | Windows QoS | Unlocks 100% QoS network bandwidth (`NonBestEffortLimit = 0`); disables background GameDVR capture. |
| **18. OEM Driver Shield** | Intel/Realtek Drivers | Prevents Windows Update from overwriting OEM drivers; enables MiniDump crash control. |

---

## 🔄 Rollback

To restore default system configuration:

```powershell
.\Optimize-Daffodil-DC253D.ps1 -Rollback
```
