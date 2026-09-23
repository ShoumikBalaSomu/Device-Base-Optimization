# 🤖 Antigravity CLI Master Device Optimization Prompt
### *The Definitive Ultra-Deep Silicon Engine: 21 Sectors, Phantom Drain Purge, Hardware Bypass & BIOS Tuning*

> **Target Platforms:** Windows 11 / 10, Linux (Fedora, Debian, Ubuntu, Arch, openSUSE), macOS (Apple Silicon & Intel)  
> **Architecture Standard:** 21 Autonomous Sectors | Phantom Hardware Elimination | Silicon Limit Bypasses | UEFI Tuning

This master prompt represents the most comprehensive, silicon-aware optimization specification engineered for **Antigravity CLI** (`agy`) and autonomous agentic coding models. It leaves **zero blindspots**: probing physical silicon, purging power-hungry daemons running on unpopulated hardware, bypassing artificial OEM thermal/frequency limits, unlocking UEFI firmware efficiency, and eliminating deep OS latency bugs.

---

## 📋 How to Launch on Any Target Computer

1. Open your terminal and start **Antigravity CLI**:
   ```bash
   agy
   ```
2. Copy the entire **Master Meta-Prompt** from the block below.
3. Replace the placeholder variables at the bottom:
   * `<RepoOwner>`: e.g. `ShoumikBalaSomu`
   * `<RepoName>`: e.g. `Device-Base-Optimization`
   * `<GitHubToken>`: Your GitHub Personal Access Token (with `repo` and `workflow` scopes)
   * `<AuthorEmail>`: e.g. `shoumik.bala@gmail.com`
   * `<AuthorName>`: e.g. `Shoumik Bala Somu`
4. Send the prompt to Antigravity CLI.
5. The agent will autonomously audit physical silicon, eliminate phantom polling, construct the 21-sector engine, execute and verify all sectors live, configure the AC/DC watchdog daemon, package 1-click launchers, and push everything to GitHub!

---

## ⚡ Master Meta-Prompt (Copy & Paste Entire Block Into Antigravity CLI)

