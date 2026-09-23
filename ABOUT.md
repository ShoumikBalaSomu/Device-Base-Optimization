# About Device-Base-Optimization ⚡

> **Precision Hardware-Aware System Optimization, Zero-Lag Latency Calibration & Autonomous Battery Protection**  
> *Engineered by **Shoumik Bala Somu** (`shoumik.bala@gmail.com`)*

---

## 🧭 Project Mission

Generic "PC Optimizer" and "Debloater" scripts treat modern laptops and desktops like black boxes. They aggressively disable essential Windows/Linux services, break printer and Bluetooth discovery, delete registry keys without understanding dependencies, and neglect hardware-specific power controllers. 

**Device-Base-Optimization** was created to challenge this paradigm. 

Instead of a blunt, destructive, one-size-fits-all approach, this project treats every hardware model as a unique silicon architecture. Every device profile is built on real hardware telemetry—probing CPU P/E-core topologies, NVMe APST microsecond latencies, GPU render standby states (RC6/FBC), PCIe ASPM interconnects, and OEM embedded controller (EC) registers.

---

## 👤 About the Creator

* **Author:** Shoumik Bala Somu
* **Email:** [`shoumik.bala@gmail.com`](mailto:shoumik.bala@gmail.com)
* **GitHub:** [@ShoumikBalaSomu](https://github.com/ShoumikBalaSomu)
* **Repository:** [ShoumikBalaSomu/Device-Base-Optimization](https://github.com/ShoumikBalaSomu/Device-Base-Optimization)
* **Web Portal:** [https://shoumikbalasomu.github.io/Device-Base-Optimization/](https://shoumikbalasomu.github.io/Device-Base-Optimization/)

Shoumik engineered this suite out of direct frustration with battery degradation, thermal throttling micro-stutters, and uncalibrated audio DAC click/pop artifacts on daily-driver machines (specifically the **Daffodil DC253D** featuring the 13th Gen Intel Core i3-1315U and the **Lenovo ThinkPad T490s**).

---

## 🔬 Core Engineering Pillars

```
                     ┌──────────────────────────────────────────────┐
                     │         DEVICE-BASE-OPTIMIZATION             │
                     └──────────────────────┬───────────────────────┘
                                            │
         ┌───────────────────────────┬──────┴───────────────────────────┐
         │                           │                                  │
         ▼                           ▼                                  ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│  Silicon-Aware   │       │  Autonomous Cell │       │   Zero-Latency   │
│  Hardware Tuning │       │    Protection    │       │     Acoustics    │
│  (Sectors 01-10) │       │  (Sectors 02/21) │       │  (Sectors 04/19) │
└──────────────────┘       └──────────────────┘       └──────────────────┘
```

### 1. Silicon-Aware Architecture (21 Sectors)
Every optimization parameter corresponds to a documented kernel driver or hardware register:
* **PCIe ASPM**: L1 sub-state negotiation without bus lockups.
* **Storage APST**: NVMe Autonomous Power State Transitions capped with exit latency guards.
* **Intel QuickSync / VA-API**: Hardware-accelerated VP9/AV1 decoding slashing CPU load from 65% to under 5%.
* **Panel Self-Refresh (PSR2)**: Reducing display refresh power draw during static viewports.

### 2. Autonomous Lithium-Ion Cell Preservation
Lithium-ion cells degrade exponentially when held at 100% state-of-charge under high ambient temperatures. The suite enforces an **80% maximum charging ceiling** via native ACPI, ThinkLMI BIOS, or embedded controller (EC) registers. When disconnected, full battery discharge is available without software limits.

### 3. Acoustic Fidelity & Latency Zeroing
Default operating system power management shuts down onboard audio codecs every 1000ms to save negligible microwatts, causing loud pops and audio drops when video or voice starts. This suite permanently sets `snd_hda_intel power_save=0` while running real-time neural DSP echo suppression (RNNoise).

### 4. Zero Regrets & 100% Reversibility
Every script comes paired with a dedicated restore mechanism (`restore-*.sh` / `Restore-*.ps1`). No core system components are permanently removed or corrupted.

---

## 📚 Complete Documentation Index

All technical guides, templates, and specifications in this repository:

| Document | Category | Scope / Focus |
| :--- | :--- | :--- |
| [**`README.md`**](README.md) | Central Portal | Full architecture overview, badges, quickstart, and telemetry tables |
| [**`ABOUT.md`**](ABOUT.md) | Project Overview | Mission statement, author bio, engineering pillars, and contact info |
| [**`devices/linux/daffodil-dc253d/README.md`**](devices/linux/daffodil-dc253d/README.md) | Device Guide | Daffodil DC253D (Core i3-1315U) Linux 21-Sector Suite |
| [**`devices/linux/daffodil-dc253d/BIOS_RECOMMENDATIONS.md`**](devices/linux/daffodil-dc253d/BIOS_RECOMMENDATIONS.md) | Firmware Guide | UEFI / BIOS setup for Daffodil DC253D (VMD, C-states, ASPM) |
| [**`devices/linux/lenovo-thinkpad-t490s/README.md`**](devices/linux/lenovo-thinkpad-t490s/README.md) | Device Guide | ThinkPad T490s Linux 21-Sector Suite (ThinkLMI & dual-thresholds) |
| [**`devices/linux/README.md`**](devices/linux/README.md) | Platform Guide | Linux architecture overview, distribution support & common scripts |
| [**`devices/windows/daffodil-dc253d/README.md`**](devices/windows/daffodil-dc253d/README.md) | Device Guide | Daffodil DC253D Windows 11/10 21-Sector Suite & driver fixes |
| [**`devices/windows/lenovo-thinkpad-t490s/README.md`**](devices/windows/lenovo-thinkpad-t490s/README.md) | Device Guide | ThinkPad T490s Windows 11/10 21-Sector Suite (WMI & DPTF) |
| [**`devices/windows/universal/README.md`**](devices/windows/universal/README.md) | Device Guide | Universal PC Windows maintenance, health checks & repair suite |
| [**`devices/macos/README.md`**](devices/macos/README.md) | Platform Roadmap | macOS power management (`pmset`), thermal profiles & roadmap |
| [**`dist/Daffodil-DC253D/README.md`**](dist/Daffodil-DC253D/README.md) | Dist Bundle | Standalone offline bundle for Daffodil DC253D |
| [**`dist/ThinkPad-T490s/README.md`**](dist/ThinkPad-T490s/README.md) | Dist Bundle | Standalone offline bundle for Lenovo ThinkPad T490s |
| [**`docs/DEVICE_SPEC_TEMPLATE.md`**](docs/DEVICE_SPEC_TEMPLATE.md) | Specification | Standardized hardware specification template for adding new devices |
| [**`docs/MASTER_OPTIMIZATION_PROMPT.md`**](docs/MASTER_OPTIMIZATION_PROMPT.md) | AI / CLI Prompt | Master prompt for Antigravity CLI and autonomous agent tuning |
| [**`.agents/rules/device-optimizer.md`**](.agents/rules/device-optimizer.md) | Developer Rules | Architectural invariants and coding standards for agents |

---

## 🛡️ License & Open Source

This project is licensed under the terms of the **MIT License**. You are free to inspect, modify, fork, and distribute it for personal and commercial hardware configurations.

*For feedback, device profile contributions, or bug reports, please open an issue on [GitHub](https://github.com/ShoumikBalaSomu/Device-Base-Optimization/issues) or contact **`shoumik.bala@gmail.com`**.*
