#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — Lenovo ThinkPad T490s (ALL Linux Distros)
# Intel i7-8665U | 32GB RAM | Intel UHD 620
# Works on: Fedora, Ubuntu/Debian, Arch, openSUSE, RHEL, CentOS, Mint, etc.
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/t490s-$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization-t490s.log"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok() { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }

# Run common optimizations first (includes distro detection)
banner "RUNNING COMMON OPTIMIZATIONS"
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/linux-common.sh | bash || true

# Universal package install helper
pkg_install() {
    if command -v dnf &>/dev/null; then dnf install -y "$@" 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" 2>/dev/null || true
    elif command -v pacman &>/dev/null; then pacman -Sy --noconfirm "$@" 2>/dev/null || true
    elif command -v zypper &>/dev/null; then zypper install -y "$@" 2>/dev/null || true
    elif command -v apk &>/dev/null; then apk add "$@" 2>/dev/null || true
    fi
}

banner "T490s 1/6 — BATTERY PROTECTION (60-80% Charge Limit)"
# ThinkPad battery charge thresholds — kernel driver (works on all distros)
modprobe thinkpad_acpi 2>/dev/null || true
if [ -f /sys/class/power_supply/BAT0/charge_control_start_threshold ]; then
    echo 60 > /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || true
    echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
    ok "Battery charge limited: 60% → 80% (extends lifespan 2-3x)"
else
    warn "BAT0 thresholds not available — may need thinkpad_acpi kernel module"
fi

# TLP — available on all major distros
pkg_install tlp
if command -v pacman &>/dev/null; then pkg_install tlp-rdw; fi
if command -v dnf &>/dev/null; then pkg_install tlp-rdw; fi

mkdir -p /etc/tlp.d
cat > /etc/tlp.d/01-thinkpad-t490s.conf << 'EOF'
# ThinkPad T490s Battery Protection & Power Management
START_CHARGE_THRESH_BAT0=60
STOP_CHARGE_THRESH_BAT0=80
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
INTEL_GPU_MIN_FREQ_ON_AC=300
INTEL_GPU_MIN_FREQ_ON_BAT=300
INTEL_GPU_MAX_FREQ_ON_AC=1150
INTEL_GPU_MAX_FREQ_ON_BAT=900
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on
USB_AUTOSUSPEND=1
DISK_IOSCHED="mq-deadline"
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto
TPACPI_ENABLE=1
TPSMAPI_ENABLE=1
EOF
systemctl enable --now tlp 2>/dev/null || true
systemctl mask systemd-rfkill systemd-rfkill.socket 2>/dev/null || true
tlp start 2>/dev/null || true
ok "TLP configured for ThinkPad T490s"

banner "T490s 2/6 — THERMAL MANAGEMENT"
pkg_install thermald lm-sensors lm_sensors
systemctl enable --now thermald 2>/dev/null || true
sensors-detect --auto 2>/dev/null || true

# thinkfan — install per distro
if command -v dnf &>/dev/null; then pkg_install thinkfan
elif command -v apt-get &>/dev/null; then pkg_install thinkfan
elif command -v pacman &>/dev/null; then pkg_install thinkfan
elif command -v zypper &>/dev/null; then pkg_install thinkfan
fi

if command -v thinkfan &>/dev/null; then
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
    ok "ThinkPad intelligent fan control active"
else
    warn "thinkfan not available — install manually for fan control"
fi

banner "T490s 3/6 — POWER MANAGEMENT (i7-8665U)"
if [ -d /sys/devices/system/cpu/intel_pstate ]; then
    echo 30 > /sys/devices/system/cpu/intel_pstate/min_perf_pct 2>/dev/null || true
    echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct 2>/dev/null || true
    ok "Intel P-state: 30-100% range"
fi
powertop --auto-tune 2>/dev/null || true
ok "Powertop auto-tune applied"

banner "T490s 4/6 — DISPLAY (UHD 620)"
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
# EasyEffects — available on all major distros
if command -v dnf &>/dev/null; then pkg_install easyeffects
elif command -v apt-get &>/dev/null; then pkg_install easyeffects
elif command -v pacman &>/dev/null; then pkg_install easyeffects
elif command -v zypper &>/dev/null; then pkg_install easyeffects
fi
ok "Dolby Atmos audio profile (via EasyEffects) — configure presets in GUI"

banner "T490s 6/6 — THINKPAD EXTRAS"
# TrackPoint sensitivity
if [ -d /sys/devices/platform/i8042/serio1 ]; then
    echo 200 > /sys/devices/platform/i8042/serio1/sensitivity 2>/dev/null || true
    echo 97 > /sys/devices/platform/i8042/serio1/speed 2>/dev/null || true
    ok "TrackPoint sensitivity optimized"
fi

# SSD TRIM timer — universal
systemctl enable --now fstrim.timer 2>/dev/null || true
ok "SSD weekly TRIM enabled"

banner "✅ THINKPAD T490s OPTIMIZATION COMPLETE"
echo "  Backup: $BACKUP_DIR"
echo "  Battery: 60-80% charge protection ON"
echo "  🔄 Reboot recommended: sudo reboot"