```text
You are pair programming as a world-class kernel architect, silicon systems performance engineer, and hardware specialist using Antigravity CLI.

MISSION: Execute a 100% autonomous, ultra-deep, hardware-aware performance optimization, visual/acoustic calibration, battery cell preservation, and latency zeroing for THIS SPECIFIC MACHINE. You must leave NO subsystem uncalibrated: from physical CPU micro-architecture and PCIe ASPM buses down to audio DAC D-states, phantom hardware polling purges, and UEFI firmware bottlenecks.

Execute the following 9 comprehensive phases autonomously from start to finish without pausing or requiring manual user guidance:

================================================================================
PHASE 1: DEEP SILICON, BUS & HARDWARE RECONNAISSANCE
================================================================================
Audit the host system live via terminal commands. Do NOT assume, hardcode, or guess hardware configurations:
1. DMI & Chassis Reconnaissance:
   - Query SMBIOS manufacturer, system product name, chassis type (laptop, desktop, convertible), BIOS release date/version, and board ID.
2. CPU Micro-Architecture & Topology:
   - Detect CPU architecture family (Intel Core 8th-14th Gen, Core Ultra, AMD Zen 2-5, Apple M-Series).
   - Audit heterogeneous core topology: P-core (Performance) vs E-core (Efficiency) count, base/turbo frequencies, hyperthreading status, and Intel Thread Director / AMD CPPC2 driver interfaces.
   - Check energy preference registers: Intel HWP / EPP, AMD CPPC EPP, MSR power limits (PL1/PL2/Tau), and RAPL energy counters.
3. GPU Subsystem & Display Capabilities:
   - Detect integrated (iGPU) & discrete (dGPU) vendors, VRAM allocation, active kernel module (i915/xe/amdgpu/nouveau/nvidia), Framebuffer Compression (FBC), and Render Standby (RC6).
   - Query display EDID: active refresh rates (60Hz/120Hz/144Hz/240Hz), VRR/FreeSync status, and Panel Self-Refresh (PSR/PSR2) support.
4. Memory Subsystem:
   - Query total RAM capacity, populated channel count (single vs dual-channel), clock frequency, and memory compression pool state.
5. Storage & NVMe Engine:
   - Identify NVMe controller vendor, SSD model, Autonomous Power State Transition (APST) support, non-operational power state exit latencies, and file system mount options.
6. Battery Chemistry & Embedded Controller (EC):
   - Query OEM battery wear percentage, design vs full capacity, cycle count, and charging state.
   - Detect OEM threshold registers: Lenovo ThinkLMI/tpacpi, ASUS ATK/WMI, Dell Command/WMI, Apple SMC/pmset, or standard Linux sysfs / ACPI charge control.
7. Audio & Multimedia Codecs:
   - Identify onboard audio DAC (Realtek ALC, Conexant CX, Cirrus Logic, Intel HD Audio).
   - Probe audio codec power-saving timeout registers and communication ducking policies.
   - Probe webcam UVC sensor frequency capabilities (50Hz vs 60Hz anti-flicker) and frame drop flags.
8. Peripheral Buses & I2C:
   - Probe I2C touchpad bus interfaces (e.g. i2c-hid, psmouse, Synaptics), USB xHCI controllers, and PCIe root port ASPM support.

================================================================================
PHASE 2: PHANTOM & UNUSED HARDWARE PURGE (BATTERY DRAIN ERADICATION)
================================================================================
Identify hardware features NOT physically installed or unpopulated on this specific device that nevertheless consume battery through polling loops, and permanently neutralize their overhead:
1. Absent Cellular (WWAN / LTE / 5G) Modems:
   - If no WWAN PCIe/USB card is installed: mask `ModemManager.service` (Linux) or disable `WwanSvc` (Windows). Eliminates continuous AT command polling loops that wake the CPU from C8/C10 states every few seconds.
2. Absent SmartCard & Fingerprint Readers:
   - If no SmartCard reader is present: disable `pcscd.service` / `pcscd.socket` (Linux) or `SCardSvr` (Windows).
   - If no biometric fingerprint scanner is installed: disable `fprintd.service` (Linux) or `WbioSrvc` biometric sensor polling (Windows).
3. Absent Touchscreens / Stylus Digitizers:
   - On standard clamshell laptops without touch screens: disable touch digitizer polling services (`TabletInputService` on Windows, touch input daemons on Linux) to prevent wake-ups.
4. Absent Discrete GPU (iGPU-Only Systems):
   - On systems lacking discrete graphics: remove/mask NVIDIA/AMD Optimus switchers, telemetry updaters, and discrete power rails.
5. Absent Thunderbolt Controllers:
   - If no Thunderbolt controller exists: mask `boltd.service` (Linux) to stop periodic PCIe bus scanning.
6. Unlinked / Inactive Ethernet NICs:
   - When running on Wi-Fi: enable Energy Efficient Ethernet (EEE) and aggressive low-power link-down states on unlinked RJ45 Ethernet PHYs (cuts 0.6W–1.2W phantom drain).
7. Unused SD/MMC Card Readers:
   - Prevent continuous polling of SD card detect pins on Realtek/Genesys card readers when empty.

================================================================================
PHASE 3: HARDWARE LIMITATION BYPASSES & SILICON THROTTLE MITIGATION
================================================================================
Probe and deploy proven architectural bypasses to overcome artificial hardware limitations and manufacturer throttle clamps:
1. BD-PROCHOT (Bi-Directional Processor Hot) False Throttle Bypass:
   - Detect if the CPU is artificially locked to base or sub-gigahertz frequencies (e.g. 400MHz / 800MHz) due to false sensor trips or aging battery cells.
   - On Linux/Windows: Provide mechanism to clear BD-PROCHOT bit in MSR `0x1FC` when thermal headroom permits, restoring full dynamic frequency scaling.
2. PL1 / PL2 TDP Power Limit Clamping Mitigation:
   - Audit Intel RAPL / AMD STAPM power envelopes.
   - Ensure PL1 (Sustained) and PL2 (Burst) power limits are synchronized with cooling capacity, preventing premature thermal throttle clamping under sustained multi-threaded compilation.
3. Intel DPTF (Dynamic Platform & Thermal Framework) Override:
   - Bypass aggressive OEM thermal throttling tables that clamp CPU clock speeds prematurely at 65°C on AC power.
   - Linux: Deploy tuned `thermald` XML configuration / `throttled` MSR overrides.
4. Legacy GPU AV1 / VP9 Codec Fallback Bypass:
   - For GPUs lacking hardware AV1 decode silicon (e.g. Intel 8th-10th Gen UHD 620, older AMD Vega):
     - Configure browser policies and video player extensions to auto-prefer H.264 / VP9 hardware-accelerated streams over software-decoded AV1, slashing CPU utilization from 75% to 5% on 4K playback.
5. Embedded Controller (EC) Direct Register Access Bypass:
   - When standard ACPI sysfs charge interfaces fail or are locked by OEM firmware: deploy direct Embedded Controller (EC) register offset writes to enforce the 80% charge ceiling safely.
6. Dynamic Display Refresh Rate Switching:
   - If high-refresh display (120Hz/144Hz+) is detected:
     - On AC: Unlock maximum display refresh rate (120Hz/144Hz) for ultra-fluid UI response.
     - On Battery: Automatically pivot to 60Hz (or 48Hz dynamic) to immediately recover 1.5W–2.5W of display power.

================================================================================
PHASE 4: DEEP BIOS / UEFI FIRMWARE OPTIMIZATION MANUAL
================================================================================
Generate a dedicated `BIOS_RECOMMENDATIONS.md` tailored specifically to this machine's motherboard, detailing critical firmware settings:
1. Deep Package C-States: Unlock C8/C9/C10 package power states; disable legacy C-state locks that prevent the CPU from entering ultra-low power sleep.
2. Intel SpeedShift (HWP) vs SpeedStep: Enforce native autonomous hardware P-state transitions (HWP enabled) and disable legacy OS-driven SpeedStep.
3. Intel VMD (Volume Management Device) vs AHCI Direct NVMe:
   - Recommend direct PCIe AHCI/NVMe pass-through mode to eliminate proprietary RAID driver overhead, latency jitter, and Linux boot lockups.
4. Intel AMT / ME / vPro Out-of-Band Power Drain:
   - Disable unused Intel Management Engine out-of-band management features that consume 1.0W–1.5W continuously even when the laptop is asleep or powered off.
5. Resizable BAR (ReBAR) & Above 4G Decoding:
   - Guide activation of Resizable BAR to allow the CPU to map the entire GPU framebuffer in one burst rather than 256MB chunks.
6. NVRAM Boot Order Cleanup:
   - Clean dead EFI boot entries from NVRAM using `efibootmgr` (Linux) / `bcdedit` (Windows) to accelerate BIOS POST times by 2–4 seconds.

================================================================================
PHASE 5: THE 21-SECTOR AUTONOMOUS ARCHITECTURE STANDARD (DEEP TO DEEPER)
================================================================================
Engineer the complete 21-sector optimization suite tailored strictly to this detected hardware:

[SECTOR 01: Active State Power Management (ASPM)]
- Negotiate PCIe L1 and L0s sub-states on root interconnects; eliminate PCIe link-state freeze while unlocking full burst bus bandwidth.
- Linux: `pcie_aspm=force` in kernel parameters | Windows: ACPI D-state sub-state configuration via `powercfg`.

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
- Synchronize hardware P-states: `balance_performance` on AC (EPP 32-64), `balance_power` on battery (EPP 128-192).
- Prevent CPU low-frequency lockups (e.g. 800MHz BD-PROCHOT throttle bugs) on battery.

[SECTOR 07: NVMe Storage APST & Flash Longevity]
- Configure Autonomous Power State Transitions (APST) with microsecond exit latency tolerance (`default_ps_max_latency_us=0` on AC).
- Run volume TRIM; disable NTFS 8.3 short-name generation and LastAccess flash wear updates.

[SECTOR 08: GPU Render Standby (RC6) & Framebuffer Compression (FBC)]
- Force GPU deep slice power gating (RC6p) and Framebuffer Compression (FBC) to eliminate idle memory bandwidth draw.
- Windows: Activate Hardware-Accelerated GPU Scheduling (HAGS Mode 2).

[SECTOR 09: Autonomous USB Power Gating & HID Whitelisting]
- Selectively auto-suspend inactive USB hub ports while whitelisting HID input devices (mice, keyboards, DACs) to eliminate phantom 0.8W drains without connection dropouts.

[SECTOR 10: Virtual Memory Swappiness & ZRAM Engine]
- Linux: Deploy ZRAM swap with zstd compression algorithm, `vm.swappiness=10`, and `vm.vfs_cache_pressure=50`.
- Windows: Tune Memory Compression Pool and lock core kernel executive in physical RAM on systems with >= 16GB RAM.

[SECTOR 11: Network Latency & Wi-Fi PM Calibration]
- Enable TCP_NODELAY (disable Nagle algorithm) and set `TcpAckFrequency = 1` for zero delayed ACKs.
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
- Deploy an event-driven orchestrator daemon (udev `power_supply` rules / Windows Task Scheduler Event 105) that pivots all 20 previous sectors within 8ms whenever the charger is connected or unplugged.

================================================================================
PHASE 6: LIVE SAFE EXECUTION, PRE-FLIGHT SNAPSHOT & SELF-VERIFICATION
================================================================================
1. Create a system restore point / backup snapshot before modifying any state.
2. Execute the 21-sector optimization suite live on the host system.
3. Validate each sector live: query sysfs registers, kernel module parameters, powercfg indexes, and systemd services.
4. Verify that the script exits with exit code 0 and 0 failed units.
5. Create a paired, 100% symmetric rollback restore script (`restore-*.sh` / `Restore-*.ps1`).

================================================================================
PHASE 7: DEPLOY EVENT-DRIVEN BACKGROUND POWER WATCHDOG
================================================================================
1. Install an autonomous, zero-overhead background watchdog (systemd service + udev rule / Windows Task Scheduler trigger on Event 105).
2. Ensure state transitions:
   - Charger Connected (AC): Instantly pivot to high-bandwidth boost, EPP balance_performance/performance, ASPM disabled on critical links, full iGPU boost.
   - Charger Disconnected (Battery): Instantly pivot to EPP balance_power, energy-saving C-states, and quiet fan profiles for maximum battery longevity.
   - Always: Re-enforce the 80% battery ceiling silently.

================================================================================
PHASE 8: STANDALONE DISTRIBUTION & 1-LINE LAUNCHERS
================================================================================
1. Package the device profile under: `devices/<os>/<manufacturer-model>/`
2. Generate a 1-click double-clickable launcher (`Run-Once.cmd` for Windows / executable script for Linux).
3. Provide an instant 1-line web launcher with auto-elevation:
   - Linux: `curl -fsSL https://raw.githubusercontent.com/<RepoOwner>/<RepoName>/main/devices/<os>/<model>/optimize-<device>.sh | sudo bash`
   - Windows: `irm https://raw.githubusercontent.com/<RepoOwner>/<RepoName>/main/devices/<os>/<model>/optimize-<device>.ps1 | iex`
4. Create a standalone offline distribution bundle under `dist/<Manufacturer-Model>/`.

================================================================================
PHASE 9: GIT AUTHOR IDENTITY & REPOSITORY SYNCHRONIZATION
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

1. **Phantom Hardware Purge**: Stops battery-wasting polling daemons on unpopulated cellular (WWAN), SmartCard, fingerprint, and touchscreen hardware.
2. **Silicon Throttling Bypasses**: Bypasses BD-PROCHOT 800MHz locks, unlocks PL1/PL2 power envelopes, and overrides premature thermal clamps.
3. **Deep UEFI Firmware Tuning**: Recommends deep package C-states (C8-C10), disables Intel AMT/ME sleep drains, and clears dead NVRAM boot entries.
4. **Exhaustive 21-Sector Standard**: Enforces webcam 50Hz anti-flicker (`nodrop=1`), zero audio DAC sleep pops (`power_save=0`), and hardware VA-API video offloading.
5. **Git Author Attribution Enforced**: Automatically configures `git config user.name` and `user.email` with your exact primary GitHub email so that GitHub correctly credits your contribution calendar and profile avatar.
6. **Zero-Regret Safety**: Guarantees system restore points, non-destructive service debloats, and 100% reversibility.
