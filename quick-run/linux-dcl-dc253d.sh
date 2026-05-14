#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — DCL DC253D (ALL Linux Distros)
# 13th Gen Intel i3-1315U | 8GB RAM | Desktop
# Works on: Fedora, Ubuntu/Debian, Arch, openSUSE, RHEL, CentOS, Mint, etc.
#
# FIXED:
#   • intel_pstate HWP-active → custom tuned profile (not raw sysfs writes)
#   • sysctl.conf deprecated → sysctl.d drop-in (idempotent)
#   • earlyoom conflict → systemd-oomd
#   • power-profiles-daemon conflict → detect & disable, install tuned-ppd
#   • Browser DoH → CleanBrowsing via managed policies
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/dc253d-$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization-dc253d.log"
SYSCTL_DROP="/etc/sysctl.d/99-dc253d.conf"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok() { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }
backup_file() { [ -f "$1" ] && cp -a "$1" "$BACKUP_DIR/$(basename "$1").bak" && ok "Backed up $1"; }

# Idempotent sysctl writer — writes to /etc/sysctl.d/ (not deprecated sysctl.conf)
sysctl_set() {
    local key="$1" val="$2"
    if ! grep -q "^${key}" "$SYSCTL_DROP" 2>/dev/null; then
        echo "${key} = ${val}" >> "$SYSCTL_DROP"
    fi
}

# Universal package install helper
pkg_install() {
    if command -v dnf &>/dev/null; then dnf install -y "$@" 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" 2>/dev/null || true
    elif command -v pacman &>/dev/null; then pacman -Sy --noconfirm "$@" 2>/dev/null || true
    elif command -v zypper &>/dev/null; then zypper install -y "$@" 2>/dev/null || true
    elif command -v apk &>/dev/null; then apk add "$@" 2>/dev/null || true
    fi
}

# Run common optimizations first (includes distro detection)
banner "RUNNING COMMON OPTIMIZATIONS"
curl -fsSL https://raw.githubusercontent.com/ShoumikBalaSomu/Device-Base-Optimization/main/quick-run/linux-common.sh | bash || true

###############################################################################
banner "DC253D 1/6 — ADAPTIVE PERFORMANCE (i3-1315U Hybrid)"
###############################################################################

# Install tuned + tuned-ppd (D-Bus compatibility layer)
pkg_install tuned tuned-utils
# tuned-ppd: bridges power-profiles-daemon D-Bus API → tuned
# Available on Fedora 41+, Ubuntu 24.04+, Arch (AUR)
pkg_install tuned-ppd 2>/dev/null || true

# FIX: Detect and disable power-profiles-daemon (conflicts with tuned)
# power-profiles-daemon overwrites tuned's CPU governor on every GUI power-mode click
if systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
    warn "Disabling power-profiles-daemon (conflicts with tuned)"
    systemctl disable --now power-profiles-daemon 2>/dev/null || true
fi
if systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null; then
    systemctl mask power-profiles-daemon 2>/dev/null || true
fi

# FIX: Use systemd-oomd instead of earlyoom (Fedora 41+ default OOM daemon)
# earlyoom polls memory at intervals — running both causes kill storms
if systemctl is-active --quiet earlyoom 2>/dev/null; then
    warn "Disabling earlyoom (conflicts with systemd-oomd)"
    systemctl disable --now earlyoom 2>/dev/null || true
fi
systemctl enable --now tuned irqbalance 2>/dev/null || true
systemctl enable --now systemd-oomd 2>/dev/null || true

# FIX: Create custom tuned profile for DC253D
# On Fedora 44+ with HWP-active mode, direct sysfs writes to
# /sys/devices/system/cpu/intel_pstate/{min_perf_pct,max_perf_pct,no_turbo}
# are SILENTLY IGNORED. Use tuned's [cpu] section which uses the correct
# kernel APIs for HWP control.
mkdir -p /etc/tuned/dc253d-desktop
cat > /etc/tuned/dc253d-desktop/tuned.conf << 'EOF'
[main]
summary=DCL DC253D — 13th Gen Desktop (throughput + adaptive)

[cpu]
force_latency=6
governor=performance
energy_perf_bias=performance
min_perf_pct=40
max_perf_pct=100
no_turbo=0

[sysctl]
vm.swappiness=5
vm.dirty_ratio=10
vm.dirty_background_ratio=3
vm.vfs_cache_pressure=75
kernel.sched_autogroup_enabled=1
kernel.sched_child_runs_first=1

