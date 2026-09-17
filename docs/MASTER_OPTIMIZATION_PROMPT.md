# 🤖 Antigravity CLI Master Device Optimization Prompt
### *The Definitive 1-Prompt Blueprint for Peak Autonomous Optimization on ANY Device*

Use this master prompt when launching **Antigravity CLI** on **ANY new computer** (Windows laptop/desktop, Linux workstation, or macOS machine) to achieve 100% autonomous, hardware-specific, all-sector optimization in a single shot without requiring manual back-and-forth guidance.

---

## 📋 How to Use

1. Install and launch **Antigravity CLI** on your target machine:
   ```bash
   agy
   ```
2. Copy the prompt below, replace the placeholder values at the bottom (`<RepoOwner>`, `<RepoName>`, and `<GitHubToken>`), and send it to Antigravity CLI.
3. Antigravity will autonomously probe the device, build the custom 18-sector engine, execute it live, install the background watchdog, package 1-click launchers, and push everything to GitHub!

---

## ⚡ Master Meta-Prompt (Copy & Paste Into Antigravity CLI)

```text
You are pair programming as an elite systems kernel, hardware, and performance engineer using Antigravity CLI. 

TASK: Perform a 100% autonomous, ultra-deep, hardware-aware performance optimization, visual/acoustic calibration, battery cell protection, and security hardening for THIS SPECIFIC DEVICE.

Execute the following 6 phases autonomously from start to finish:

### PHASE 1: HARDWARE & KERNEL RECONNAISSANCE (Probed Live)
- Audit this machine live via terminal commands: detect CPU architecture/stepping, GPU vendor & VRAM, RAM capacity & dual-channel status, NVMe controller & APST sleep support, Wi-Fi/NIC chipset, OEM battery wear & hardware charge-threshold interfaces (e.g. Lenovo PWRMGRV, ASUS ATK, Dell Command, Apple smc/pmset, Linux TLP/sysfs), and OS build.

### PHASE 2: TAILORED ALL-SECTOR ARCHITECTURE (Custom to this Hardware)
Engineer an autonomous optimization suite specifically for this detected hardware covering ALL critical sectors:
1. CPU Architecture: SpeedShift EPP = 0 on AC, core unparking, frequency scaling.
2. Memory Subsystem: Disable memory compression on >=16GB RAM; lock kernel executive in physical RAM.
3. Storage & NVMe: Zero APST sleep latency on AC; run volume ReTrim; disable NTFS 8.3 & LastAccess flash wear writes.
4. GPU & DWM: Enable HAGS Mode 2; zero MenuShowDelay; flush DirectX shader caches.
5. Network Stack: TCPNoDelay = 1 (Nagle Off); TcpAckFrequency = 1 (No delayed ACKs); modern BBR2/Cubic congestion control.
6. OEM BIOS & Thermals: Configure WMI/NVRAM thermal policies for maximum performance on AC.
7. Kernel Scheduler: Win32PrioritySeparation 0x26 (3:1 foreground priority boost) / Linux sched_autogroup.
8. Services & Debloat: Convert non-essential services (telemetry, retail demo, error reporting) to Demand-Start.
9. Battery Chemistry Protection: Lock permanent 75%–80% hardware charge threshold in OEM drivers to prevent Li-ion cell degradation.
10. Security & DNS: Cloudflare Family 1.1.1.3 DNS (anti-malware & adult content filter) with automatic backup; enforce Real-Time Protection & Firewall.
11. Display Quality: Permanently disable adaptive contrast dimming (Intel DPST / AMD Vari-Bright) to preserve true 100% blacks; lock subpixel RGB font smoothing.
12. High-Fidelity Audio: Eliminate 80% communication audio ducking; elevate MMCSS multimedia audio task priority (Priority 6, High Scheduling) to eradicate buffer underruns and crackling.
13. Bus & Peripheral Latency: Disable PCIe ASPM link state sleep on AC; disable USB Selective Suspend on AC to stop external drive/DAC disconnects; unlock full iGPU boost clock.
14. Input Precision: Enforce 1:1 linear pointer tracking (zero acceleration curves); minimize keyboard repeat delay (250ms); zero touchpad tap latency.
15. Privacy & Telemetry: Reduce OS diagnostic data to Basic (Level 1); purge advertising ID & timeline tracking; eliminate crash dump UI freezes.
16. Desktop Snappiness: Disable window minimize/maximize animation delay (MinAnimate = 0); remove web search from Start Menu for instantaneous local-only search.
17. Gaming & Throughput: Disable background GameDVR screen recording; unlock 100% QoS network bandwidth (NonBestEffortLimit = 0).
18. OEM Driver Shield: Protect manufacturer OEM drivers from generic OS update downgrades; enforce MiniDump crash control.

### PHASE 3: LIVE SAFE EXECUTION & SELF-VERIFICATION
1. Create a system restore snapshot prior to modifying state.
2. Apply all optimizations LIVE on this machine.
3. Query and probe the modified registry keys, powercfg active indexes, and network stack live to verify 100% success.

### PHASE 4: AUTONOMOUS BACKGROUND WATCHDOG TASK
1. Install a silent, persistent background watchdog task (Windows Task Scheduler / systemd daemon / launchd plist).
2. The watchdog must automatically detect power states:
   - On AC: Unleash Maximum Performance (EPP 0, PCIe ASPM Off, USB Active, GPU Max Boost).
   - On Battery: Activate Extreme Battery Saver (CPU base clock cap, PCIe ASPM Max, USB Sleep) to guarantee 8–10+ hours runtime.
   - Always: Continuously re-enforce the 75%–80% battery charging threshold and run silent weekly TRIM.

### PHASE 5: DISTRIBUTION & INSTANT 1-LINE EXECUTION
1. Package the device profile under: devices/<os>/<manufacturer-model>/
2. Create a 1-click double-clickable launcher: Run-Once.cmd (with auto-elevation).
3. Implement an instant 1-line command with in-memory self-elevation fallback:
   irm https://raw.githubusercontent.com/<RepoOwner>/<RepoName>/main/devices/<os>/<model>/Optimize-<Device>.ps1 | iex

### PHASE 6: REPOSITORY SYNCHRONIZATION & GITHUB RELEASE
1. Update the root README.md compatibility matrix and architecture flowchart.
2. Push all code and device documentation to GitHub:
   Repo: <RepoOwner>/<RepoName>
   Token: <GitHubToken>
3. Publish a new GitHub Release with release notes and a downloadable 1-click .zip asset bundle.
```

---

## 🔧 Template Variables Reference

| Variable | Description | Example |
|---|---|---|
| `<RepoOwner>` | Your GitHub Username | `ShoumikBalaSomu` |
| `<RepoName>` | Your GitHub Repository Name | `Device-Base-Optimization` |
| `<GitHubToken>` | Personal Access Token (with `repo` scope) | `ghp_xxxxxxxxxxxxxxxxxxxx` |

---

## 🌟 Why This Prompt Generates Superior Results

1. **Explicit Multi-Sector Scope**: Eliminates omissions of display quality, audio fidelity, bus latency, and input precision.
2. **Mandatory Live Execution**: Forces the AI to apply and verify the optimizations immediately rather than simply generating inert text files.
3. **Hardware-Tied Watchdog**: Guarantees permanent battery cell health and dynamic AC/Battery switching forever.
4. **Instant 1-Liner Generation**: Automatically produces web-executable commands (`irm ... | iex`) with in-memory elevation fallbacks.
5. **Turnkey GitHub Release**: Finishes the job by packaging and publishing official `.zip` releases ready for public distribution.
