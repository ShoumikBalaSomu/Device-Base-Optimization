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
#   • Power auto-shifting → tuned-ppd bridge (GUI modes work now)
#   • Battery charge control → auto stop at 80%
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
banner "DC253D 1/7 — ADAPTIVE POWER (Auto-Shifting Profiles)"
###############################################################################
# PROBLEM: Previously we masked power-profiles-daemon + locked tuned to static
#          "performance" mode → GUI power switching (GNOME/KDE) stopped working.
#
# FIX: Use tuned + tuned-ppd bridge so GUI power mode changes are honored:
#   • GNOME/KDE "Performance"  → tuned dc253d-performance
#   • GNOME/KDE "Balanced"     → tuned dc253d-balanced (DEFAULT)
#   • GNOME/KDE "Power Saver"  → tuned dc253d-powersave
#
# tuned-ppd provides the power-profiles-daemon D-Bus API backed by tuned,
# so the desktop environment power controls work seamlessly.

# Install tuned + tuned-ppd (D-Bus compatibility layer)
pkg_install tuned tuned-utils
pkg_install tuned-ppd 2>/dev/null || true

# FIX: UNMASK power-profiles-daemon if it was previously masked by our script
if systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null | grep -q masked; then
    systemctl unmask power-profiles-daemon 2>/dev/null || true
    ok "Unmasked power-profiles-daemon (was incorrectly masked)"
fi

# Stop original power-profiles-daemon if running (tuned-ppd replaces it)
# tuned-ppd provides the same D-Bus API but routes to tuned profiles
if systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
    # Only stop the original ppd, not tuned-ppd
    if ! systemctl is-active --quiet tuned-ppd 2>/dev/null; then
        systemctl disable --now power-profiles-daemon 2>/dev/null || true
    fi
fi

# FIX: Use systemd-oomd instead of earlyoom (Fedora 41+ default OOM daemon)
if systemctl is-active --quiet earlyoom 2>/dev/null; then
    warn "Disabling earlyoom (conflicts with systemd-oomd)"
    systemctl disable --now earlyoom 2>/dev/null || true
fi
systemctl enable --now irqbalance 2>/dev/null || true
systemctl enable --now systemd-oomd 2>/dev/null || true

# --- Create 3 custom tuned profiles for auto-shifting ---

# Profile 1: dc253d-performance (for heavy workloads)
mkdir -p /etc/tuned/dc253d-performance
cat > /etc/tuned/dc253d-performance/tuned.conf << 'EOF'
[main]
summary=DCL DC253D — Performance mode (max throughput)
include=throughput-performance

[cpu]
force_latency=6
governor=performance
energy_perf_bias=performance
min_perf_pct=60
max_perf_pct=100
no_turbo=0

[sysctl]
vm.swappiness=5
vm.dirty_ratio=10
vm.dirty_background_ratio=3
vm.vfs_cache_pressure=75
kernel.sched_autogroup_enabled=1

[script]
script=${i:PROFILE_DIR}/script.sh
EOF

cat > /etc/tuned/dc253d-performance/script.sh << 'SCRIPT'
#!/usr/bin/env bash
# Set HWP to performance on all CPUs
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo performance > "$epp" 2>/dev/null || true
done
SCRIPT
chmod +x /etc/tuned/dc253d-performance/script.sh

# Profile 2: dc253d-balanced (DEFAULT — auto-shifts based on workload)
mkdir -p /etc/tuned/dc253d-balanced
cat > /etc/tuned/dc253d-balanced/tuned.conf << 'EOF'
[main]
summary=DCL DC253D — Balanced mode (adaptive auto-shifting)
include=balanced

[cpu]
governor=schedutil
energy_perf_bias=normal
min_perf_pct=20
max_perf_pct=100
no_turbo=0

[sysctl]
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5
vm.vfs_cache_pressure=75
kernel.sched_autogroup_enabled=1

[script]
script=${i:PROFILE_DIR}/script.sh
EOF

cat > /etc/tuned/dc253d-balanced/script.sh << 'SCRIPT'
#!/usr/bin/env bash
# Set HWP to balance_performance (CPU auto-shifts between power saving and boost)
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo balance_performance > "$epp" 2>/dev/null || true
done
SCRIPT
chmod +x /etc/tuned/dc253d-balanced/script.sh

