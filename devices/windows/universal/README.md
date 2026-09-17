# Universal Windows 10/11 Optimization Profile 💻

A cross-device, hardware-agnostic maintenance, repair, security hardening, and performance tuning suite designed to run safely on **any Windows 10 or Windows 11 PC** (desktop, laptop, or workstation).

---

## ⚡ 1-Click Quickstart

### 🚀 Option 1: Instant 1-Line PowerShell Command (Zero Download / Zero Git)
Copy and paste this single line into **PowerShell** (Standard or Administrator) and press Enter:
```powershell
irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/universal/Optimize-Windows-Universal.ps1 | iex
```
*(Prompts for UAC elevation if needed, runs DISM/SFC repair, security hardening, DNS, and power tuning automatically).*

### 💻 Option 2: From Local Git Clone
```powershell
powershell -ExecutionPolicy Bypass -File .\devices\windows\universal\Optimize-Windows-Universal.ps1 -All
```

---

## 🛠️ Features
* **DISM & SFC System Repair**: Fixes component store corruption and system integrity issues.
* **Smart Package Updates**: Automatically upgrades installed software via Winget.
* **Junk Purge**: Empties Recycle Bin and cleans temp directories.
* **Security Hardening**: Enforces Windows Defender real-time monitoring and enables firewall across all profiles.
* **Cloudflare 1.1.1.3 Family DNS**: Blocks malware and adult content across all active adapters.
* **Ultimate Performance Power Plan**: Unlocks and enables the low-latency power scheme.
* **SSD TRIM Enforcement**: Enables TRIM and runs volume ReTrim on Drive `C:`.
