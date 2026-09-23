# 🤖 Antigravity CLI Master Device Optimization Prompt
### *The Definitive Ultra-Deep 21-Sector Autonomous Optimization Engine for Any Silicon Architecture*

> **Target Environments:** Windows 11 / 10, Linux (Fedora, Debian, Ubuntu, Arch, openSUSE), macOS (Apple Silicon & Intel)  
> **Agent Standard:** 21 Autonomous Sectors | Zero-Lag Telemetry | Silicon-Aware Kernel Calibration

Use this master meta-prompt when launching **Antigravity CLI** (`agy`) on **ANY new computer**. It provides an exhaustive, multi-layered blueprint ensuring the autonomous AI coding agent misses **nothing** from firmware to kernel, driver to scheduler, and silicon to user interface.

---

## 📋 How to Launch on Any Machine

1. Install and launch **Antigravity CLI** on your target computer:
   ```bash
   agy
   ```
2. Copy the complete **Master Meta-Prompt** from the code block below.
3. Fill in or replace the placeholder variables at the bottom:
   * `<RepoOwner>`: e.g. `ShoumikBalaSomu`
   * `<RepoName>`: e.g. `Device-Base-Optimization`
   * `<GitHubToken>`: Your GitHub Personal Access Token (with `repo` scope)
   * `<AuthorEmail>`: e.g. `shoumik.bala@gmail.com`
   * `<AuthorName>`: e.g. `Shoumik Bala Somu`
4. Send the prompt to Antigravity CLI.
5. The agent will autonomously audit the silicon, construct the 21-sector suite, apply and verify optimizations live, install the dynamic AC/DC watchdog daemon, package 1-click standalone launchers, and push the verified profile to GitHub!

---

## ⚡ Master Meta-Prompt (Copy & Paste Entire Block Into Antigravity CLI)

