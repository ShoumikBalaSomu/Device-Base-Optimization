# ⚡ Daffodil Computers Ltd. DC253D - Linux Optimization Profile

> **Target Hardware**: Daffodil Computers Ltd. DC253D (ODM: Emdoor Digital Technology Co., Ltd / IDL528)  
> **Processor**: 13th Gen Intel® Core™ i3-1315U (6 Cores / 8 Threads: 2 P-Cores + 4 E-Cores, up to 4.50 GHz Turbo)  
> **Graphics**: Intel® Raptor Lake-P UHD Graphics (1250 MHz Max Turbo, QuickSync AV1/HEVC/VP9)  
> **Memory**: 8.0 GiB DDR4-3200 MT/s Single Channel (Expandable to Dual-Channel)  
> **Storage**: TWSC TSC3AN512-F2T70S (512GB) / MAXIO MAP1202 DRAM-less NVMe Controller  
> **Audio**: Realtek ALC269VC Analog Codec on Intel Raptor Lake cAVS (PipeWire 1.6.8 / WirePlumber)  
> **Network**: Intel Raptor Lake CNVi Wi-Fi 6 (`iwlwifi`) + Realtek RTL8168 PCIe Gigabit Ethernet (`r8169`)  
> **Operating System**: Fedora Linux 44 Workstation (Kernel 7.2.4 x86_64, GNOME 48 / Wayland)

---

## 🚀 Instant 1-Line Execution

Run this command directly in terminal (with automatic privilege elevation):

```bash
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/daffodil-dc253d/run-once.sh | sudo bash
```

Or clone and run locally:

```bash
git clone https://github.com/ShoumikBalaSomu/Device-Base-Optimization.git
cd Device-Base-Optimization/devices/linux/daffodil-dc253d
chmod +x run-once.sh optimize-daffodil-dc253d.sh daffodil-charge-mode.sh
sudo ./run-once.sh
```

---

## 🔋 Battery Health & Dual-Mode Charge Controller

Manage battery health modes using the built-in CLI tool:

```bash
# Set 80% Li-ion Lifespan Protection Mode (ideal for daily plugged-in use)
daffodil-charge-mode protect

# Set 100% Full Charge Mode (for travel and maximum off-grid runtime)
daffodil-charge-mode full

# Check current battery chemistry, health percentage, and charge mode
daffodil-charge-mode status
```

---

## 🛠️ 18-Sector Architecture Overview

| Sector | Hardware Target | Applied Optimization |
|---|---|---|
| **01. CPU SpeedShift** | Intel Core i3-1315U | SpeedShift EPP set to `performance` (0) on AC, EPB=0, unparks all 8 logical cores (2P + 4E). |
| **02. Memory Subsystem** | 8GB DDR4-3200 MT/s | `zram0` upgraded to `zstd` algorithm; `vm.swappiness = 10`; `vm.vfs_cache_pressure = 50`; `vm.max_map_count = 2147483642`. |
| **03. NVMe Storage** | MAXIO MAP1202 DRAM-less | Zero APST latency (`default_ps_max_latency_us=0`) on AC to prevent DRAM-less freezes; Btrfs mounted with `noatime,commit=60`; weekly TRIM enabled. |
| **04. GPU Acceleration** | Intel Raptor Lake UHD | Intel `i915` options `enable_dpst=0 enable_guc=2`; Mesa shader cache 4GB (`MESA_SHADER_CACHE_MAX_SIZE=4G`); Intel QuickSync VA-API enabled. |
| **05. Network Stack** | Intel CNVi Wi-Fi + RTL8168 | TCP BBR congestion control + FQ qdisc; low latency buffer scaling; Wi-Fi power save disabled on AC. |
| **06. OEM BIOS & Thermals** | Emdoor IDL528 Platform | DPTF platform profile performance locking; firmware ACPI bug logging suppressed with `loglevel=3`. |
| **07. Kernel Scheduler** | Linux PREEMPT_DYNAMIC | `sched_autogroup_enabled = 1` for instantaneous foreground app responsiveness; panic safety timeout 10s. |
| **08. Services & Debloat** | Fedora Systemd | Disabled `NetworkManager-wait-online.service` (**saves 7.1s boot time**); disabled `ModemManager` and `abrt-*`; systemd journal vacuumed and capped to 100MB. |
| **09. Battery Protection** | Dongguan Ganfeng 55.2Wh | Autonomous watchdog monitors state; provides `daffodil-charge-mode` CLI and desktop notification alerts when charge reaches 80% on AC. |
| **10. Security & DNS** | Network Stack | Cloudflare Family 1.1.1.3 DNS-over-TLS (DoT) with automatic fallback; Firewalld verified and active. |
| **11. Display Quality** | 1080p FHD IPS Panel | Intel DPST adaptive contrast dimming disabled (100% true blacks preserved); RGB subpixel antialiasing & slight hinting locked. |
| **12. High-Fidelity Audio** | Realtek ALC269VC Codec | PipeWire 48kHz / 512 quantum; WirePlumber zero ducking; WebRTC acoustic echo cancellation & noise suppression; ALSA power save 0 on AC; volume headroom boosted to 130%. |
| **13. Bus Latency** | PCIe & USB 3.2 | PCIe ASPM set to `performance` on AC; USB autosuspend disabled on AC; Intel UHD iGPU unlocked to full 1250 MHz turbo boost. |
| **14. Input Precision** | Synaptics Precision Touchpad | Flat 1:1 acceleration profile (zero mouse curve acceleration); tap-to-click enabled; keyboard repeat delay 250ms / interval 25ms. |
| **15. Privacy Hardening** | GNOME Desktop | GNOME technical problem auto-reporting and software usage telemetry disabled. |
| **16. Desktop Snappiness** | GNOME 48 Shell | Start menu external web search queries disabled for instantaneous local searches. |
| **17. Gaming & Throughput** | Mesa & Proton | GameMode integration; TCP BBR maximum throughput for low ping gaming and streaming. |
| **18. Driver Resilience** | Linux Kernel 7.2 | Kernel boot parameters embedded via grubby: `split_lock_mitigate=0 nowatchdog transparent_hugepage=madvise loglevel=3`. |

---

## 🔄 Factory Rollback

To safely restore factory defaults:

```bash
sudo ./restore-daffodil-dc253d.sh
```