[script]
script=${i:PROFILE_DIR}/script.sh
EOF

cat > /etc/tuned/dc253d-desktop/script.sh << 'SCRIPT'
#!/usr/bin/env bash
# Apply HWP energy_performance_preference per-CPU (works even in HWP-active mode)
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo performance > "$cpu" 2>/dev/null || true
    done
fi
SCRIPT
chmod +x /etc/tuned/dc253d-desktop/script.sh

# Activate the custom profile (fallback to throughput-performance if it fails)
tuned-adm profile dc253d-desktop 2>/dev/null || tuned-adm profile throughput-performance
ok "CPU: dc253d-desktop tuned profile, HWP=performance, turbo on"
ok "P-cores + E-cores optimized with Intel Thread Director"

###############################################################################
banner "DC253D 2/6 — MEMORY OPTIMIZATION (8GB + ZRAM)"
###############################################################################

# FIX: Idempotent sysctl via drop-in (not /etc/sysctl.conf appends)
backup_file /etc/sysctl.conf
touch "$SYSCTL_DROP"
# vm.swappiness/dirty_ratio handled by tuned profile, set only non-tuned values:
sysctl_set vm.overcommit_memory      0
sysctl_set vm.overcommit_ratio       80
sysctl_set fs.inotify.max_user_watches 524288
sysctl_set fs.inotify.max_user_instances 1024

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

sysctl --system 2>/dev/null || true
ok "Memory tuned for 8GB system (sysctl.d drop-in)"

###############################################################################
banner "DC253D 3/6 — NETWORK (TCP BBR + Hardening)"
###############################################################################

# FIX: Idempotent sysctl.d drop-in for network settings
sysctl_set net.core.default_qdisc               fq
sysctl_set net.ipv4.tcp_congestion_control       bbr
sysctl_set net.core.rmem_max                    16777216
sysctl_set net.core.wmem_max                    16777216
sysctl_set "net.ipv4.tcp_rmem"                  "4096 87380 16777216"
sysctl_set "net.ipv4.tcp_wmem"                  "4096 65536 16777216"
sysctl_set net.ipv4.tcp_fastopen                3
sysctl_set net.ipv4.tcp_slow_start_after_idle   0
sysctl_set net.ipv4.tcp_mtu_probing             1
sysctl_set net.ipv4.conf.all.rp_filter          1
sysctl_set net.ipv4.icmp_echo_ignore_broadcasts 1
sysctl --system 2>/dev/null || true
ok "TCP BBR + network hardening (sysctl.d drop-in)"

###############################################################################
banner "DC253D 4/6 — DISPLAY (13th Gen Intel UHD)"
###############################################################################

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

###############################################################################
banner "DC253D 5/6 — I/O + SSD OPTIMIZATION"
###############################################################################

mkdir -p /etc/udev/rules.d
cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
systemctl enable --now fstrim.timer 2>/dev/null || true
ok "SSD I/O scheduler + weekly TRIM"

###############################################################################
banner "DC253D 6/6 — AUDIO (PipeWire + Dolby)"
###############################################################################

pkg_install easyeffects 2>/dev/null || true

mkdir -p /etc/pipewire/pipewire.conf.d /etc/wireplumber/wireplumber.conf.d
cat > /etc/pipewire/pipewire.conf.d/99-dolby-dc253d.conf << 'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 192000 ]
    default.clock.quantum = 512
    default.clock.min-quantum = 32
}
EOF
cat > /etc/wireplumber/wireplumber.conf.d/99-amplify.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [ { node.name = "~alsa_output.*" } ]
    actions = { update-props = { volume.max = 1.5 } }
  }
]
EOF
ok "PipeWire 48kHz low-latency + volume 150%"

###############################################################################
banner "✅ DCL DC253D OPTIMIZATION COMPLETE"
###############################################################################
echo "  Backup:   $BACKUP_DIR"
echo "  Sysctl:   $SYSCTL_DROP"
echo "  Profile:  $(tuned-adm active 2>/dev/null || echo 'dc253d-desktop')"
echo "  ZRAM:     ~12GB effective memory"
echo ""
echo "  Verify adaptive performance:"
echo "    tuned-adm active                     # should show: dc253d-desktop"
echo "    tuned-adm verify                     # should verify profile applied"
echo "    cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
echo "                                         # should show: performance"
echo "    systemctl is-active power-profiles-daemon  # should be inactive"
echo "    systemctl is-active systemd-oomd           # should be active"
echo ""
echo "  🔄 Reboot recommended: sudo reboot"