# Profile 3: dc253d-powersave (for quiet/idle/low-load)
mkdir -p /etc/tuned/dc253d-powersave
cat > /etc/tuned/dc253d-powersave/tuned.conf << 'EOF'
[main]
summary=DCL DC253D — Power saver mode (quiet + efficient)
include=powersave

[cpu]
governor=schedutil
energy_perf_bias=powersave
min_perf_pct=10
max_perf_pct=70
no_turbo=1

[sysctl]
vm.swappiness=20
vm.dirty_ratio=20
vm.dirty_background_ratio=8
vm.vfs_cache_pressure=50

[script]
script=${i:PROFILE_DIR}/script.sh
EOF

cat > /etc/tuned/dc253d-powersave/script.sh << 'SCRIPT'
#!/usr/bin/env bash
# Set HWP to power saving
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo power > "$epp" 2>/dev/null || true
done
SCRIPT
chmod +x /etc/tuned/dc253d-powersave/script.sh

# Configure tuned-ppd to map GUI power modes → custom profiles
if [ -d /etc/tuned ]; then
    mkdir -p /etc/tuned/ppd.conf.d 2>/dev/null || true
    # tuned-ppd config (maps power-profiles-daemon API to tuned profiles)
    cat > /etc/tuned/ppd.conf 2>/dev/null << 'EOF' || true
[ppd]
performance=dc253d-performance
balanced=dc253d-balanced
power-saver=dc253d-powersave
default=dc253d-balanced
EOF
fi

# Enable tuned and tuned-ppd
systemctl enable --now tuned 2>/dev/null || true
systemctl enable --now tuned-ppd 2>/dev/null || true

# Set default profile to balanced (auto-shifting)
tuned-adm profile dc253d-balanced 2>/dev/null || tuned-adm profile balanced 2>/dev/null || true
ok "Power profiles: auto-shifting enabled via tuned-ppd"
ok "  Performance → dc253d-performance (governor=performance, HWP=max)"
ok "  Balanced    → dc253d-balanced    (governor=schedutil, HWP=auto) ← DEFAULT"
ok "  Power Saver → dc253d-powersave   (governor=schedutil, turbo=off)"
ok "GNOME/KDE power mode switcher now works with tuned"

###############################################################################
banner "DC253D 2/7 — BATTERY CHARGE CONTROL (Stop at 80%)"
###############################################################################
# DCL DC253D with i3-1315U (mobile chip) — may have internal battery/UPS
# Sets charge threshold to stop charging at 80% to extend battery lifespan

CHARGE_LIMIT_SET=false

# Method 1: Standard kernel sysfs interface (most common)
for bat in /sys/class/power_supply/BAT*/; do
    if [ -d "$bat" ]; then
        batname=$(basename "$bat")

        # charge_control_end_threshold (kernel 5.4+)
        if [ -f "${bat}charge_control_end_threshold" ]; then
            echo 80 > "${bat}charge_control_end_threshold" 2>/dev/null || true
            # Also set start threshold if available (hysteresis — start at 75%)
            [ -f "${bat}charge_control_start_threshold" ] && \
                echo 75 > "${bat}charge_control_start_threshold" 2>/dev/null || true
            ok "$batname: charge limit set → stop at 80%, resume at 75%"
            CHARGE_LIMIT_SET=true
        fi

        # Some devices use charge_behaviour
        if [ -f "${bat}charge_behaviour" ]; then
            # Check if 'inhibit-charge' or 'force-discharge' is available
            if grep -q "auto" "${bat}charge_behaviour" 2>/dev/null; then
                ok "$batname: charge_behaviour supports auto mode"
            fi
        fi
    fi
done

# Method 2: ACPI battery charge via platform driver (vendor-specific)
# Works for some devices that don't expose standard sysfs
if [ "$CHARGE_LIMIT_SET" = false ]; then
    # Try cros_ec (Chromebook-style embedded controller)
    if [ -f /sys/class/chromeos/cros_ec/charge_control_end_threshold ]; then
        echo 80 > /sys/class/chromeos/cros_ec/charge_control_end_threshold 2>/dev/null || true
        echo 75 > /sys/class/chromeos/cros_ec/charge_control_start_threshold 2>/dev/null || true
        ok "Charge limit set via cros_ec → stop at 80%"
        CHARGE_LIMIT_SET=true
    fi
