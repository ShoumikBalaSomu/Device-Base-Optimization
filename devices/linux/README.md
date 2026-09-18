# Linux Device Optimization Roadmap 🐧

This directory contains hardware-specific and distribution-level optimization profiles for Linux machines (Ubuntu, Debian, Fedora, Arch, and specialized embedded devices).

---

## 🗺️ Planned Architecture & Features

### Core Linux Optimizations
1. **Kernel Sysctl & Network Latency**:
   - Enable TCP BBR Congestion Control (`net.ipv4.tcp_congestion_control = bbr`).
   - Increase network buffer sizes and TCP window scaling.
2. **CPU Governors & Thermal Management**:
   - `auto-cpufreq` integration for adaptive frequency scaling.
   - `TLP` configuration for ThinkPad battery thresholds and power savings.
3. **Storage & Filesystems**:
   - `systemd` periodic TRIM via `fstrim.timer`.
   - `noatime` mount option on SSDs to minimize write wear.
   - I/O scheduler tuning (`kyber` or `none` for NVMe).
4. **Security & DNS**:
   - Cloudflare 1.1.1.3 Family DNS via `systemd-resolved` with DNS-over-TLS (DoT).
   - `ufw` or `firewalld` basic hardening rules.

---

## 📂 Available Device Profiles
* [**`lenovo-thinkpad-t490s/`**](lenovo-thinkpad-t490s/README.md) ⚡ **100% Autonomous (18 Sectors)**: Lenovo ThinkPad T490s (`20NYS64T00`), Intel Core i7-8665U, 32GB RAM, Intel UHD 620, BBR, DYTC EC thermals, 75%–80% battery protection, systemd watchdog.

## 🗺️ Upcoming Device Profiles
* `generic-desktop/` (Debian/Ubuntu/Arch performance tuning).
* `raspberry-pi-5/` (ARM64 SBC performance and thermal optimizations).

To add a new Linux profile, refer to [`docs/DEVICE_SPEC_TEMPLATE.md`](../../docs/DEVICE_SPEC_TEMPLATE.md).
