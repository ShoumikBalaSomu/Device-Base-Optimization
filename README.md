# Device-Base-Optimization 🚀

A comprehensive, modular, and enterprise-grade system analysis, bug-fixing, security hardening, and deep performance tuning repository designed for multiple platforms and devices.

Currently featured: **Windows 10 / 11 Deep Optimization & Repair Suite**.

---

## 📂 Repository Structure

```text
Device-Base-Optimization/
├── README.md                      # Documentation & Execution Guide
├── LICENSE                        # MIT License
└── scripts/
    └── windows/
        └── Optimize-Device.ps1    # Main Windows Analysis & Optimization Script
```
*(Additional operating systems and device profiles will be added under `scripts/<platform>/`)*.

---

## ⚡ Quick Start (Windows)

### Prerequisites
* Windows 10 (Build 19041+) or Windows 11 (All editions)
* Administrator privileges
* PowerShell 5.1 or PowerShell 7+

### 1. Clone or Download the Script
```powershell
# In an elevated PowerShell (Run as Administrator):
cd "C:\Users\shoum\Device-Base-Optimization\scripts\windows"
```

### 2. Run Options

#### Option A: Run Full System Diagnostics Only (Safe / Read-Only)
Inspects CPU, RAM, storage, SSD TRIM status, battery health, and network adapters without modifying system state:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -AnalyzeOnly
```

#### Option B: Interactive Menu
Choose individual optimization modules:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -Interactive
```

#### Option C: Run All Optimizations Unattended
Executes all 10 optimization phases and creates a Windows System Restore Point automatically:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -All
```

#### Option D: Revert DNS Settings
Restores original DNS servers backed up prior to applying Cloudflare DNS:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -RevertDNS
```

---

## 🛠️ Optimization Phases Breakdown

| Phase | Module | Description |
|---|---|---|
| **0** | **Pre-flight & Restore Point** | Gathers system inventory, creates a Windows System Restore Point (`Pre-Device-Optimization-Backup`), and backs up active DNS. |
| **1** | **Fix Bugs (OS / Software / Drivers)** | Runs `DISM /Online /Cleanup-Image /RestoreHealth`, `sfc /scannow`, `chkdsk C: /scan`, resets Windows Update services (`wuauserv`, `bits`, `cryptsvc`), resets Winsock/TCP stack, and triggers Plug & Play hardware enumeration (`pnputil /scan-devices`). |
| **2** | **Smart Auto-Update** | Automatically updates installed software packages via Windows Package Manager (`winget upgrade --all`) and initiates a background Windows Update scan. |
| **3** | **Clean Temp & Junk Files** | Purges User/System Temp, Prefetch, Delivery Optimization cache, Windows Error Reporting dumps, empties Recycle Bin, and cleans superseded component store packages (`DISM StartComponentCleanup`). |
| **4** | **Missing Runtimes & Driver Libraries** | Installs Visual C++ Redistributables (2005-2022 All-in-One x86 & x64), DirectX Web Runtime, and .NET Desktop Runtime via Winget. |
| **5** | **Device Security Hardening** | Enforces Windows Defender Real-Time Protection and Cloud Reporting, enables Windows Firewall on all profiles, disables vulnerable legacy SMBv1, disables LLMNR credential sniffing, and activates SmartScreen. |
| **6** | **Cloudflare Family DNS (1.1.1.3)** | Configures network adapters to Cloudflare 1.1.1.1 for Families (`1.1.1.3` / `1.0.0.3` for IPv4; `2606:4700:4700::1113` for IPv6) to automatically block known malware and adult content at the DNS layer. |
| **7** | **Universal Codec Support** | Installs K-Lite Codec Pack Standard, AV1 Video Extension, VP9 Video Extension, and HEIF Image Extensions so any media file plays smoothly. |
| **8** | **Deep Power Plan Optimization** | Unlocks the hidden **Ultimate Performance** scheme, sets CPU min state (5% to allow idle downclocking) and max state (100%), disables PCIe Link State Power Management on AC, and disables USB Selective Suspend. |
| **9** | **Battery Protection** | Configures automatic Battery Saver at 25%, detects OEM battery protection interfaces (Lenovo Conservation Mode, ASUS Battery Health Charging, Dell AC Mode, HP Battery Care), and generates a detailed HTML battery health report. |
| **10** | **Deep Low-Level Tweaks** | Enforces SSD TRIM (`fsutil behavior set DisableDeleteNotify 0`), runs volume ReTrim, disables network throttling index (`0xFFFFFFFF`), prioritizes multimedia/gaming responsiveness (`SystemResponsiveness = 0`), sets TCP Window Auto-Tuning to normal, and disables invasive diagnostic telemetry services and tasks. |

---

## 🛡️ Safety & Rollback Features

* **System Restore Point**: An automated restore point named `Pre-Device-Optimization-Backup` is taken before any changes are made.
* **DNS Backup & Revert**: Original DNS server addresses are stored in `C:\ProgramData\DeviceOptimization\dns_backup.json`. Run with `-RevertDNS` to restore them at any time.
* **Detailed Logging**: All actions and results are logged to `C:\ProgramData\DeviceOptimization\optimization.log`.
* **Battery Report**: For laptops, an HTML health report is generated at `C:\ProgramData\DeviceOptimization\battery-report.html`.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **Shoumik Bala Somu**.
