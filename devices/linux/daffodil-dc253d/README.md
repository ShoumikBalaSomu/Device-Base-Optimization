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
| **02. Memory Subsystem** | 8GB DDR4-3200 MT/s | `zram0` upgraded to `zstd` (7.5GB); `vm.swappiness = 10`; `vfs_cache_pressure = 50`; anti-stutter VM watermarks (`watermark_boost_factor = 0`, `watermark_scale_factor = 125`); `MALLOC_ARENA_MAX = 2` glibc fragmentation limiter; file descriptors scaled to 1M. |
| **03. NVMe Storage** | MAXIO MAP1202 DRAM-less | Zero APST latency (`default_ps_max_latency_us=0`) on AC; NVMe queue request CPU affinity locked to `2` for cache locality; Btrfs mounted with `noatime,commit=60`; weekly TRIM enabled. |
| **04. GPU Acceleration** | Intel Raptor Lake UHD | Intel `i915` options `enable_dpst=0 enable_guc=2`; Mesa shader cache 4GB (`MESA_SHADER_CACHE_MAX_SIZE=4G`, single-file cache); Intel QuickSync VA-API enabled. |
| **05. Network Stack** | Intel CNVi Wi-Fi + RTL8168 | TCP BBR congestion control + FQ qdisc; socket backlog scaled (16K/8K); Intel Hybrid IRQ affinity pinned to P-Cores (`CPU 0-3`) via `irqbalance`; Wi-Fi power save disabled on AC. |
| **06. OEM BIOS & Thermals** | Emdoor IDL528 Platform | DPTF platform profile performance locking; UEFI NVRAM boot order optimized (`efibootmgr`); firmware ACPI bug logging suppressed with `loglevel=3`. See [BIOS Recommendations](BIOS_RECOMMENDATIONS.md). |
| **07. Kernel Scheduler** | Linux PREEMPT_DYNAMIC | `sched_autogroup_enabled = 1` for instantaneous foreground app responsiveness; panic safety timeout 10s. |
| **08. Services & Debloat** | Fedora Systemd | Disabled `NetworkManager-wait-online.service` (**saves 7.1s boot time**); disabled `ModemManager` and `abrt-*`; systemd journal vacuumed and capped to 100MB. |
| **09. Battery Protection** | Dongguan Ganfeng 55.2Wh | Autonomous watchdog monitors state; provides `daffodil-charge-mode` CLI; silent direct EC hardware stop-charge and thermal protection when charge reaches 80% on AC (zero popups). |
| **10. Security & DNS** | Network Stack | Cloudflare Family 1.1.1.3 DNS-over-TLS (DoT) with automatic fallback; Firewalld verified and active. |
| **11. Display Quality** | 1080p FHD IPS Panel | Intel DPST adaptive contrast dimming disabled (100% true blacks preserved); RGB subpixel antialiasing & slight hinting locked. |
| **12. High-Fidelity Audio & Studio Mic** | Realtek ALC269VC Codec | PipeWire 48kHz / 512 quantum; WirePlumber zero ducking; Studio WebRTC acoustic echo cancellation, high-pass rumble filter, and voice AGC; ALSA analog mic boost calibrated (eliminates +60dB clipping/hiss); volume headroom boosted to 130%. |
| **13. Bus & Camera** | PCIe, USB & FHD WebCam | PCIe ASPM set to `performance` on AC; Chicony/SunplusIT FHD webcam (`04f2:b650`) hardware shielded against USB autosuspend (`power/control=on`, `power/autosuspend=-1`); `uvcvideo` tuned with `nodrop=1` and `quirks=128` (prevents frame drops during lighting changes & fixes bandwidth calculation); WirePlumber camera priority rule set; user added to `video,render` groups; Intel UHD iGPU unlocked to 1250 MHz. |
| **14. Input Precision** | Synaptics Precision Touchpad | Mouse 1:1 flat acceleration; Touchpad calibrated with adaptive acceleration, natural scrolling, and tap-to-click; Intel LPSS I2C controllers shielded against sleep freeze; keyboard repeat delay 250ms / interval 25ms. |
| **15. Privacy Hardening** | GNOME Desktop | GNOME technical problem auto-reporting and software usage telemetry disabled. |
| **16. Desktop Snappiness** | GNOME 48 Shell | Start menu external web search queries disabled for instantaneous local searches; Mutter Wayland `scale-monitor-framebuffer` active. |
| **17. Gaming & Throughput** | Mesa & Proton | GameMode integration; TCP BBR maximum throughput for low ping gaming and streaming. |
| **18. Driver Resilience** | Linux Kernel 7.2 | Kernel boot parameters embedded via grubby: `split_lock_mitigate=0 nowatchdog transparent_hugepage=madvise loglevel=3`. |

---

## 🖱️ Troubleshooting: Touchpad Frozen on Clean Fedora Install (Before Running Script)

If a user installs Fedora fresh on the Daffodil DC253D and the touchpad does not respond on the very first boot:

1. **Dual-Boot Windows Fast Startup Lock**:
   - Windows 11 Fast Startup (enabled by default from the factory) hibernates hardware states and locks the Intel Serial IO I2C host controller (`00:15.0`) into an ACPI `D3hot` sleep state. When Linux boots, the I2C bus fails to communicate with `SYNA3602:00`.
   - **Fix**: Boot into Windows, open **Command Prompt as Administrator** and run `powercfg /h off`, then power cycle the laptop.
2. **BIOS Fast Boot Skipping I2C Controller**:
   - In BIOS Setup (`F2` at boot) -> `Boot` tab -> set **Fast Boot** to **`Disabled`** (forces UEFI to enumerate and clock the I2C controller during POST).
3. **5-Second Lid Workaround (Suspend/Resume)**:
   - Close the laptop lid for 3–5 seconds until the power LED pulses (sleep state), then open it. The ACPI wake event forces the kernel to reset and re-bind `i2c_hid_acpi`.
4. **Stock Tap-to-Click is Disabled in Fedora**:
   - Stock Fedora GNOME leaves tap-to-click turned OFF out-of-the-box. Firmly press down until the trackpad mechanically clicks, or enable **Settings -> Mouse & Touchpad -> Tap to Click**.

---

## 🔄 Factory Rollback

To safely restore factory defaults:

```bash
sudo ./restore-daffodil-dc253d.sh
```