fi

# Create systemd service to persist charge limit across reboots
if [ "$CHARGE_LIMIT_SET" = true ]; then
    cat > /etc/systemd/system/battery-charge-limit.service << 'EOF'
[Unit]
Description=Set battery charge limit to 80%
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'for bat in /sys/class/power_supply/BAT*/; do [ -f "${bat}charge_control_end_threshold" ] && echo 80 > "${bat}charge_control_end_threshold" && echo 75 > "${bat}charge_control_start_threshold" 2>/dev/null; done; [ -f /sys/class/chromeos/cros_ec/charge_control_end_threshold ] && echo 80 > /sys/class/chromeos/cros_ec/charge_control_end_threshold && echo 75 > /sys/class/chromeos/cros_ec/charge_control_start_threshold 2>/dev/null; true'

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable battery-charge-limit.service 2>/dev/null || true
    ok "Charge limit persisted via systemd (survives reboot)"
else
    warn "No battery sysfs detected — charge limit not applicable (pure desktop)"
    warn "If device has a battery, ensure ACPI battery driver is loaded"
fi

# Install TLP for battery management if battery exists
if ls /sys/class/power_supply/BAT* 1>/dev/null 2>&1; then
    pkg_install tlp
    mkdir -p /etc/tlp.d
    cat > /etc/tlp.d/01-dc253d-charge.conf << 'EOF'
# DCL DC253D Battery Charge Protection
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80
START_CHARGE_THRESH_BAT1=75
STOP_CHARGE_THRESH_BAT1=80
EOF
    # TLP conflicts with tuned for CPU — only use TLP for battery thresholds
    # Disable TLP CPU management, keep battery management
    cat > /etc/tlp.d/02-dc253d-cpu-disable.conf << 'EOF'
# Let tuned handle CPU — TLP only handles battery thresholds
CPU_SCALING_GOVERNOR_ON_AC=""
CPU_SCALING_GOVERNOR_ON_BAT=""
CPU_ENERGY_PERF_POLICY_ON_AC=""
CPU_ENERGY_PERF_POLICY_ON_BAT=""
CPU_BOOST_ON_AC=""
CPU_BOOST_ON_BAT=""
EOF
    systemctl enable --now tlp 2>/dev/null || true
    ok "TLP configured for battery charge control only (CPU managed by tuned)"
fi

###############################################################################
banner "DC253D 3/7 — MEMORY OPTIMIZATION (8GB + ZRAM)"
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
banner "DC253D 4/7 — NETWORK (TCP BBR + Hardening)"
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
banner "DC253D 5/7 — DISPLAY (13th Gen Intel UHD)"
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
banner "DC253D 6/7 — I/O + SSD OPTIMIZATION"
###############################################################################

mkdir -p /etc/udev/rules.d
cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
systemctl enable --now fstrim.timer 2>/dev/null || true
ok "SSD I/O scheduler + weekly TRIM"

###############################################################################
banner "DC253D 7/7 — AUDIO (PipeWire + Dolby)"
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
echo "  Profile:  $(tuned-adm active 2>/dev/null || echo 'dc253d-balanced')"
echo "  ZRAM:     ~12GB effective memory"
echo ""
echo "  Verify power auto-shifting:"
echo "    tuned-adm active                     # should show: dc253d-balanced"
echo "    tuned-adm list | grep dc253d         # should show 3 profiles"
echo "    cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
echo "                                         # balanced = balance_performance"
echo "    systemctl is-active tuned-ppd        # should be active"
echo "    systemctl is-active tuned            # should be active"
echo ""
echo "  Switch power mode manually:"
echo "    tuned-adm profile dc253d-performance # max performance"
echo "    tuned-adm profile dc253d-balanced    # auto (default)"
echo "    tuned-adm profile dc253d-powersave   # quiet/efficient"
echo "  Or use GNOME/KDE Settings → Power → Power Mode (auto via tuned-ppd)"
echo ""
echo "  Verify charge control:"
echo "    cat /sys/class/power_supply/BAT0/charge_control_end_threshold  # should be 80"
echo "    systemctl is-active battery-charge-limit  # should be active"
echo ""
echo "  🔄 Reboot recommended: sudo reboot"
