<div align="center">

# 🚀 Device-Base-Optimization
### *Precision Hardware-Aware System Optimization & Autonomous Battery Protection*

[![Latest Release](https://img.shields.io/github/v/release/ShoumikBalaSomu/Device-Base-Optimization?color=blue&label=Latest%20Release&logo=github)](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-informational?logo=windows)](devices/)
[![PowerShell: 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](devices/windows/)
[![Automation: 100% Autonomous](https://img.shields.io/badge/Automation-100%25%20Run--Once-success)](devices/windows/lenovo-thinkpad-t490s/)

<p align="center">
  <b>A modular, multi-platform ecosystem delivering deep, hardware-specific kernel tuning, latency zeroing, display/audio calibration, and permanent battery cell protection.</b>
</p>

[⚡ 1-Click Quickstart](#-1-click-quickstart-run-once--forget) • 
[🧭 Supported Devices](#-supported-devices--operating-systems-matrix) • 
[🔬 18-Sector Breakdown](#-the-18-ultra-deep-optimization-sectors) • 
[🤖 Background Watchdog](#-autonomous-background-watchdog) • 
[➕ Add Your Device](#-contributing-a-new-device-profile)

</div>

---

## 🌟 Why Device-Base-Optimization?

Generic "Windows Optimizer" scripts use a blunt, one-size-fits-all approach that frequently breaks drivers, creates audio crackling, or resets manufacturer power calibrations. 

**Device-Base-Optimization** is fundamentally different:
* 🎯 **Hardware-Aware Engineering**: Custom-crafted for specific motherboard chipsets, CPU architectures, NVMe controllers, and OEM power management drivers.
* ⚡ **100% Autonomous ("Run-Once & Forget")**: No periodic manual scripts. The engine auto-calibrates in seconds, locks hardware thresholds, and silently handles maintenance forever.
* 🔋 **Permanent Battery Chemistry Protection**: Locks 75%–80% charging thresholds directly in OEM hardware controllers (e.g. Lenovo Power Management), doubling battery lifespan.
* 🔄 **Dynamic AC/DC Profile Switching**: Automatically unleashes maximum boost and 0ms bus latency on AC, and throttles wattage for whisper-quiet 8–10+ hour runtime on battery.
* 🛡️ **Zero-Risk Architecture**: Automatically creates Windows System Restore snapshots prior to changes, with 1-click full rollback capability.

---

## 🧭 Supported Devices & Operating Systems Matrix

| Operating System | Manufacturer | Device Model & CPU | Optimization Depth | Guide & Scripts |
|:---:|:---:|:---:|:---:|:---:|
| **Linux (Fedora 44)** | **Daffodil** | **DC253D (Intel Core i3-1315U 6C/8T)** | ⚡ **100% Autonomous (18 Sectors)** | [**📖 View Daffodil DC253D Linux Guide**](devices/linux/daffodil-dc253d/README.md) |
| **Windows 11 / 10** | **Daffodil** | **DC253D (Intel Core i3-1315U 6C/8T)** | ⚡ **100% Autonomous (18 Sectors)** | [**📖 View Daffodil DC253D Windows Guide**](devices/windows/daffodil-dc253d/README.md) |
| **Windows 11 / 10** | **Lenovo** | **ThinkPad T490s (`20NYS64T00`)** | ⚡ **100% Autonomous (18 Sectors)** | [**📖 View ThinkPad T490s Windows Guide**](devices/windows/lenovo-thinkpad-t490s/README.md) |
| **Linux (Fedora / Debian)** | **Lenovo** | **ThinkPad T490s (`20NYS64T00`)** | ⚡ **100% Autonomous (18 Sectors)** | [**📖 View ThinkPad T490s Linux Guide**](devices/linux/lenovo-thinkpad-t490s/README.md) |
| **Windows 11 / 10** | Any OEM | Universal PC (Desktop / Laptop) | 🟢 **Standard (Maintenance & Repair)** | [**📖 View Universal Windows Guide**](devices/windows/universal/README.md) |
| **Linux** | Any OEM | Ubuntu / Debian / Fedora / Arch | 🟡 *In Roadmap (Sysctl / TLP)* | [**📖 View Linux Roadmap**](devices/linux/README.md) |
| **macOS** | Apple | MacBook / Mac mini (Apple Silicon / Intel) | 🟡 *In Roadmap (pmset / defaults)* | [**📖 View macOS Roadmap**](devices/macos/README.md) |

---

## 🏗️ Architecture & Execution Flow

```mermaid
flowchart TD
    Start(["Launch Run-Once.cmd"]) --> UAC["Self-Elevation (Administrator)"]
    UAC --> Restore["Create Windows System Restore Point"]
    Restore --> Audit["Hardware & Diagnostic Audit"]
    
    subgraph Execution ["18-Sector Optimization Engine"]
        Audit --> S1["CPU SpeedShift EPP 0 & Unparking"]
        S1 --> S2["32GB RAM Zero-Compression"]
        S2 --> S3["NVMe APST Latency Zeroing"]
        S3 --> S4["GPU HAGS & DWM Snappiness"]
        S4 --> S5["TCP NoDelay & Instant ACK"]
        S5 --> S6["ThinkPad BIOS Thermal Maxima"]
        S6 --> S7["Scheduler Quantum 0x26"]
        S7 --> S8["Services Demand-Start"]
        S8 --> S9["75-80% Battery Limit Locked"]
        S9 --> S10["Security & Cloudflare 1.1.1.3 DNS"]
        S10 --> S11["Display: Intel DPST Disabled"]
        S11 --> S12["Audio: Ducking Off & MMCSS Priority 6"]
        S12 --> S13["PCIe ASPM Off & USB Sleep Off"]
        S13 --> S14["1:1 Mouse & Fast Keyboard"]
        S14 --> S15["Privacy & Basic Telemetry"]
        S15 --> S16["Instant Window Animation"]
        S16 --> S17["GameDVR Off & 100% Bandwidth"]
        S17 --> S18["OEM Driver Protection & MiniDump"]
    end
    
    Execution --> Watchdog["Install Autonomous Watchdog Task"]
    Watchdog --> Complete(["Finished! Run-Once Complete"])
```

---

## ⚡ 1-Click Quickstart (Run-Once & Forget)

### 🚀 Instant 1-Line PowerShell Launch (Zero Download / Zero Git)

Just open **PowerShell** (Standard or Administrator) and paste the command for your machine:

#### 🐧 1. Daffodil DC253D — Linux (Fedora 44 / Ubuntu / Debian)
```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/daffodil-dc253d/run-once.sh | sudo bash
```
*(Takes Btrfs safety snapshot, sets SpeedShift EPP=0, unparks hybrid cores, zeros MAP1202 NVMe APST latency, tunes 8GB RAM zram zstd, enables QuickSync VA-API, locks 80% battery protection, and enables watchdog in ~10s).*

#### 💻 2. Daffodil DC253D — Windows 11 / 10
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/daffodil-dc253d/Optimize-Daffodil-DC253D.ps1 | iex
```
*(Auto-elevates, applies 18 sectors, enables HAGS mode 2, zeros NVMe APST, locks MMCSS priority 6, and installs watchdog in ~15s).*

#### 💻 3. Lenovo ThinkPad T490s (`20NYS64T00`) — Windows 11 / 10
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/lenovo-thinkpad-t490s/Optimize-ThinkPad-T490s.ps1 | iex
```
*(Auto-elevates, executes all 18 sectors, locks 75%-80% battery threshold, and installs the watchdog task in ~15s).*

#### 🐧 4. Lenovo ThinkPad T490s (`20NYS64T00`) — Linux (Fedora / Debian / Arch)
```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/lenovo-thinkpad-t490s/optimize-thinkpad-t490s.sh | sudo bash
```
*(Takes Btrfs safety snapshot, executes all 18 sectors, locks 75%-80% battery threshold, and enables systemd watchdog in ~10s).*

#### 🖥️ 5. Universal Windows 10 / 11 PC (Any OEM)
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/universal/Optimize-Windows-Universal.ps1 | iex
```
*(Auto-elevates, runs DISM/SFC repairs, cleans junk, enables Cloudflare 1.1.1.3 DNS, and tunes power).*

---

### 📦 Alternative Launch Methods

#### Method B: Double-Click Launcher (Zero CLI)
* **Daffodil DC253D Linux**: Download [**`Daffodil-DC253D-Linux-v1.3.0.zip`**](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/releases/download/v1.3.0/Daffodil-DC253D-Linux-v1.3.0.zip) and run `run-once.sh`.
* **Daffodil DC253D Windows**: Download [**`Daffodil-DC253D-Windows-v1.3.0.zip`**](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/releases/download/v1.3.0/Daffodil-DC253D-Windows-v1.3.0.zip) and double-click `Run-Once.cmd`.
* **ThinkPad T490s Windows**: Download [**`ThinkPad-T490s-Autonomous-v1.0.0.zip`**](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/releases/download/v1.0.0/ThinkPad-T490s-Autonomous-v1.0.0.zip) and double-click `Run-Once.cmd`.
* **ThinkPad T490s Linux**: Download [**`ThinkPad-T490s-Linux-Autonomous-v1.2.2.zip`**](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/releases/download/v1.2.2/ThinkPad-T490s-Linux-Autonomous-v1.2.2.zip) and run `run-once.sh`.

#### Method C: Via Git Repository
```bash
git clone https://github.com/ShoumikBalaSomu/Device-Base-Optimization.git
cd Device-Base-Optimization/devices/linux/daffodil-dc253d
chmod +x run-once.sh optimize-daffodil-dc253d.sh
sudo ./run-once.sh
```

---

## 🔬 The 18 Ultra-Deep Optimization Sectors

| Sector | Target Area | Technical Implementation & Hardware Impact |
|:---:|:---|:---|
| **01** | **CPU SpeedShift EPP** | SpeedShift EPP set to `0` on AC; all 8 logical cores unparked. |
| **02** | **32GB RAM Architecture** | Memory Compression disabled (`Disable-MMAgent`); Kernel locked in RAM (`DisablePagingExecutive = 1`). |
| **03** | **NVMe SSD Storage** | Intel NVMe APST sleep latency zeroed on AC; NTFS wear writes and tunneling cache disabled. |
| **04** | **GPU Scheduling & DWM** | Hardware-Accelerated GPU Scheduling (HAGS Mode 2); `MenuShowDelay = 0` for instant UI popups. |
| **05** | **Low-Latency Network** | Nagle's algorithm disabled (`TCPNoDelay = 1`); delayed ACKs eliminated (`TcpAckFrequency = 1`). |
| **06** | **ThinkPad BIOS Maxima** | WMI NVRAM thermal limits set to `MaximizePerformance` on AC. |
| **07** | **Kernel Scheduler** | `Win32PrioritySeparation = 38 (0x26)`: Short variable quanta with 3:1 foreground boost. |
| **08** | **Services & Debloat** | Non-essential services set to Manual; telemetry scheduled tasks purged. |
| **09** | **Battery Preservation** | Permanent 75% start / 80% stop threshold locked in Lenovo Power Manager (`PWRMGRV`). |
| **10** | **Security & DNS** | Cloudflare Family 1.1.1.3 DNS (blocks malware & adult content); Defender RTP active. |
| **11** | **Display Quality** | Intel DPST adaptive contrast dimming disabled (`FeatureTestControl = 0x8210`); ClearType 2.0 RGB subpixel rendering. |
| **12** | **High-Fidelity Audio** | Windows 80% communication audio ducking disabled (`UserDuckingPreference = 3`); MMCSS Audio Priority 6 real-time scheduling. |
| **13** | **Bus & Peripherals** | PCIe ASPM set to Off on AC (zero NVMe/Wi-Fi wake delay); USB Selective Suspend disabled on AC; Intel UHD 620 iGPU Maximum Performance (1.15GHz). |
| **14** | **Input Precision** | 1:1 linear pointer tracking (`MouseSpeed = 0`, no acceleration); fast keyboard repeat (250ms); Precision Touchpad zero tap latency. |
| **15** | **Privacy Hardening** | Diagnostic telemetry reduced to Basic (Level 1); Advertising ID and Activity History purged; Windows Error Reporting UI freezes eliminated. |
| **16** | **Desktop Snappiness** | Window minimize/maximize animation delay disabled (`MinAnimate = 0`); Start Menu Bing search removed for instant local-only search. |
| **17** | **Gaming & Bandwidth** | Background GameDVR video recording disabled; Windows Game Mode active; 20% QoS reserved bandwidth unlocked (`NonBestEffortLimit = 0`); BBR2/Cubic TCP. |
| **18** | **Driver Shield & Crash** | ThinkPad OEM drivers protected against generic Windows Update downgrades; MiniDump crash safety enforced. |

---

## 🤖 Autonomous Background Watchdog

The background watchdog task (`ThinkPad-Autonomous-Optimization`) is registered in Windows Task Scheduler and executes silently:

```mermaid
stateDiagram-v2
    [*] --> AC_Check
    state AC_Check {
        direction LR
        CheckStatus --> Is_AC: Plugged In
        CheckStatus --> Is_DC: On Battery
    }
    Is_AC --> Maximum_Performance: EPP=0, ASPM=Off, USB=Active, GPU=Max Boost
    Is_DC --> Extreme_Battery: 1.9GHz Cap, ASPM=Max Savings, USB=Sleep, GPU=Saver (~10h Life)
    Maximum_Performance --> Battery_Guard: Check 75%-80% Threshold
    Extreme_Battery --> Battery_Guard: Check 75%-80% Threshold
    Battery_Guard --> Maintenance: Run Weekly TRIM & Temp Purge
```

---

## 📂 Repository Layout

```text
Device-Base-Optimization/
├── README.md                                    # Central Multi-Device Hub & Documentation
├── LICENSE                                      # MIT Open Source License
├── docs/
│   └── DEVICE_SPEC_TEMPLATE.md                  # Standard blueprint for contributing new devices
├── devices/
│   ├── windows/
│   │   ├── daffodil-dc253d/                     # Custom Daffodil DC253D profile (Intel i3-1315U)
│   │   │   ├── README.md                        # Windows 18-sector hardware & audio guide
│   │   │   ├── Run-Once.cmd                     # 1-Click Double-Clickable Auto-Elevating Launcher
│   │   │   └── Optimize-Daffodil-DC253D.ps1     # Autonomous Windows optimization engine
│   │   ├── lenovo-thinkpad-t490s/               # Custom Ultra-Deep ThinkPad T490s profile
│   │   │   ├── README.md                        # 18-Sector hardware, display & audio guide
│   │   │   ├── Run-Once.cmd                     # 1-Click Double-Clickable Auto-Elevating Launcher
│   │   │   └── Optimize-ThinkPad-T490s.ps1      # Autonomous kernel & hardware optimization engine
│   │   └── universal/                           # Generic Windows fallback
│   │       ├── README.md                        # Universal Windows guide
│   │       └── Optimize-Windows-Universal.ps1   # Hardware-agnostic maintenance script
│   ├── linux/                                   # Linux distributions and devices
│   │   ├── daffodil-dc253d/                     # Custom Daffodil DC253D profile (Fedora Linux 44)
│   │   │   ├── README.md                        # Linux 18-sector hardware & audio guide
│   │   │   ├── BIOS_RECOMMENDATIONS.md          # Hardware BIOS & firmware setup guide
│   │   │   ├── run-once.sh                      # 1-Click Auto-Elevating Launcher
│   │   │   ├── optimize-daffodil-dc253d.sh      # Autonomous kernel & hardware optimization engine
│   │   │   ├── restore-daffodil-dc253d.sh       # 1-Click Rollback Script
│   │   │   ├── daffodil-charge-mode.sh          # CLI Battery Health / Full charge switcher
│   │   │   └── daffodil-watchdog.sh             # Dynamic AC/Battery Watchdog & Battery Guard
│   │   ├── lenovo-thinkpad-t490s/               # Custom Ultra-Deep Linux ThinkPad T490s profile
│   │   │   ├── README.md                        # 18-Sector hardware, display & audio guide
│   │   │   ├── run-once.sh                      # 1-Click Auto-Elevating Launcher
│   │   │   ├── optimize-thinkpad-t490s.sh       # Autonomous kernel & hardware optimization engine
│   │   │   ├── restore-thinkpad-t490s.sh        # 1-Click Rollback Script
│   │   │   └── thinkpad-watchdog.sh             # Dynamic AC/Battery Watchdog & Battery Guard
│   │   └── README.md                            # Roadmap & kernel sysctl architecture
│   └── macos/                                   # Apple Mac systems
│       └── README.md                            # Roadmap & macOS defaults architecture
└── scripts/
    └── windows/
        └── Optimize-Device.ps1                  # Synchronized core engine script
```

---

## 🤖 Optimizing Any Device with Antigravity CLI

Want to optimize another computer (e.g. ASUS ROG, Dell XPS, HP Spectre, MacBook, or Linux rig) at this exact peak depth? We've engineered the **Master Optimization Prompt** designed specifically for **Antigravity CLI**:

1. Install and launch **Antigravity CLI** on your target device (`agy`).
2. Open [**`docs/MASTER_OPTIMIZATION_PROMPT.md`**](docs/MASTER_OPTIMIZATION_PROMPT.md).
3. Copy and paste the prompt into Antigravity CLI.
4. Antigravity CLI will autonomously probe the hardware, engineer the custom 18-sector suite, execute it live, lock battery protection, and push the new device profile to GitHub!

---

## ➕ Contributing a New Device Profile

We invite contributions for more laptop models, custom gaming rigs, and operating systems!

1. Read [`docs/DEVICE_SPEC_TEMPLATE.md`](docs/DEVICE_SPEC_TEMPLATE.md) for diagnostic probe commands and structure.
2. Fork the repository and create a new branch:
   ```bash
   git checkout -b profile/your-device-model
   ```
3. Create your device folder under `devices/<os>/<manufacturer-model>/` with:
   - `README.md` (Hardware specs, sector details)
   - `Run-Once.cmd` (1-click launcher)
   - `Optimize-<Device>.ps1` (Optimization script)
4. Add your device to the [Compatibility Matrix](#-supported-devices--operating-systems-matrix) in the root `README.md`.
5. Open a Pull Request!

---

## 📜 License & Acknowledgments

* Licensed under the **MIT License** — see [LICENSE](LICENSE) for details.
* Created and maintained by **[Shoumik Bala Somu](https://github.com/ShoumikBalaSomu)**.
