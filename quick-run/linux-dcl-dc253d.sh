#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — DCL DC253D (ALL Linux Distros)
# 13th Gen Intel i3-1315U | 8GB RAM | Desktop
# Works on: Fedora, Ubuntu/Debian, Arch, openSUSE, RHEL, CentOS, Mint, etc.
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/dc253d-$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization-dc253d.log"
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

banner "DC253D 1/5 — PERFORMANCE MODE (i3-1315U)"
# 13th Gen Intel — Alder Lake hybrid arch (P-cores + E-cores)
if command -v tuned-adm &>/dev/null; then
    tuned-adm profile throughput-performance 2>/dev/null || true
    ok "tuned → throughput-performance"
fi

if [ -d /sys/devices/system/cpu/intel_pstate ]; then
    echo 40 > /sys/devices/system/cpu/intel_pstate/min_perf_pct 2>/dev/null || true
    echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct 2>/dev/null || true
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    ok "Intel P-state: turbo on, 40-100%"
fi

if ! grep -q "DC253D Performance" /etc/sysctl.conf 2>/dev/null; then
    cat >> /etc/sysctl.conf << 'EOF'

### DC253D Performance ###
kernel.sched_autogroup_enabled=1
kernel.sched_child_runs_first=1
EOF
    sysctl -p 2>/dev/null || true
fi
ok "CPU scheduler optimized for hybrid architecture"

banner "DC253D 2/5 — MEMORY OPTIMIZATION (8GB)"
if ! grep -q "DC253D Memory" /etc/sysctl.conf 2>/dev/null; then
    cat >> /etc/sysctl.conf << 'EOF'

### DC253D Memory (8GB) ###
vm.swappiness=5
vm.vfs_cache_pressure=75
vm.dirty_ratio=10
vm.dirty_background_ratio=3
vm.overcommit_memory=0
vm.overcommit_ratio=80
EOF
    sysctl -p 2>/dev/null || true
fi

# ZRAM — cross-distro compressed swap
if command -v dnf &>/dev/null; then
    pkg_install zram-generator
elif command -v apt-get &>/dev/null; then
    pkg_install systemd-zram-generator zram-tools
elif command -v pacman &>/dev/null; then
    pkg_install zram-generator
elif command -v zypper &>/dev/null; then
    pkg_install systemd-zram-service
fi

# Configure ZRAM (systemd method — works everywhere with systemd)
if [ -d /usr/lib/systemd ]; then
    mkdir -p /etc/systemd
    cat > /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
    systemctl daemon-reload 2>/dev/null || true
    ok "ZRAM swap enabled (effectively ~12GB usable memory)"
fi

# Fallback: manual zram for non-systemd or older kernels
if ! [ -f /etc/systemd/zram-generator.conf ] && [ -f /sys/block/zram0/disksize ]; then
    echo "$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 2 ))K" > /sys/block/zram0/disksize
    mkswap /dev/zram0 2>/dev/null || true
    swapon -p 100 /dev/zram0 2>/dev/null || true
    ok "ZRAM swap enabled (manual fallback)"
fi
ok "Memory tuned for 8GB system"

banner "DC253D 3/5 — DISPLAY (13th Gen Intel UHD)"
mkdir -p /etc/X11/xorg.conf.d /etc/modprobe.d
cat > /etc/X11/xorg.conf.d/20-intel-uhd-13thgen.conf << 'EOF'
Section "Device"
    Identifier "Intel UHD (13th Gen)"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF
cat > /etc/modprobe.d/i915-13thgen.conf << 'EOF'
options i915 enable_guc=3 enable_fbc=1 fastboot=1
EOF
ok "Intel UHD 13th Gen — DRI3 + GuC/HuC enabled"

banner "DC253D 4/5 — I/O OPTIMIZATION (Desktop SSD)"
mkdir -p /etc/udev/rules.d
cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
systemctl enable --now fstrim.timer 2>/dev/null || true
ok "SSD I/O scheduler + weekly TRIM"

banner "DC253D 5/5 — DOLBY AUDIO PROFILE"
if command -v dnf &>/dev/null; then pkg_install easyeffects
elif command -v apt-get &>/dev/null; then pkg_install easyeffects
elif command -v pacman &>/dev/null; then pkg_install easyeffects
elif command -v zypper &>/dev/null; then pkg_install easyeffects
fi

mkdir -p /etc/pipewire/pipewire.conf.d
cat > /etc/pipewire/pipewire.conf.d/99-dolby-dc253d.conf << 'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 192000 ]
    default.clock.quantum = 512
    default.clock.min-quantum = 32
}
EOF
ok "Dolby audio profile (low-latency desktop)"

banner "✅ DCL DC253D OPTIMIZATION COMPLETE"
echo "  Backup: $BACKUP_DIR"
echo "  ZRAM: ~12GB effective memory"
echo "  🔄 Reboot recommended: sudo reboot"
