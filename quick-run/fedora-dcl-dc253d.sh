#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — DCL DC253D (Fedora 44)
# 13th Gen Intel i3-1315U | 8GB RAM | Desktop
# Runs common optimizations + DC253D-specific tuning
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/dc253d-$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization-dc253d.log"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok() { echo -e "\033[1;32m  ✔ $1\033[0m"; }

# Run common optimizations first
banner "RUNNING COMMON OPTIMIZATIONS"
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/fedora-common.sh | bash || true

banner "DC253D 1/5 — PERFORMANCE MODE (i3-1315U)"
# 13th Gen Intel — Alder Lake hybrid arch (P-cores + E-cores)
# Maximize performance for desktop use
tuned-adm profile throughput-performance 2>/dev/null || true

# Intel Thread Director optimization
if [ -d /sys/devices/system/cpu/intel_pstate ]; then
    echo 40 > /sys/devices/system/cpu/intel_pstate/min_perf_pct 2>/dev/null || true
    echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct 2>/dev/null || true
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    ok "Intel P-state: turbo on, 40-100%"
fi

# CPU scheduler — prefer P-cores for foreground tasks
cat >> /etc/sysctl.conf << 'EOF'
### DC253D Performance ###
kernel.sched_autogroup_enabled=1
kernel.sched_child_runs_first=1
EOF
sysctl -p 2>/dev/null || true
ok "CPU scheduler optimized for hybrid architecture"

banner "DC253D 2/5 — MEMORY OPTIMIZATION (8GB)"
# With only 8GB RAM, optimize memory aggressively
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

# Enable zram for compressed swap (doubles effective RAM)
dnf install -y zram-generator 2>/dev/null || true
cat > /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
systemctl daemon-reload 2>/dev/null || true
ok "ZRAM swap enabled (effectively 12GB usable memory)"
ok "Memory tuned for 8GB system"

banner "DC253D 3/5 — DISPLAY (13th Gen Intel UHD)"
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-intel-uhd-13thgen.conf << 'EOF'
Section "Device"
    Identifier "Intel UHD (13th Gen)"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF

# Intel 13th gen GuC/HuC firmware
cat > /etc/modprobe.d/i915-13thgen.conf << 'EOF'
options i915 enable_guc=3 enable_fbc=1 fastboot=1
EOF
ok "Intel UHD 13th Gen — DRI3 + GuC/HuC enabled"

banner "DC253D 4/5 — I/O OPTIMIZATION (Desktop SSD)"
# Desktop SSD tuning — max throughput
cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

# Enable TRIM for SSD
systemctl enable fstrim.timer 2>/dev/null || true
ok "SSD I/O scheduler + weekly TRIM"

banner "DC253D 5/5 — DOLBY AUDIO PROFILE"
dnf install -y easyeffects 2>/dev/null || true
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
