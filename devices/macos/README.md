# macOS Device Optimization Roadmap 🍎

This directory hosts system and hardware optimizations for Apple Mac devices (MacBook Pro, MacBook Air, Mac mini, Mac Studio, Mac Pro) across both Apple Silicon (M1/M2/M3/M4) and legacy Intel architectures.

---

## 🗺️ Planned Architecture & Features

### Core macOS Optimizations
1. **UI & Window Server Latency**:
   - Accelerate mission control and window animations via `defaults write`.
   - Speed up Finder rendering and quick look previews.
2. **Thermal & Energy Management**:
   - Background sleep and Power Nap optimizations for battery preservation.
   - Low Power Mode automatic switching scripts.
3. **Storage & Memory Management**:
   - APFS snapshot management and local Time Machine cache trimming.
   - RAM purge and swapfile memory pressure mitigation.
4. **Security & DNS**:
   - Cloudflare 1.1.1.3 Family DNS configuration with Encrypted DNS (DoH/DoT configuration profiles).
   - Packet filter (`pf`) firewall rules.

---

## 📂 Upcoming Device Profiles
* `apple-silicon-macbook/` (M-series MacBook Air & Pro battery and thermals).
* `intel-mac/` (Thermal throttling and fan curve management).

To contribute a new macOS profile, refer to [`docs/DEVICE_SPEC_TEMPLATE.md`](../../docs/DEVICE_SPEC_TEMPLATE.md).
