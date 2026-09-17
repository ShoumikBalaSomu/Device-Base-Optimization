# Device-Base-Optimization 🚀

A modular, multi-platform, and hardware-specific system analysis, repair, security hardening, and deep performance tuning repository.

Instead of generic, one-size-fits-all scripts, **Device-Base-Optimization** provides **custom-engineered profiles tailored to specific device models, hardware chipsets, and operating systems**, down to the CPU microcode, kernel scheduler, and network interface.

---

## 🧭 Supported Devices & Operating Systems Matrix

| Operating System | Manufacturer | Model / Platform | Optimization Depth | Profile & Documentation |
|---|---|---|---|---|
| **Windows 11 / 10** | **Lenovo** | **ThinkPad T490s (`20NYS64T00`)** | ⚡ **Ultra-Deep (10 Sectors)** | [**View ThinkPad T490s Profile**](devices/windows/lenovo-thinkpad-t490s/README.md) |
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
    │   │   ├── README.md                        # 10-Sector hardware guide & benchmarks
    │   │   └── Optimize-ThinkPad-T490s.ps1      # Kernel & hardware optimization engine
    │   └── universal/                           # Generic Windows fallback
    │       ├── README.md                        # Universal Windows guide
    │       └── Optimize-Windows-Universal.ps1   # Hardware-agnostic maintenance script
    ├── linux/                                   # Linux distributions and devices
    │   └── README.md                            # Roadmap & kernel sysctl architecture
    └── macos/                                   # Apple Mac systems
        └── README.md                            # Roadmap & macOS defaults architecture
```

---

## ⚡ Quick Launch by Device

### 1. Lenovo ThinkPad T490s (`20NYS64T00`)
Custom-tuned across 10 hardware and kernel sectors (SpeedShift EPP 0, 32GB RAM zero-compression, NVMe APST zero-sleep, TCP NoDelay, Win32PrioritySeparation 0x26, ThinkPad WMI BIOS thermal maxima, 75-80% battery threshold):
```powershell
# In elevated PowerShell (Run as Administrator):
cd "devices\windows\lenovo-thinkpad-t490s"
powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -All
```

#### Specialized ThinkPad Switches:
* **Read-Only Audit**: `powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -AnalyzeOnly`
* **Extreme Battery Mode (8–10+ Hours)**: `powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ExtremeBattery`
* **Travel Mode (Charge to 100%)**: `powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -ChargeToFull`
* **Interactive Console Menu**: `powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Interactive`
* **Rollback to Windows Defaults**: `powershell -ExecutionPolicy Bypass -File .\Optimize-ThinkPad-T490s.ps1 -Rollback`

---

### 2. Universal Windows 10/11 PC
Safe maintenance, DISM/SFC repair, junk purge, Cloudflare 1.1.1.3 DNS, and power tuning for any Windows PC:
```powershell
# In elevated PowerShell (Run as Administrator):
cd "devices\windows\universal"
powershell -ExecutionPolicy Bypass -File .\Optimize-Windows-Universal.ps1 -All
```

---

## ➕ Adding a New Device or Operating System

We encourage adding hardware profiles for more laptops, custom desktops, and operating systems!

1. Open [`docs/DEVICE_SPEC_TEMPLATE.md`](docs/DEVICE_SPEC_TEMPLATE.md) for probing commands and boilerplate.
2. Create your device directory under `devices/<os>/<manufacturer-model>/`.
3. Add a dedicated `README.md` and optimization script.
4. Update the [Compatibility Matrix](#-supported-devices--operating-systems-matrix) in this README.

---

## 🛡️ Safety, Rollback & Logging

* **Windows Restore Point**: Automated restore points (`Pre-ThinkPad-UltraDeep-Optimization`) are generated before applying system tweaks.
* **Full Reversibility**: The ThinkPad script includes a dedicated `-Rollback` switch to return Windows kernel, memory, network, and scheduler settings to stock defaults.
* **DNS Backup**: Original DNS settings are backed up to `C:\ProgramData\DeviceOptimization\dns_backup.json` and can be restored using `-RevertDNS`.
* **Execution Logs**: Complete logs are saved under `C:\ProgramData\DeviceOptimization\`.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **Shoumik Bala Somu**.
