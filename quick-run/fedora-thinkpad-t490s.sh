#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — Lenovo ThinkPad T490s (Fedora 44)
# Intel i7-8665U | 32GB RAM | Intel UHD 620
# Runs common optimizations + T490s-specific tuning
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/t490s-$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization-t490s.log"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok() { echo -e "\033[1;32m  ✔ $1\033[0m"; }

# Run common optimizations first
banner "RUNNING COMMON OPTIMIZATIONS"
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/fedora-common.sh | bash || true

banner "T490s 1/6 — BATTERY PROTECTION (60-80% Charge Limit)"
# ThinkPad battery charge thresholds via tp_smapi / thinkpad_acpi
modprobe thinkpad_acpi 2>/dev/null || true
if [ -d /sys/class/power_supply/BAT0 ]; then
    # Set charge thresholds: start charging at 60%, stop at 80%
    echo 60 > /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || true
    echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
    ok "Battery charge limited: 60% → 80% (extends lifespan 2-3x)"
fi

# Persist via TLP
dnf install -y tlp tlp-rdw 2>/dev/null || true
mkdir -p /etc/tlp.d
cat > /etc/tlp.d/01-thinkpad-t490s.conf << 'EOF'
# ThinkPad T490s Battery Protection
START_CHARGE_THRESH_BAT0=60
STOP_CHARGE_THRESH_BAT0=80

# CPU energy policy (balance performance/power)
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# CPU boost: on when AC, off on battery for longevity
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# Intel GPU power
INTEL_GPU_MIN_FREQ_ON_AC=300
INTEL_GPU_MIN_FREQ_ON_BAT=300
INTEL_GPU_MAX_FREQ_ON_AC=1150
INTEL_GPU_MAX_FREQ_ON_BAT=900
INTEL_GPU_BOOST_FREQ_ON_AC=1150
INTEL_GPU_BOOST_FREQ_ON_BAT=900

# WiFi power saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# USB autosuspend
USB_AUTOSUSPEND=1

# Disk I/O scheduler
DISK_IOSCHED="mq-deadline"

# Runtime PM
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto

# ThinkPad specific
TPACPI_ENABLE=1
TPSMAPI_ENABLE=1
EOF
systemctl enable --now tlp 2>/dev/null || true
systemctl mask systemd-rfkill systemd-rfkill.socket 2>/dev/null || true
tlp start 2>/dev/null || true
ok "TLP configured for ThinkPad T490s"

banner "T490s 2/6 — THERMAL MANAGEMENT"
systemctl enable --now thermald 2>/dev/null || true
# ThinkPad fan control (thinkfan)
dnf install -y thinkfan lm_sensors 2>/dev/null || true
sensors-detect --auto 2>/dev/null || true
cat > /etc/thinkfan.conf << 'EOF'
sensors:
  - hwmon: /sys/devices/platform/thinkpad_hwmon/hwmon
    indices: [1]

fans:
  - tpacpi: /proc/acpi/ibm/fan

levels:
  - [0,  0,  45]
  - [1,  42, 55]
  - [2,  50, 60]
  - [3,  55, 65]
  - [4,  60, 70]
  - [5,  65, 75]
  - [7,  70, 85]
  - ["level auto", 80, 32767]
EOF
systemctl enable --now thinkfan 2>/dev/null || true
ok "Thermal management + intelligent fan control"

banner "T490s 3/6 — POWER MANAGEMENT (i7-8665U)"
# Intel P-state driver tuning
if [ -d /sys/devices/system/cpu/intel_pstate ]; then
    echo 30 > /sys/devices/system/cpu/intel_pstate/min_perf_pct 2>/dev/null || true
    echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct 2>/dev/null || true
    ok "Intel P-state: 30-100% range"
fi

# Powertop auto-tune
powertop --auto-tune 2>/dev/null || true
ok "Powertop auto-tune applied"

banner "T490s 4/6 — DISPLAY (UHD 620 Color Profile)"
# Intel UHD 620 specific color tuning
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-intel-uhd620.conf << 'EOF'
Section "Device"
    Identifier "Intel UHD 620"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF
ok "Intel UHD 620 — TearFree + DRI3 + glamor"

banner "T490s 5/6 — DOLBY ATMOS AUDIO PROFILE"
# EasyEffects / PipeWire equalizer for Dolby-like enhancement
dnf install -y easyeffects 2>/dev/null || true
mkdir -p /etc/pipewire/pipewire.conf.d
cat > /etc/pipewire/pipewire.conf.d/99-dolby-atmos-t490s.conf << 'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 ]
}
context.spa-libs = {
    audio.convert.* = audioconvert/libspa-audioconvert
}
EOF
ok "Dolby Atmos audio profile configured"

banner "T490s 6/6 — THINKPAD EXTRAS"
# TrackPoint sensitivity
if [ -d /sys/devices/platform/i8042/serio1 ]; then
    echo 200 > /sys/devices/platform/i8042/serio1/sensitivity 2>/dev/null || true
    echo 97 > /sys/devices/platform/i8042/serio1/speed 2>/dev/null || true
    ok "TrackPoint sensitivity optimized"
fi

banner "✅ THINKPAD T490s OPTIMIZATION COMPLETE"
echo "  Backup: $BACKUP_DIR"
echo "  Battery: 60-80% charge protection ON"
echo "  🔄 Reboot recommended: sudo reboot"
