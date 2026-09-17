# Device-Base-Optimization 🚀

A modular, multi-platform, and hardware-specific system analysis, repair, security hardening, and deep performance tuning repository.

Instead of generic, one-size-fits-all scripts, **Device-Base-Optimization** provides **custom-engineered profiles tailored to specific device models, hardware chipsets, and operating systems**, featuring **100% autonomous "Run-Once & Forget"** automation.

---

## 🧭 Supported Devices & Operating Systems Matrix

| Operating System | Manufacturer | Model / Platform | Optimization Depth | Profile & Documentation |
|---|---|---|---|---|
| **Windows 11 / 10** | **Lenovo** | **ThinkPad T490s (`20NYS64T00`)** | ⚡ **100% Autonomous (Run-Once & Forget)** | [**View ThinkPad T490s Profile**](devices/windows/lenovo-thinkpad-t490s/README.md) |
| **Windows 11 / 10** | Any OEM | Universal PC (Desktop / Laptop) | 🟢 **Standard (Maintenance & Repair)** | [**View Universal Windows Profile**](devices/windows/universal/README.md) |
| **Linux** | Any OEM | Ubuntu / Debian / Fedora / Arch | 🟡 *In Roadmap* | [**View Linux Roadmap**](devices/linux/README.md) |
| **macOS** | Apple | MacBook / Mac mini (Apple Silicon / Intel) | 🟡 *In Roadmap* | [**View macOS Roadmap**](devices/macos/README.md) |

---

## 📂 Repository Architecture

```text
Device-Base-Optimization/
├── README.md                                    # Central Multi-Device Hub & Compatibility Matrix
├── LICENSE                                      # MIT Open Source License
├── docs/
│   └── DEVICE_SPEC_TEMPLATE.md                  # Standard blueprint for contributing new device configs
└── devices/
    ├── windows/
    │   ├── lenovo-thinkpad-t490s/               # Custom Ultra-Deep ThinkPad T490s profile
    │   │   ├── README.md                        # 12-Sector hardware, display & audio guide & benchmarks
    │   │   ├── Run-Once.cmd                     # 1-Click Double-Clickable Auto-Elevating Launcher
    │   │   └── Optimize-ThinkPad-T490s.ps1      # Autonomous kernel, display, audio & hardware engine
    │   └── universal/                           # Generic Windows fallback
    │       ├── README.md                        # Universal Windows guide
    │       └── Optimize-Windows-Universal.ps1   # Hardware-agnostic maintenance script
    ├── linux/                                   # Linux distributions and devices
    │   └── README.md                            # Roadmap & kernel sysctl architecture
    └── macos/                                   # Apple Mac systems
        └── README.md                            # Roadmap & macOS defaults architecture
```

---

## ⚡ 1-Click Autonomous Quick Launch

### 1. Lenovo ThinkPad T490s (`20NYS64T00`) — Run Once & Forget!
You only need to run this once. It optimizes all 12 hardware, display, audio, and kernel sectors, locks the 75%-80% battery threshold, and installs a persistent background watchdog service that automatically switches between Maximum Performance on AC and Extreme Battery Saver on Battery.

#### Method 1: Double-Click (Zero CLI)
Double-click:
```text
devices\windows\lenovo-thinkpad-t490s\Run-Once.cmd
```

#### Method 2: From Elevated PowerShell
```powershell
cd "devices\windows\lenovo-thinkpad-t490s"
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1
```

---

### 2. Universal Windows 10/11 PC
Safe maintenance, DISM/SFC repair, junk purge, Cloudflare 1.1.1.3 DNS, and power tuning for any Windows PC:
```powershell
cd "devices\windows\universal"
powershell -ExecutionPolicy Bypass -File .\Optimize-Windows-Universal.ps1 -All
```

---

## 🤖 What the Autonomous Watchdog Does Forever:
* **75%–80% Battery Conservation**: Continuously ensures the charging threshold stays enforced to protect your battery chemistry, even across Windows or Lenovo Vantage updates.
* **AC / Battery Auto-Switching**:
  - *On Charger*: Engages Maximum Performance, unparks all 8 cores, and maximizes boost clocks.
  - *On Battery*: Engages Extreme Battery Saver by capping CPU clocks to the cool 1.9GHz base clock, doubling battery life to **8–10+ hours**.
* **Silent Weekly Maintenance**: Automatically executes SSD TRIM and clears temp caches weekly.

---

## ➕ Adding a New Device or Operating System

We encourage adding hardware profiles for more laptops, custom desktops, and operating systems!

1. Open [`docs/DEVICE_SPEC_TEMPLATE.md`](docs/DEVICE_SPEC_TEMPLATE.md) for probing commands and boilerplate.
2. Create your device directory under `devices/<os>/<manufacturer-model>/`.
3. Add a dedicated `README.md`, `Run-Once.cmd`, and optimization script.
4. Update the [Compatibility Matrix](#-supported-devices--operating-systems-matrix) in this README.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **Shoumik Bala Somu**.
