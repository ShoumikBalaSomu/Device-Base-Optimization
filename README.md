# 🚀 Device-Base-Optimization

> **Professional-grade OS optimization toolkit** for maximum performance, battery longevity, network speed, audio/visual excellence, and security — tailored per-device.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Supported Devices](#supported-devices)
- [Quick Start — Single-Line Commands](#quick-start--single-line-commands)
- [Feature Highlights](#feature-highlights)
- [Branch Structure](#branch-structure)
- [Common Optimizations](#common-optimizations)
- [Safety & Rollback](#safety--rollback)
- [License](#license)

---

## Overview

This repository provides **device-specific** and **common** optimization scripts for Windows 11 and Fedora 44 (Linux). Each supported device has its own branch containing full optimization suites, while the `main` branch provides:

1. **Quick single-line commands** to run all optimizations instantly.
2. **Common optimization modules** shared across all devices.
3. **Documentation** for every optimization applied.

---

## Supported Devices

| # | Device | Model | Processor | RAM | OS Targets |
|---|--------|-------|-----------|-----|------------|
| 1 | **Lenovo ThinkPad T490s** | T490s | Intel i7-8665U @ 1.90 GHz | 32 GB | Windows 11 / Fedora 44 |
| 2 | **DCL DC253D** | DC253D | 13th Gen Intel i3-1315U @ 1.20 GHz | 8 GB | Windows 11 / Fedora 44 |

---

## Quick Start — Single-Line Commands

### 🐧 Fedora 44 (Linux Terminal)

**Lenovo ThinkPad T490s:**
```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/fedora-thinkpad-t490s.sh | sudo bash
```

**DCL DC253D:**
```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/fedora-dcl-dc253d.sh | sudo bash
```

**Common Optimizations Only (Any Device):**
```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/fedora-common.sh | sudo bash
```

### 🪟 Windows 11 (PowerShell — Run as Administrator)

**Lenovo ThinkPad T490s:**
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-thinkpad-t490s.ps1 | iex
```

**DCL DC253D:**
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-dcl-dc253d.ps1 | iex
```

**Common Optimizations Only (Any Device):**
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/windows-common.ps1 | iex
```

---

## Feature Highlights

| Feature | Linux | Windows | Description |
|---------|:-----:|:-------:|-------------|
| ⚡ Max Performance | ✅ | ✅ | CPU governor, I/O scheduler, kernel tuning, process priority |
| 🔋 Battery Longevity | ✅ | ✅ | Charge thresholds (60-80%), TLP/powertop, adaptive power |
| 🌐 Network Optimization | ✅ | ✅ | TCP tuning, BBR congestion, DNS optimization, MTU config |
| 🖼️ Max Picture Quality | ✅ | ✅ | Intel GPU tuning, color profiles, refresh rate optimization |
| 🔊 Max Sound | ✅ | ✅ | PipeWire/PulseAudio tuning, Dolby Atmos config |
| 🔊 Above 100% Volume | ✅ | ❌ | PipeWire amplification up to 150% safely |
| 🛡️ CoreDNS Security | ✅ | ✅ | Block malware, adult content, ads via DNS filtering |
| 🎬 Dolby Vision + Atmos | ✅ | ✅ | HDR/Dolby Vision profiles, Atmos spatial audio |
| 🔌 Battery Protection | ✅ | ✅ | Charge limit technology, thermal management |
| 🧹 System Cleanup | ✅ | ✅ | Remove bloatware, disable telemetry, free resources |

---

## Branch Structure

```
main                          ← You are here (Quick commands + Common optimizations)
│
├── Lenovo-ThinkPad-T490s     ← Full optimization suite for ThinkPad T490s
│   ├── linux/                   (Fedora 44 scripts)
│   └── windows/                 (Windows 11 scripts)
│
└── DCL-DC253D                ← Full optimization suite for DCL DC253D
    ├── linux/                   (Fedora 44 scripts)
    └── windows/                 (Windows 11 scripts)
```

---

## Common Optimizations

The `common/` directory contains optimizations applicable to **all devices**:

| Module | File | Description |
|--------|------|-------------|
| DNS Security | `common/linux/dns-security.sh` | CoreDNS setup blocking malware & adult content |
| DNS Security | `common/windows/dns-security.ps1` | Windows DNS filtering configuration |
| Network Tuning | `common/linux/network-optimize.sh` | TCP BBR, buffer tuning, MTU optimization |
| Network Tuning | `common/windows/network-optimize.ps1` | Windows TCP/IP stack optimization |
| Sound Enhancement | `common/linux/sound-enhance.sh` | PipeWire above 100%, Dolby Atmos profiles |
| Sound Enhancement | `common/windows/sound-enhance.ps1` | Windows audio optimization & Dolby config |
| Display Quality | `common/linux/display-optimize.sh` | Intel GPU tuning, color management |
| Display Quality | `common/windows/display-optimize.ps1` | Windows display and HDR optimization |
| System Cleanup | `common/linux/system-cleanup.sh` | Remove unnecessary services, free resources |
| System Cleanup | `common/windows/system-cleanup.ps1` | Windows debloat, disable telemetry |

---

## Safety & Rollback

> ⚠️ **All scripts create automatic backups before making changes.**

- **Linux**: Backups saved to `/opt/device-optimization/backups/`
- **Windows**: Backups saved to `C:\DeviceOptimization\Backups\`
- **Registry**: Windows registry backups created before any modification
- **Config files**: Original config files backed up with `.bak` extension

To rollback:
```bash
# Linux
sudo /opt/device-optimization/rollback.sh

# Windows (PowerShell as Admin)
C:\DeviceOptimization\rollback.ps1
```

---

## License

MIT License — See [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Built with ❤️ for maximum device performance</strong><br>
  <em>By <a href="https://github.com/ShoumikBalaSomu">ShoumikBalaSomu</a></em>
</p>
