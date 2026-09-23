/**
 * ==============================================================================
 * 🚀 DEVICE-BASE-OPTIMIZATION — INTERACTIVE HUD & TELEMETRY ENGINE
 * Repository: ShoumikBalaSomu/Device-Base-Optimization
 * Architecture: 21 Autonomous Sectors | Zero-Lag Parallax | Real-time Canvas Studio
 * ==============================================================================
 */

(function () {
  'use strict';

  // --- 1. DATA DICTIONARIES: 21 OPTIMIZATION SECTORS ---
  const SECTORS_DATA = [
    {
      id: 1,
      cat: "kernel",
      code: "SEC-01",
      title: "Active State Power Management (ASPM)",
      badge: "PCIe Bus L1/L0s",
      desc: "Autonomously audits PCIe interconnects, forcing L1 sub-states on root ports while granting high-bandwidth burst transitions without bus freeze.",
      tech: "Linux: pcie_aspm=force | Win: ACPI D-state override"
    },
    {
      id: 2,
      cat: "kernel",
      code: "SEC-02",
      title: "Dynamic Battery Health Thresholding",
      badge: "Cycle Preservation",
      desc: "Enforces 80% maximum charging ceiling via OEM ACPI/WMI registers (ThinkLMI & EC) to prevent Lithium-ion dendrite formation and cell swelling.",
      tech: "Linux: tpacpi / ec_sys | Win: Lenovo Vantage WMI"
    },
    {
      id: 3,
      cat: "graphics",
      code: "SEC-03",
      title: "Display Refresh & Panel Self-Refresh",
      badge: "GPU VBlank Tuning",
      desc: "Activates Intel PSR/PSR2 (Panel Self-Refresh) and adapts refresh rate dynamically (e.g. 60Hz idle vs high-rate motion) to save 1.2W-1.8W display draw.",
      tech: "Linux: i915.enable_psr=1 | Win: Intel Graphics Command Center"
    },
    {
      id: 4,
      cat: "kernel",
      code: "SEC-04",
      title: "Audio DSP & Zero-Lag Latency",
      badge: "Sound Subsystem",
      desc: "Stops audio DAC pop/crack by tuning power_save timeouts to 0ms on AC, while deploying real-time RNNoise AEC suppression pipelines.",
      tech: "Linux: snd_hda_intel power_save=0 | Win: Realtek High Definition ASIO"
    },
    {
      id: 5,
      cat: "kernel",
      code: "SEC-05",
      title: "Thermal Management & Fan Profiles",
      badge: "DPTF / thermald",
      desc: "Deploys Intel Dynamic Platform and Thermal Framework (DPTF) tables, preventing thermal throttle oscillations through gentle early fan ramps.",
      tech: "Linux: thermald + throttled | Win: Intel DPTF OEM Inf"
    },
    {
      id: 6,
      cat: "kernel",
      code: "SEC-06",
      title: "CPU Governor & Energy Performance Bias",
      badge: "P-Core / E-Core",
      desc: "Synchronizes Intel HWP (Hardware P-States) with EPP (Energy Performance Preference): balance_performance on AC, balance_power on battery.",
      tech: "Linux: intel_pstate EPP | Win: Powercfg PPM EPB"
    },
    {
      id: 7,
      cat: "storage",
      code: "SEC-07",
      title: "NVMe Storage APST & Host Latency",
      badge: "Storage Engine",
      desc: "Configures Autonomous Power State Transitions (APST) with microsecond exit latency tolerance, cutting SSD temperature by up to 9°C.",
      tech: "Linux: nvme_core.default_ps_max_latency_us=0 | Win: StorNVMe LPM"
    },
    {
      id: 8,
      cat: "graphics",
      code: "SEC-08",
      title: "GPU Render Standby (RC6) & FBC",
      badge: "Intel Iris Xe / UHD",
      desc: "Forces GPU deep slice power gating (RC6p) and Framebuffer Compression (FBC) to eliminate idle memory bandwidth consumption.",
      tech: "Linux: i915.enable_fbc=1 enable_rc6=1 | Win: D3DKMT PowerState"
    },
    {
      id: 9,
      cat: "security",
      code: "SEC-09",
      title: "Autonomous USB Power Gating & UWS",
      badge: "Host Controller",
      desc: "Selectively auto-suspends inactive USB hub ports while whitelisting HID input devices (mice/keyboards) to eliminate phantom 0.8W drains.",
      tech: "Linux: powertop usb autosuspend | Win: USB selective suspend"
    },
    {
      id: 10,
      cat: "storage",
      code: "SEC-10",
      title: "Virtual Memory Swappiness & ZRAM",
      badge: "RAM & VMM",
      desc: "Initializes ZRAM compressed RAM swap (zstd) with vm.swappiness=10 and vfs_cache_pressure=50, doubling responsive memory headroom.",
      tech: "Linux: zram-generator + sysctl | Win: Memory Compression Pool"
    },
    {
      id: 11,
      cat: "security",
      code: "SEC-11",
      title: "Network Latency & Wi-Fi PM",
      badge: "802.11ax / ac",
      desc: "Disables disruptive Wi-Fi dynamic power savings during active sockets, cutting jitter and packet loss on Zoom/Teams calls.",
      tech: "Linux: iw wlan0 set power_save off | Win: NetAdapter LSO/RSC"
    },
    {
      id: 12,
      cat: "kernel",
      code: "SEC-12",
      title: "Kernel Watchdog & NMI Tick Disable",
      badge: "Interrupt Timers",
      desc: "Silences unnecessary hardware non-maskable interrupt (NMI) watchdogs, reducing idle context switches by up to 250 ticks per second.",
      tech: "Linux: kernel.nmi_watchdog=0 | Win: High Precision Event Timer"
    },
    {
      id: 13,
      cat: "security",
      code: "SEC-13",
      title: "Bluetooth LE Radio Idle Suspension",
      badge: "Radio Frequency",
      desc: "Powers down RF transceivers when no paired BLE peripherals are transmitting, recovering battery reserves without connection drops.",
      tech: "Linux: rfkill block bluetooth (opt) | Win: BthEnum LPM"
    },
    {
      id: 14,
      cat: "security",
      code: "SEC-14",
      title: "Systemd Service & Telemetry Decoupling",
      badge: "Daemon Trimming",
      desc: "Masks non-essential debug loggers, diagnostic reporting, and background indexing services that induce random disk wakes.",
      tech: "Linux: systemctl mask abrt / whoopsie | Win: DiagTrack Disable"
    },
    {
      id: 15,
      cat: "kernel",
      code: "SEC-15",
      title: "I/O Scheduler Optimization (BFQ / Kyber)",
      badge: "Block Devices",
      desc: "Selects multi-queue Kyber or BFQ schedulers for NVMe/SATA SSDs to guarantee zero UI frame lag under heavy background compilations.",
      tech: "Linux: /sys/block/nvme0n1/queue/scheduler=kyber"
    },
    {
      id: 16,
      cat: "security",
      code: "SEC-16",
      title: "S3 Deep Sleep / Modern Standby Tuning",
      badge: "Sleep & Suspend",
      desc: "Forces deep S3/s2idle states and prevents Windows Modern Standby / Linux S4 hibernation wake-lock battery drain inside backpacks.",
      tech: "Linux: mem_sleep=deep | Win: CsEnabled / PlatformAoAc"
    },
    {
      id: 17,
      cat: "multimedia",
      code: "SEC-17",
      title: "Hardware Keystroke Debounce & Trackpad",
      badge: "Input Subsystem",
      desc: "Optimizes touchpad polling rate, palm rejection algorithms, and keyboard debounce timing for fluid typing without missed strikes.",
      tech: "Linux: libinput Accel Speed + Palm | Win: Precision Touchpad"
    },
    {
      id: 18,
      cat: "multimedia",
      code: "SEC-18",
      title: "Webcam 50Hz Anti-Flicker & Nodrop Pipeline",
      badge: "UVC Video Camera",
      desc: "Configures UVC webcam parameters to 50Hz/60Hz AC lighting frequency with `nodrop=1` frame preservation to prevent conference stutter.",
      tech: "Linux: uvcvideo nodrop=1 + v4l2-ctl | Win: MediaCapture DShow"
    },
    {
      id: 19,
      cat: "multimedia",
      code: "SEC-19",
      title: "Audio Power-Gating Zeroing & Click Filter",
      badge: "Realtek / Conexant",
      desc: "Permanently disables aggressive 1-second headphone amp power gating that produces annoying audio snap/pop artifacts.",
      tech: "Linux: modprobe snd_hda_intel power_save=0 | Win: DevNode D0 State"
    },
    {
      id: 20,
      cat: "graphics",
      code: "SEC-20",
      title: "Hardware Video Acceleration (VA-API / D3D12)",
      badge: "VP9 / AV1 / H.264",
      desc: "Hooks Intel QuickSync / VA-API iHD drivers directly into web browsers (Chrome/Firefox/Edge), slashing 4K 60FPS video CPU load from 65% to 4%.",
      tech: "Linux: LIBVA_DRIVER_NAME=iHD | Win: MF_MEDIA_ENGINE_HARDWARE"
    },
    {
      id: 21,
      cat: "power",
      code: "SEC-21",
      title: "Autonomous Dynamic AC/DC Power Orchestrator",
      badge: "Udev / ACPI Daemon",
      desc: "Deploys an event-driven orchestrator daemon that instantly pivots all 20 previous sectors within 8ms whenever the charger is connected or unplugged.",
      tech: "Linux: udev power_supply switch | Win: Windows Power Notification"
    }
  ];

  // --- 2. DEVICE SPECIFICATIONS & COMMAND MAPS ---
  const DEVICE_CONFIGS = {
    daffodil: {
      name: "Daffodil DC253D (IDL528)",
      cpu: "Intel Core i3-1315U (6 Cores / 8 Threads)",
      gpu: "Intel Iris Xe Graphics (64 EUs)",
      ram: "8GB - 32GB DDR4-3200",
      battery: "Autonomous 80% Limit / Battery Charge Daemon",
      audio: "Realtek ALC269 + RNNoise Echo Suppression",
      camera: "UVC 720p HD Camera (50Hz Anti-flicker)",
      commands: {
        linux: "curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/daffodil-dc253d/optimize-daffodil-dc253d.sh | sudo bash",
        windows: "irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/daffodil-dc253d/optimize-daffodil-dc253d.ps1 | iex"
      }
    },
    thinkpad: {
      name: "Lenovo ThinkPad T490s (20NYS64T00)",
      cpu: "Intel Core i5-8365U / i7-8665U (vPro)",
      gpu: "Intel UHD Graphics 620",
      ram: "16GB - 32GB Dual-Channel DDR4",
      battery: "Native ThinkLMI Dual-Threshold (75% / 80%)",
      audio: "Conexant CX11880 + Low-Latency DSP",
      camera: "ThinkShutter IR / 720p Dual Mic Array",
      commands: {
        linux: "curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/lenovo-thinkpad-t490s/optimize-thinkpad-t490s.sh | sudo bash",
        windows: "irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/lenovo-thinkpad-t490s/optimize-thinkpad-t490s.ps1 | iex"
      }
    },
    universal: {
      name: "Universal OEM PC (Desktop / Laptop)",
      cpu: "Intel Core / AMD Ryzen (64-bit Architecture)",
      gpu: "Intel / AMD Radeon / NVIDIA Discrete",
      ram: "4GB - 128GB Unified Memory",
      battery: "Universal ACPI Battery Guard & Standby Optimizer",
      audio: "Standard HD Audio Latency Eliminator",
      camera: "UVC Universal Flicker Mitigation",
      commands: {
        linux: "curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/linux/universal/optimize-universal.sh | sudo bash",
        windows: "irm https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/devices/windows/universal/optimize-universal.ps1 | iex"
      }
    }
  };

  let currentDevice = "daffodil";
  let currentOS = "linux";

  // --- 3. BACKGROUND CANVAS PARTICLE CONSTELLATION ---
  function initBackgroundCanvas() {
    const canvas = document.getElementById("bg-canvas");
    if (!canvas) return;
    const ctx = canvas.getContext("2d");

    let width = (canvas.width = window.innerWidth);
    let height = (canvas.height = window.innerHeight);

    let mouseX = width / 2;
    let mouseY = height / 2;
    let targetMouseX = mouseX;
    let targetMouseY = mouseY;

    const PARTICLE_COUNT = Math.min(Math.floor((width * height) / 16000), 75);
    const particles = [];

    class Particle {
      constructor() {
        this.x = Math.random() * width;
        this.y = Math.random() * height;
        this.vx = (Math.random() - 0.5) * 0.45;
        this.vy = (Math.random() - 0.5) * 0.45;
        this.radius = Math.random() * 1.8 + 0.8;
        this.alpha = Math.random() * 0.5 + 0.2;
      }
      update() {
        this.x += this.vx;
        this.y += this.vy;

        if (this.x < 0) this.x = width;
        if (this.x > width) this.x = 0;
        if (this.y < 0) this.y = height;
        if (this.y > height) this.y = 0;
      }
      draw() {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(0, 240, 255, ${this.alpha})`;
        ctx.fill();
      }
    }

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      particles.push(new Particle());
    }

    window.addEventListener("resize", () => {
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    });

    window.addEventListener("mousemove", (e) => {
      targetMouseX = e.clientX;
      targetMouseY = e.clientY;
    });

    function animate() {
      ctx.clearRect(0, 0, width, height);

      // Smooth mouse lerp
      mouseX += (targetMouseX - mouseX) * 0.05;
      mouseY += (targetMouseY - mouseY) * 0.05;

      // Draw constellation connections
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x;
          const dy = particles[i].y - particles[j].y;
          const dist = Math.sqrt(dx * dx + dy * dy);

          if (dist < 120) {
            const alpha = (1 - dist / 120) * 0.15;
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(particles[j].x, particles[j].y);
            ctx.strokeStyle = `rgba(0, 240, 255, ${alpha})`;
            ctx.lineWidth = 0.8;
            ctx.stroke();
          }
        }
      }

      // Draw & update particles
      particles.forEach((p) => {
        p.update();
        p.draw();
      });

      requestAnimationFrame(animate);
    }
    animate();
  }

  // --- 4. POWER SIMULATOR STATE MACHINE ---
  function initPowerSimulator() {
    const powerToggle = document.getElementById("power-toggle-input");
    const acLabel = document.getElementById("label-ac-mode");
    const dcLabel = document.getElementById("label-dc-mode");

    const gaugePower = document.getElementById("gauge-val-power");
    const gaugeClock = document.getElementById("gauge-val-clock");
    const gaugeGovernor = document.getElementById("gauge-val-governor");
    const gaugeDegradation = document.getElementById("gauge-val-degrade");

    const barPower = document.getElementById("bar-power-fill");
    const barClock = document.getElementById("bar-clock-fill");
    const barDegradation = document.getElementById("bar-degrade-fill");

    if (!powerToggle) return;

    function applyState(isBattery) {
      if (isBattery) {
        // Battery Mode Active
        if (acLabel) acLabel.classList.remove("active");
        if (dcLabel) dcLabel.classList.add("active");

        if (gaugePower) gaugePower.textContent = "6.4 W";
        if (gaugeClock) gaugeClock.textContent = "1.8 GHz (Eff)";
        if (gaugeGovernor) gaugeGovernor.textContent = "balance_power";
        if (gaugeDegradation) gaugeDegradation.textContent = "0.00 % / cycle";

        if (barPower) barPower.style.width = "22%";
        if (barClock) barClock.style.width = "40%";
        if (barDegradation) {
          barDegradation.style.width = "8%";
          barDegradation.style.background = "var(--neon-emerald)";
        }
      } else {
        // AC Charger Plugged In
        if (acLabel) acLabel.classList.add("active");
        if (dcLabel) dcLabel.classList.remove("active");

        if (gaugePower) gaugePower.textContent = "38.2 W (Burst)";
        if (gaugeClock) gaugeClock.textContent = "4.4 GHz (Turbo)";
        if (gaugeGovernor) gaugeGovernor.textContent = "balance_performance";
        if (gaugeDegradation) gaugeDegradation.textContent = "Capped @ 80%";

        if (barPower) barPower.style.width = "85%";
        if (barClock) barClock.style.width = "95%";
        if (barDegradation) {
          barDegradation.style.width = "80%";
          barDegradation.style.background = "linear-gradient(90deg, #0070f3, #00f0ff)";
        }
      }
    }

    powerToggle.addEventListener("change", (e) => {
      applyState(e.target.checked);
    });

    // Default: AC plugged in
    applyState(false);
  }

  // --- 5. AUDIO VISUALIZER STUDIO SIMULATOR ---
  function initAudioVisualizer() {
    const canvas = document.getElementById("audio-canvas");
    if (!canvas) return;
    const ctx = canvas.getContext("2d");

    const rawBtn = document.getElementById("btn-audio-raw");
    const filteredBtn = document.getElementById("btn-audio-filtered");

    let isFiltered = true;
    let animFrame;
    let phase = 0;

    function resize() {
      canvas.width = canvas.parentElement.clientWidth - 32;
      canvas.height = 200;
    }
    resize();
    window.addEventListener("resize", resize);

    if (rawBtn && filteredBtn) {
      rawBtn.addEventListener("click", () => {
        isFiltered = false;
        rawBtn.classList.add("active");
        filteredBtn.classList.remove("active");
      });

      filteredBtn.addEventListener("click", () => {
        isFiltered = true;
        filteredBtn.classList.add("active");
        rawBtn.classList.remove("active");
      });
    }

    function renderAudioWave() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const width = canvas.width;
      const height = canvas.height;
      const centerY = height / 2;

      // Draw grid lines
      ctx.strokeStyle = "rgba(0, 240, 255, 0.08)";
      ctx.lineWidth = 1;
      for (let y = 20; y < height; y += 40) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        ctx.stroke();
      }

      // Draw waveform
      ctx.beginPath();
      ctx.lineWidth = 2.5;

      if (isFiltered) {
        ctx.strokeStyle = "#00f0ff";
        ctx.shadowColor = "#00f0ff";
        ctx.shadowBlur = 12;
      } else {
        ctx.strokeStyle = "#ff1744";
        ctx.shadowColor = "#ff1744";
        ctx.shadowBlur = 10;
      }

      const points = 180;
      for (let i = 0; i <= points; i++) {
        const x = (i / points) * width;
        let y = centerY;

        if (isFiltered) {
          // Smooth, clean crystal-clear sinusoidal acoustic vocal envelope
          const wave1 = Math.sin(i * 0.08 + phase) * 45;
          const wave2 = Math.sin(i * 0.16 - phase * 0.8) * 18;
          y += wave1 + wave2;
        } else {
          // Unfiltered noisy waveform with jitter, pop spikes and clipping
          const rawWave = Math.sin(i * 0.08 + phase) * 35;
          const noise = (Math.random() - 0.5) * 38;
          const spike = i % 25 === 0 ? (Math.random() - 0.5) * 60 : 0;
          y += rawWave + noise + spike;
        }

        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }

      ctx.stroke();
      ctx.shadowBlur = 0; // reset

      // Spectrum Bars beneath
      const barCount = 32;
      const barWidth = width / barCount - 4;
      for (let b = 0; b < barCount; b++) {
        const bx = b * (barWidth + 4) + 2;
        let bHeight;

        if (isFiltered) {
          // Harmonic decay curve (studio balanced)
          bHeight = Math.abs(Math.sin(b * 0.2 + phase)) * 55 * Math.exp(-b * 0.04);
          ctx.fillStyle = "rgba(0, 240, 255, 0.4)";
        } else {
          // Broadband white noise floor
          bHeight = Math.random() * 65 + 10;
          ctx.fillStyle = "rgba(255, 23, 68, 0.4)";
        }

        ctx.fillRect(bx, height - bHeight, barWidth, bHeight);
      }

      phase += 0.06;
      animFrame = requestAnimationFrame(renderAudioWave);
    }

    renderAudioWave();
  }

  // --- 6. 21-SECTOR MATRIX RENDERER & LIVE FILTER ---
  function initSectorsMatrix() {
    const grid = document.getElementById("sectors-grid");
    const filterPills = document.querySelectorAll(".filter-pill");
    const searchInput = document.getElementById("sector-search-input");

    if (!grid) return;

    function renderCards(items) {
      if (items.length === 0) {
        grid.innerHTML = `
          <div style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted); font-family: var(--font-mono);">
            [!] No optimization sectors found matching criteria.
          </div>
        `;
        return;
      }

      grid.innerHTML = items
        .map(
          (s) => `
        <div class="sector-card" data-cat="${s.cat}">
          <div class="sector-card-header">
            <span class="sector-badge">${s.code}</span>
            <span class="sector-status-pill">
              <span class="live-indicator-dot"></span> Active
            </span>
          </div>
          <h3 class="sector-title">${s.title}</h3>
          <p class="sector-desc">${s.desc}</p>
          <div class="sector-tech-box">
            <code>${s.tech}</code>
          </div>
        </div>
      `
        )
        .join("");
    }

    // Initial Full Render
    renderCards(SECTORS_DATA);

    function filterData() {
      const activePill = document.querySelector(".filter-pill.active");
      const currentCat = activePill ? activePill.getAttribute("data-filter") : "all";
      const query = (searchInput ? searchInput.value : "").trim().toLowerCase();

      const filtered = SECTORS_DATA.filter((s) => {
        const matchesCat = currentCat === "all" || s.cat === currentCat;
        const matchesQuery =
          !query ||
          s.title.toLowerCase().includes(query) ||
          s.desc.toLowerCase().includes(query) ||
          s.code.toLowerCase().includes(query) ||
          s.tech.toLowerCase().includes(query);
        return matchesCat && matchesQuery;
      });

      renderCards(filtered);
    }

    filterPills.forEach((pill) => {
      pill.addEventListener("click", () => {
        filterPills.forEach((p) => p.classList.remove("active"));
        pill.classList.add("active");
        filterData();
      });
    });

    if (searchInput) {
      searchInput.addEventListener("input", filterData);
    }
  }

  // --- 7. DEVICE SELECTOR & OS TABS HANDLER ---
  function updateDeviceDisplay() {
    const config = DEVICE_CONFIGS[currentDevice];
    if (!config) return;

    // Update specs
    const nameEl = document.getElementById("spec-device-name");
    const cpuEl = document.getElementById("spec-device-cpu");
    const gpuEl = document.getElementById("spec-device-gpu");
    const batEl = document.getElementById("spec-device-battery");
    const cmdEl = document.getElementById("device-command-text");

    if (nameEl) nameEl.textContent = config.name;
    if (cpuEl) cpuEl.textContent = config.cpu;
    if (gpuEl) gpuEl.textContent = config.gpu;
    if (batEl) batEl.textContent = config.battery;

    if (cmdEl) {
      cmdEl.textContent = config.commands[currentOS] || config.commands.linux;
    }
  }

  function initDeviceTabs() {
    const tabBtns = document.querySelectorAll(".device-tab-btn");
    const osPills = document.querySelectorAll(".os-pill");
    const copyBtn = document.getElementById("btn-copy-cmd");
    const cmdText = document.getElementById("device-command-text");

    tabBtns.forEach((btn) => {
      btn.addEventListener("click", () => {
        tabBtns.forEach((b) => b.classList.remove("active"));
        btn.classList.add("active");
        currentDevice = btn.getAttribute("data-device") || "daffodil";
        updateDeviceDisplay();
      });
    });

    osPills.forEach((pill) => {
      pill.addEventListener("click", () => {
        osPills.forEach((p) => p.classList.remove("active"));
        pill.classList.add("active");
        currentOS = pill.getAttribute("data-os") || "linux";
        updateDeviceDisplay();
      });
    });

    if (copyBtn && cmdText) {
      copyBtn.addEventListener("click", async () => {
        try {
          await navigator.clipboard.writeText(cmdText.textContent.trim());
          copyBtn.classList.add("copied");
          copyBtn.innerHTML = `✓ Copied!`;
          setTimeout(() => {
            copyBtn.classList.remove("copied");
            copyBtn.innerHTML = `
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
              Copy Command
            `;
          }, 2000);
        } catch (err) {
          console.error("Clipboard copy failed:", err);
        }
      });
    }

    updateDeviceDisplay();
  }

  // --- 8. THEME TOGGLE SWITCHER ---
  function initThemeToggle() {
    const themeBtn = document.getElementById("theme-toggle-btn");
    const themes = ["theme-default", "theme-matrix", "theme-cyber"];
    let currentIdx = 0;

    if (!themeBtn) return;

    themeBtn.addEventListener("click", () => {
      document.body.classList.remove("theme-matrix", "theme-cyber");
      currentIdx = (currentIdx + 1) % themes.length;

      if (themes[currentIdx] === "theme-matrix") {
        document.body.classList.add("theme-matrix");
        themeBtn.innerHTML = `<span>🟢 Matrix</span>`;
      } else if (themes[currentIdx] === "theme-cyber") {
        document.body.classList.add("theme-cyber");
        themeBtn.innerHTML = `<span>🟣 Cyber</span>`;
      } else {
        themeBtn.innerHTML = `<span>⚡ Cyan</span>`;
      }
    });
  }

  // --- 9. INITIALIZATION BOOTSTRAP ---
  document.addEventListener("DOMContentLoaded", () => {
    initBackgroundCanvas();
    initPowerSimulator();
    initAudioVisualizer();
    initSectorsMatrix();
    initDeviceTabs();
    initThemeToggle();
  });
})();
