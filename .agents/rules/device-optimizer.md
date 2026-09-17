# Antigravity Rule: Device-Specific Optimization Standard

When asked to optimize a machine or create a new hardware profile in this repository, always adhere to the following 6-Phase Standard:

1. **Phase 1 (Reconnaissance)**:
   - Always probe the target machine live via terminal commands before making changes.
   - Detect CPU stepping, GPU VRAM, RAM dual-channel, NVMe APST, WMI BIOS, battery wear, and OEM charge threshold interfaces.

2. **Phase 2 (Tailored 18-Sector Architecture)**:
   - Never use generic one-size-fits-all scripts.
   - Implement all 18 sectors: CPU EPP, RAM zero-compression, NVMe APST latency zeroing, GPU HAGS/boost, TCP low-latency, BIOS thermal maxima, Scheduler 0x26, Services demand-start, Battery 75-80% hardware limit, Cloudflare 1.1.1.3 DNS, Display DPST disable, Audio ducking disable & MMCSS priority 6, PCIe ASPM Off on AC, 1:1 mouse tracking, Privacy telemetry debloat, instant window animation, GameDVR disable, and OEM driver shield.

3. **Phase 3 (Live Execution & Verification)**:
   - Always create a system restore point first.
   - Execute all sectors live on the host.
   - Verify all modified registry keys, active powercfg indexes, and services live.

4. **Phase 4 (Autonomous Background Watchdog)**:
   - Install a persistent background scheduled task that automatically detects AC vs Battery status.
   - Switch to Maximum Performance on AC, and Extreme Battery Saver on Battery.
   - Continuously re-enforce the 75%-80% battery threshold.

5. **Phase 5 (1-Line Execution Delivery)**:
   - Provide `Run-Once.cmd` for 1-click double-click launching.
   - Provide `irm <raw_github_url> | iex` with in-memory self-elevation fallback.

6. **Phase 6 (Repository Synchronization)**:
   - Store profiles under `devices/<os>/<manufacturer-model>/`.
   - Update the root `README.md` compatibility matrix and flowchart.
   - Push to GitHub and package official `.zip` releases.