```text
You are pair programming as an elite kernel architect, silicon systems performance engineer, and hardware specialist using Antigravity CLI.

MISSION: Perform an ultra-deep, 100% autonomous, hardware-aware performance optimization, visual/acoustic calibration, battery cell preservation, and latency zeroing for THIS SPECIFIC MACHINE. You must leave NO subsystem uncalibrated—from CPU micro-architecture and PCIe ASPM buses down to audio DAC D-states and webcam UVC frame pipelines.

You MUST execute the following 7 comprehensive phases autonomously from start to finish without pausing or requiring manual guidance:

================================================================================
PHASE 1: LIVE HARDWARE & SILICON RECONNAISSANCE (PROBE DEEP TO DEEPER)
================================================================================
Audit the host system live through terminal execution. Do NOT guess or hardcode specs:
1. DMI & Motherboard: Query SMBIOS manufacturer, system product name, chassis type, BIOS release date/version, and board ID.
2. CPU Micro-Architecture:
   - Detect architecture family (Intel Core 8th-14th Gen, Core Ultra, AMD Zen 2-5, Apple M-Series).
   - Audit core topology: P-core vs E-core count, base/turbo frequencies, hyperthreading status, and Intel Thread Director / AMD CPPC2 support.
   - Check energy preference registers: Intel HWP / EPP, AMD CPPC EPP, MSR power limits (PL1/PL2/Tau), and RAPL energy domains.
3. GPU Subsystem: Identify integrated (iGPU) & discrete (dGPU) vendors, VRAM allocation, driver module (i915/xe/amdgpu/nvidia), Framebuffer Compression (FBC), and Render Standby (RC6).
4. Memory Topology: Audit RAM capacity, channel count (single vs dual-channel), clock frequency, and memory compression pool state.
5. Storage & NVMe Engine: Identify NVMe controller vendor, SSD model, Autonomous Power State Transition (APST) support, non-operational power state exit latencies, and file system mount options.
6. Battery Chemistry & Embedded Controller (EC):
   - Query OEM battery wear percentage, design vs full capacity, cycle count, and charging state.
   - Detect OEM threshold registers: Lenovo ThinkLMI/tpacpi, ASUS ATK/WMI, Dell Command/WMI, Apple SMC/pmset, or standard Linux sysfs / ACPI charge control.
7. Audio & Multimedia Codecs:
   - Identify onboard audio DAC (Realtek ALC, Conexant CX, Cirrus Logic, Intel HD Audio).
   - Probe audio codec power-saving timeout registers and communication ducking policies.
   - Probe webcam UVC sensor frequency capabilities (50Hz vs 60Hz anti-flicker) and frame drop flags.
8. Peripheral Buses & I2C: Probe I2C touchpad bus interfaces (e.g. i2c-hid, psmouse, Synaptics), USB xHCI controllers, and PCIe root port ASPM support.

================================================================================
PHASE 2: THE 21-SECTOR AUTONOMOUS ARCHITECTURE STANDARD (EXHAUSTIVE DEPTH)
================================================================================
Engineer a dedicated optimization suite tailored strictly to this detected hardware across all 21 sectors:

[SECTOR 01: Active State Power Management (ASPM)]
- Negotiate PCIe L1 and L0s sub-states on root interconnects; eliminate PCIe link-state freeze while unlocking full burst bus bandwidth.
- Linux: pcie_aspm=force | Windows: ACPI D-state sub-state configuration via powercfg.

[SECTOR 02: Dynamic Battery Health Thresholding]
- Enforce permanent 75%–80% maximum charging ceiling directly in OEM ACPI/WMI/EC registers.
- Completely prevent Lithium-ion electrolyte dendrite crystallization and high-temperature cell swelling.
- Provide silent graceful fallbacks with zero intrusive user notification popups.

[SECTOR 03: Display Refresh & Panel Self-Refresh (PSR2)]
- Enable Intel/AMD Panel Self-Refresh (PSR/PSR2) to eliminate display bus draw during static viewports.
- Disable aggressive dynamic contrast dimming (Intel DPST / AMD Vari-Bright) to preserve true color accuracy and deep 100% blacks.

[SECTOR 04: Audio DSP & Zero-Lag Latency]
- Eliminate 80% communication audio ducking; set multimedia task scheduling to Priority 6 (High Scheduling).
- Linux: Configure PipeWire/PulseAudio with 48kHz sampling and low-latency 256-sample buffer.

[SECTOR 05: Thermal Management & Fan Profiles]
- Deploy Intel DPTF / thermald / throttled custom thermal profile curves.
- Stop thermal throttle spikes by initiating early, gentle, whisper-quiet fan ramps before silicon junction temperatures reach 85°C.

[SECTOR 06: CPU Governor & Energy Performance Bias (HWP / EPP)]
- Synchronize hardware P-states: balance_performance on AC (EPP 32-64), balance_power on battery (EPP 128-192).
- Prevent CPU low-frequency lockups (e.g. 800MHz BD-PROCHOT throttle bugs) on battery.

[SECTOR 07: NVMe Storage APST & Flash Longevity]
- Configure Autonomous Power State Transitions (APST) with microsecond exit latency tolerance (default_ps_max_latency_us=0 on AC).
- Run volume TRIM; disable NTFS 8.3 short-name generation and LastAccess flash wear updates.

[SECTOR 08: GPU Render Standby (RC6) & Framebuffer Compression (FBC)]
- Force GPU deep slice power gating (RC6p) and Framebuffer Compression (FBC) to eliminate idle memory bandwidth draw.
- Windows: Activate Hardware-Accelerated GPU Scheduling (HAGS Mode 2).

[SECTOR 09: Autonomous USB Power Gating & HID Whitelisting]
- Selectively auto-suspend inactive USB hub ports while whitelisting HID input devices (mice, keyboards, DACs) to eliminate phantom 0.8W drains without connection dropouts.

[SECTOR 10: Virtual Memory Swappiness & ZRAM Engine]
- Linux: Deploy ZRAM swap with zstd compression algorithm, vm.swappiness=10, and vm.vfs_cache_pressure=50.
- Windows: Tune Memory Compression Pool and lock core kernel executive in physical RAM on systems with >= 16GB RAM.

[SECTOR 11: Network Latency & Wi-Fi PM Calibration]
- Enable TCP_NODELAY (disable Nagle algorithm) and set TcpAckFrequency = 1 for zero delayed ACKs.
- Disable disruptive Wi-Fi dynamic power savings during active socket connections to eradicate conference jitter.

[SECTOR 12: Kernel Watchdog & NMI Interruption Elimination]
- Silence unnecessary hardware Non-Maskable Interrupt (NMI) watchdogs (`kernel.nmi_watchdog=0`), eliminating up to 250 unnecessary context switches per second.

[SECTOR 13: Bluetooth LE Radio Idle Suspension]
- Power down radio transceivers when no paired BLE peripherals are actively transmitting, recovering reserves without connection drops.

[SECTOR 14: Systemd Service & Telemetry Diagnostics Decoupling]
- Convert non-essential telemetry loggers, retail demo services, error reporting agents, and crash uploaders to Demand-Start or masked states to stop unprovoked disk wakes.

[SECTOR 15: I/O Scheduler Optimization (BFQ / Kyber)]
- Select multi-queue Kyber or BFQ schedulers for NVMe/SATA storage devices to guarantee fluid UI frame delivery under background compile/write workloads.

[SECTOR 16: S3 Deep Sleep & Modern Standby Backpack Shield]
- Enforce deep S3/s2idle suspend (`mem_sleep=deep`) and eliminate Windows Modern Standby / Linux S4 hibernation wake-lock battery drain inside backpacks.

[SECTOR 17: Hardware Keystroke Debounce & Trackpad Sleep Shield]
- Calibrate pointer acceleration curves; shield I2C touchpad controllers (`i2c-hid`) from sleep freezes upon cold boot.
- Set keyboard repeat delay to 250ms and zero tap-to-click latency.

[SECTOR 18: Webcam 50Hz Anti-Flicker & Nodrop Pipeline]
- Configure UVC camera powerline frequency filter to 50Hz (or 60Hz per region) and enforce `nodrop=1` frame preservation to eradicate video call flickering and stutter.

[SECTOR 19: Audio Power-Gating Zeroing & Click/Pop Filter]
- Permanently disable aggressive 1-second headphone amp power gating (`snd_hda_intel power_save=0` / Windows DevNode D0 State) to eliminate loud audio pops on playback start.

[SECTOR 20: Hardware Video Acceleration (VA-API / D3D12)]
- Hook Intel QuickSync / VA-API iHD / D3D12 hardware video decoders into browsers (Chrome, Firefox, Edge), slashing 4K 60FPS video CPU utilization from 65% to under 5%.

[SECTOR 21: Autonomous Dynamic AC/DC Power Orchestrator]
- Deploy an event-driven orchestrator daemon (udev power_supply rules / Windows Task Scheduler Event 105) that pivots all 20 previous sectors within 8ms whenever the charger is connected or unplugged.

================================================================================
PHASE 3: LIVE EXECUTION, PRE-FLIGHT SNAPSHOT & SELF-VERIFICATION
================================================================================
1. Create a system restore point / backup snapshot before modifying any state.
2. Execute the 21-sector optimization suite live on the host system.
3. Validate each sector live: query sysfs registers, kernel module parameters, powercfg indexes, and systemd services.
4. Verify that the script exits with exit code 0 and 0 failed units.
5. Create a paired, 100% symmetric rollback restore script (`restore-*.sh` / `Restore-*.ps1`).

================================================================================
PHASE 4: DEPLOY EVENT-DRIVEN BACKGROUND POWER WATCHDOG
================================================================================
1. Install an autonomous, zero-overhead background watchdog (systemd service + udev rule / Windows Task Scheduler trigger on Event 105).
2. Ensure state transitions:
   - Charger Connected (AC): Instantly pivot to high-bandwidth boost, EPP balance_performance/performance, ASPM disabled on critical links, full iGPU boost.
   - Charger Disconnected (Battery): Instantly pivot to EPP balance_power, energy-saving C-states, and quiet fan profiles for maximum battery longevity.
   - Always: Re-enforce the 80% battery ceiling silently.

================================================================================
PHASE 5: STANDALONE DISTRIBUTION & 1-LINE LAUNCHERS
================================================================================
1. Package the device profile under: `devices/<os>/<manufacturer-model>/`
2. Generate a 1-click double-clickable launcher (`Run-Once.cmd` for Windows / executable script for Linux).
3. Provide an instant 1-line web launcher with auto-elevation:
   - Linux: `curl -fsSL https://raw.githubusercontent.com/<RepoOwner>/<RepoName>/main/devices/<os>/<model>/optimize-<device>.sh | sudo bash`
   - Windows: `irm https://raw.githubusercontent.com/<RepoOwner>/<RepoName>/main/devices/<os>/<model>/optimize-<device>.ps1 | iex`
