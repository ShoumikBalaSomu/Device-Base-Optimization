# Device-Base-Optimization 🚀
### Custom Hardware Edition: Lenovo ThinkPad T490s (`20NYS64T00`)

A high-performance, hardware-engineered PowerShell analysis, repair, security hardening, and deep system optimization suite specifically tailored for the **Lenovo ThinkPad T490s**.

---

## 💻 Target Machine Specifications

| Component | Hardware Specification |
|---|---|
| **System Model** | Lenovo ThinkPad T490s (Machine Type: `20NYS64T00`, BIOS: `N2JETB0W`) |
| **Processor** | Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz (4 Cores, 8 Threads, Whiskey Lake-U) |
| **Graphics** | Intel(R) UHD Graphics 620 (Intel QuickSync Hardware Video Decoder) |
| **Memory** | 32 GB DDR4 High-Capacity System RAM |
| **Storage** | INTEL SSDPEKKF512G8L 512GB PCIe NVMe SSD + Realtek PCIE Card Reader |
| **Wireless** | Intel(R) Wireless-AC 9560 160MHz (802.11ac dual-band) |
| **Ethernet** | Intel(R) Ethernet Connection (6) I219-LM Gigabit |
| **Battery** | SMP 02DL014 (ThinkPad 57Wh Internal Li-ion Battery) |
| **Operating System** | Microsoft Windows 11 Pro (Build 26300) |

---

## ⚡ Quick Start

Open **PowerShell as Administrator** and run:

```powershell
cd "C:\Users\shoum\Device-Base-Optimization\scripts\windows"
```

### 1. Pre-Flight Hardware Health & Battery Wear Diagnostics (Safe / Read-Only)
Calculates exact battery wear percentage (from SMP 02DL014 57Wh design capacity), NVMe TRIM status, and ThinkPad BIOS configuration:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -AnalyzeOnly
```

### 2. Interactive Menu
Pick and choose specific optimization phases:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -Interactive
```

### 3. Run Full Unattended Optimization
Executes all 12 custom phases and creates a Windows System Restore Point:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -All
```

### 4. Travel Mode (Charge Battery to 100%)
Temporarily bypasses the 80% battery conservation threshold when you need maximum runtime on the road:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -ChargeToFull
```

### 5. Revert DNS
Restores original DNS server addresses:
```powershell
powershell -ExecutionPolicy Bypass -File .\Optimize-Device.ps1 -RevertDNS
```

---

## 🛠️ ThinkPad T490s Tailored Optimization Modules

1. **ThinkPad BIOS / UEFI WMI Tuning**:
   - Queries `root\wmi:Lenovo_BiosSetting` and sets `AdaptiveThermalManagementAC` to `MaximizePerformance` (unleashes full boost clock on charger) and `AdaptiveThermalManagementBattery` to `Balanced` (maintains cool thermals and fan silence on battery).
   - Disables `ChargeInBatteryMode` to prevent USB devices from draining the laptop battery when asleep.
   - Saves settings permanently to ThinkPad NVRAM via `Lenovo_SaveBiosSettings`.

2. **Hardware Battery Protection & Lifespan Conservation**:
   - Directly configures the Lenovo Power Management Driver (`PWRMGRV`) to start charging at **75%** and stop at **80%**.
   - Eliminates continuous high-voltage lithium stress while plugged into AC power.
   - Automatically calculates battery degradation wear level and outputs an HTML report.

3. **Intel Wireless-AC 9560 160MHz Network Tuning**:
   - Enables **Throughput Booster** for packet bursting on 802.11ac Wi-Fi.
   - Sets **Preferred Band** to `3. Prefer 5GHz band` to prevent connection degradation on crowded 2.4GHz channels.
   - Sets **MIMO Power Save Mode** to `No SMPS` on AC power to eliminate gaming and streaming latency spikes.

4. **Intel NVMe SSD (SSDPEKKF512G8L) NTFS & Write Lifecycle Tuning**:
   - Enforces TRIM (`DisableDeleteNotify = 0`) and triggers volume Re-Trim on Drive C:.
   - Disables legacy 8.3 short filename generation (`fsutil 8dot3name set C: 1`) for faster file operations.
   - Disables NTFS `LastAccess` timestamp updates (`fsutil behavior set disablelastaccess 1`) to eliminate millions of unnecessary NAND flash write cycles.

5. **32GB High-Capacity RAM & Memory Tuning**:
   - Sets `DisablePagingExecutive = 1` to lock the Windows kernel in physical 32GB RAM for zero paging latency.
   - Disables Windows network throttling (`NetworkThrottlingIndex = 0xFFFFFFFF`) and prioritizes foreground responsiveness (`SystemResponsiveness = 0`).

6. **Windows 11 Build 26300 Core Bug Repair**:
   - `DISM /Online /Cleanup-Image /RestoreHealth` (Component store health scan).
   - `sfc /scannow` (System File Checker).
   - `chkdsk C: /scan` (Filesystem scan).
   - Resets stalled Windows Update download queues and refreshes the Winsock/IP stack.

7. **Smart Auto-Updates**:
   - Updates all installed software packages via Winget (`winget upgrade --all`).
   - Initiates a background scan for pending Windows updates and drivers.

8. **Deep Temp & Junk Purge**:
   - Cleans `%TEMP%`, Windows Temp, Prefetch, Delivery Optimization, and crash dumps.
   - Empties Recycle Bin and cleans superseded component store packages (`DISM StartComponentCleanup`).

9. **Device Security Hardening & Cloudflare 1.1.1.3 Family DNS**:
   - Enforces Windows Defender Real-Time and Cloud Protection.
   - Enables Windows Firewall across all profiles.
   - Disables insecure legacy SMBv1 and LLMNR.
   - Applies **Cloudflare 1.1.1.3 Family DNS** (blocks malware and adult content) across all active adapters.

10. **Universal Media Codecs for Intel UHD 620 QuickSync**:
    - Installs K-Lite Codec Pack Standard configured for Intel QuickSync hardware decoding.
    - Installs Microsoft AV1, VP9, and HEIF image/video extensions.
    - Installs Visual C++ Redistributable (2005-2022 All-in-One x86 & x64) and .NET Desktop Runtime 8.

11. **ThinkPad Dual-Mode Power Management**:
    - Unlocks and activates the **Ultimate Performance** power plan on AC power with 0% PCIe latency and disabled USB selective suspend.
    - Preserves battery life on DC power with balanced CPU throttling.

---

## 📜 License

MIT License - Copyright (c) 2026 Shoumik Bala Somu.
