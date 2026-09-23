# Antigravity Rule: Device-Specific Optimization Standard (21 Sectors)

When asked to optimize a machine or create a new hardware profile in this repository, always adhere strictly to this multi-phase silicon-level standard:

1. **Phase 1 (Silicon Reconnaissance & Probing)**:
   - Always probe the target machine live via terminal commands before making changes.
   - Detect CPU stepping, P/E-core topology, GPU VRAM, RAM dual-channel, NVMe APST latencies, WMI/DMI BIOS, battery wear, and OEM charge threshold interfaces (EC, ThinkLMI, ACPI).

2. **Phase 2 (Phantom Hardware Purge & Throttle Bypasses)**:
   - Purge polling daemons on absent/unpopulated hardware (WWAN/LTE ModemManager, SmartCard pcscd, fingerprint readers, touch digitizers, absent discrete GPUs, and unlinked Ethernet PHYs).
   - Apply silicon throttle bypasses: clear false BD-PROCHOT 800MHz locks, unlock PL1/PL2 power envelopes, override aggressive DPTF clamps, and steer older GPUs without hardware AV1 decode to hardware-accelerated H.264/VP9.

3. **Phase 3 (Tailored 21-Sector Architecture)**:
   - Never use generic one-size-fits-all scripts.
   - Implement all 21 sectors:
     1. PCIe ASPM L1/L0s Sub-states.
     2. Permanent 75%–80% Battery Charge Ceiling.
     3. Display Panel Self-Refresh (PSR2) & Contrast Dimming (DPST/Vari-Bright) disable.
     4. Audio DSP 48kHz low-latency buffers & ducking elimination.
     5. DPTF / thermald custom thermal profiles & early fan ramping.
     6. CPU Governor & HWP EPP (balance_performance on AC / balance_power on Battery).
     7. NVMe Storage APST microsecond latency masking & TRIM.
     8. GPU Render Standby (RC6p), FBC & HAGS Mode 2.
     9. USB Selective Suspend with HID input whitelisting.
     10. ZRAM zstd compression (`swappiness=10`) / Windows Memory Compression Pool.
     11. Network TCP_NODELAY & Wi-Fi dynamic power-save disable during active sockets.
     12. Kernel NMI watchdog disable (`kernel.nmi_watchdog=0`).
     13. Bluetooth LE radio idle suspension.
     14. Systemd telemetry decoupling & diagnostics service debloat.
     15. I/O Scheduler optimization (BFQ / Kyber multi-queue).
     16. S3 Deep Sleep (`mem_sleep=deep`) & Modern Standby backpack shield.
     17. Trackpad I2C sleep freeze shield & keyboard debounce tuning.
     18. Webcam 50Hz anti-flicker & `uvcvideo nodrop=1` frame pipeline.
     19. Audio Codec D-state zeroing (`snd_hda_intel power_save=0` pop eliminator).
     20. Hardware Video Acceleration (VA-API QuickSync / D3D12 browser offload).
     21. Autonomous Dynamic AC/DC Power Orchestrator daemon (8ms switching).

4. **Phase 4 (Live Execution & Verification)**:
   - Always create a system restore point / backup snapshot first.
   - Execute all sectors live on the host.
   - Verify all sysfs registers, kernel module parameters, active powercfg indexes, and services live (require return code 0 and 0 failed units).
   - Pair every script with a 100% symmetric rollback restore script (`restore-*.sh` / `Restore-*.ps1`).

5. **Phase 5 (Autonomous Background Watchdog)**:
   - Install a persistent background event-driven watchdog (systemd daemon / Windows Task Scheduler Event 105).
   - Switch to Maximum Performance on AC, and Extreme Battery Saver on Battery.
   - Continuously re-enforce the 75%-80% battery threshold silently.

6. **Phase 6 (1-Line Execution Delivery & Distribution)**:
   - Provide `Run-Once.cmd` for 1-click double-click launching.
   - Provide `curl ... | sudo bash` (Linux) or `irm ... | iex` (Windows) with in-memory self-elevation fallback.
   - Package standalone offline bundles under `dist/<Device>/`.

7. **Phase 7 (Identity Attribution & Repository Synchronization)**:
   - Store profiles under `devices/<os>/<manufacturer-model>/`.
   - Update `README.md`, `ABOUT.md`, and the web portal (`docs/index.html`).
   - Configure Git Author Identity to `Shoumik Bala Somu <shoumik.bala@gmail.com>`.
   - Push cleanly to GitHub and package official release tags.