4. Create a standalone offline distribution bundle under `dist/<Manufacturer-Model>/`.

================================================================================
PHASE 6: REPOSITORY DOCUMENTATION & WEB PORTAL INTEGRATION
================================================================================
1. Create/update the device's technical `README.md` and `BIOS_RECOMMENDATIONS.md`.
2. Update the root `README.md` compatibility matrix, quickstart guide, and flowchart.
3. Update `ABOUT.md` and the interactive web portal (`docs/index.html`, `docs/assets/js/app.js`) to index the new device.

================================================================================
PHASE 7: GIT AUTHOR IDENTITY & REPOSITORY SYNCHRONIZATION
================================================================================
1. Set the git commit author identity before committing:
   git config user.name "<AuthorName>"
   git config user.email "<AuthorEmail>"
   git config --global user.name "<AuthorName>"
   git config --global user.email "<AuthorEmail>"
2. Commit all changes with standard conventional commit messages: `feat(<device>): implement 21-sector autonomous suite`.
3. Push cleanly to the remote repository using `<GitHubToken>`:
   git push origin main
4. Create and push a new release tag (e.g. `v1.x.x`).
```

---

## 🔧 Template Variables Reference

| Variable | Description | Example |
| :--- | :--- | :--- |
| `<RepoOwner>` | Your GitHub Username / Organization | `ShoumikBalaSomu` |
| `<RepoName>` | Your GitHub Repository Name | `Device-Base-Optimization` |
| `<GitHubToken>` | Personal Access Token (with `repo` and `workflow` scopes) | `ghp_xxxxxxxxxxxxxxxxxxxx` |
| `<AuthorEmail>` | Primary GitHub Account Email (for contribution tracking) | `shoumik.bala@gmail.com` |
| `<AuthorName>` | Full Name of the Author | `Shoumik Bala Somu` |

---

## 🔬 Why This Prompt Prevents Autonomous Agent Blindspots

1. **Exhaustive 21-Sector Standard**: Elevates older 18-sector guidelines to include webcam anti-flicker (`nodrop=1`), audio DAC pop zeroing (`power_save=0`), and hardware VA-API video offloading.
2. **Silicon-Specific Hardware Probing**: Forces the agent to probe P/E core layouts, NVMe APST microsecond latencies, and OEM EC battery thresholds before writing code.
3. **Mandatory Live Execution & Rollback**: Prohibits the agent from generating untested pseudo-scripts; mandates live execution, verification, and a paired 1:1 rollback script.
4. **Git Author Attribution Enforced**: Automatically configures `git config user.name` and `user.email` with your exact primary GitHub email so that GitHub correctly credits your contribution calendar and profile avatar.
5. **Zero-Regret Safety**: Guarantees system restore points, non-destructive service debloats, and 100% reversibility.
