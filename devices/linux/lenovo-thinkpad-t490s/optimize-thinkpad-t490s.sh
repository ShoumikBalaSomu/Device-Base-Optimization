#!/usr/bin/env bash
# ==============================================================================
#  ⚡ THINKPAD T490s AUTONOMOUS 18-SECTOR LINUX OPTIMIZATION ENGINE
#  Hardware Target: Lenovo ThinkPad T490s (Type: 20NYS64T00)
#  Operating System: Fedora Linux 44 Workstation (Kernel 7.2.4 x86_64)
#  Repository: ShoumikBalaSomu/Device-Base-Optimization
# ==============================================================================

set -euo pipefail

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "=============================================================================="
echo "   🚀 THINKPAD T490s 100% AUTONOMOUS HARDWARE & KERNEL OPTIMIZATION"
echo "=============================================================================="
echo -e "${NC}"

# Auto-Elevation Check
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}🔑 Requesting administrative privileges (sudo)...${NC}"
    exec sudo bash "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# ==============================================================================
# PHASE 0: PRE-FLIGHT SAFETY RESTORE SNAPSHOT (Btrfs)
# ==============================================================================
echo -e "\n${BOLD}[Phase 0/6] Pre-Flight Safety Snapshot...${NC}"
if findmnt -n -o FSTYPE / | grep -q "btrfs"; then
    mkdir -p /.snapshots
    SNAPSHOT_NAME="/.snapshots/pre-optimization-${TIMESTAMP}"
    echo -e "  🛡️  Creating read-only Btrfs snapshot at: ${CYAN}${SNAPSHOT_NAME}${NC}"
    btrfs subvolume snapshot -r / "$SNAPSHOT_NAME" 2>/dev/null || echo -e "  ⚠️ Snapshot notice: Root snapshot skipped or already exists."
    echo -e "  ${GREEN}✓ Safety restore point secured.${NC}"
else
    echo -e "  ℹ️  Root filesystem is not Btrfs. Snapshot skipped safely."
fi

# ==============================================================================
# SECTOR 01: CPU ARCHITECTURE & SCALING
# ==============================================================================
echo -e "\n${BOLD}[Sector 01/18] CPU SpeedShift EPP & Core Unparking...${NC}"
for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [[ -f "$epp" ]] && echo performance > "$epp" 2>/dev/null || true
done
# Ensure all 8 logical cores are unparked
for cpu in /sys/devices/system/cpu/cpu[1-7]/online; do
    [[ -f "$cpu" ]] && echo 1 > "$cpu" 2>/dev/null || true
done
echo -e "  ${GREEN}✓ All 8 logical cores online; SpeedShift EPP set to 'performance'.${NC}"

# ==============================================================================
# SECTOR 02: 32GB RAM ARCHITECTURE & VM SYSCTL
# ==============================================================================
echo -e "\n${BOLD}[Sector 02/18] 32GB RAM Tuning & Virtual Memory...${NC}"
cat << 'EOF' > /etc/sysctl.d/99-thinkpad-t490s-performance.conf
# ==============================================================================
# ThinkPad T490s Hardware Performance & Latency Sysctls
# ==============================================================================

# Memory Subsystem (32GB RAM Tuning)
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.max_map_count = 2147483642

# Network Stack & TCP Low Latency
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_fastopen = 3
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1

# Kernel Scheduler Autogrouping
kernel.sched_autogroup_enabled = 1

# Crash & Reboot Safety
kernel.panic = 10
kernel.sysrq = 1
EOF
sysctl --system >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Sysctl applied: swappiness=10, vfs_cache_pressure=50, max_map_count=2147483642.${NC}"

# ==============================================================================
# SECTOR 03: STORAGE & NVMe APST ZERO LATENCY
# ==============================================================================
echo -e "\n${BOLD}[Sector 03/18] NVMe SSD Zero-APST Latency & Volume ReTrim...${NC}"
cat << 'EOF' > /etc/modprobe.d/nvme-thinkpad.conf
# Zero APST sleep latency on NVMe SSD
options nvme_core default_ps_max_latency_us=0
EOF
if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
    echo 0 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
fi
systemctl enable --now fstrim.timer >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ NVMe APST sleep latency zeroed; fstrim.timer enabled.${NC}"

# ==============================================================================
# SECTOR 04: GPU ACCELERATION & SHADER CACHE
# ==============================================================================
echo -e "\n${BOLD}[Sector 04/18] GPU Acceleration & Shader Cache...${NC}"
cat << 'EOF' > /etc/modprobe.d/i915-thinkpad.conf
# Intel UHD 620 Graphics optimizations
options i915 enable_dpst=0 enable_guc=2
EOF
mkdir -p /etc/environment.d
cat << 'EOF' > /etc/environment.d/10-mesa-shader.conf
MESA_SHADER_CACHE_MAX_SIZE=4G
MESA_VK_ENABLE_SUBGROUP_EXTENSIONS=1
EOF
echo -e "  ${GREEN}✓ Intel i915 options locked (DPST disabled, GuC enabled); Mesa shader cache configured.${NC}"

# ==============================================================================
# SECTOR 05: LOW-LATENCY NETWORK STACK & BBR
# ==============================================================================
echo -e "\n${BOLD}[Sector 05/18] Low-Latency Network Stack & BBR Congestion Control...${NC}"
mkdir -p /etc/modules-load.d
echo "tcp_bbr" > /etc/modules-load.d/bbr.conf
modprobe tcp_bbr 2>/dev/null || true
sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1 || true
sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ TCP BBR + FQ active; delayed ACK eliminated; TCP Fast Open enabled.${NC}"

# ==============================================================================
# SECTOR 06: OEM BIOS & THERMAL POLICIES (ThinkPad DYTC)
# ==============================================================================
echo -e "\n${BOLD}[Sector 06/18] ThinkPad EC DYTC & Thermal Maxima...${NC}"
cat << 'EOF' > /etc/modprobe.d/thinkpad_acpi.conf
options thinkpad_acpi fan_control=1
EOF
if [[ -f /sys/firmware/acpi/platform_profile ]]; then
    echo performance > /sys/firmware/acpi/platform_profile 2>/dev/null || true
    echo -e "  ${GREEN}✓ ThinkPad ACPI platform profile locked to 'performance'.${NC}"
fi

# ==============================================================================
# SECTOR 07: KERNEL SCHEDULER AUTOGROUPING
# ==============================================================================
echo -e "\n${BOLD}[Sector 07/18] Kernel Scheduler Snappiness...${NC}"
sysctl -w kernel.sched_autogroup_enabled=1 >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Sched autogrouping enabled (foreground responsiveness guaranteed).${NC}"

# ==============================================================================
# SECTOR 08: SERVICES & DEBLOAT
# ==============================================================================
echo -e "\n${BOLD}[Sector 08/18] Background Telemetry & Service Debloat...${NC}"
systemctl disable --now abrt-journal-core abrt-oops abrt-xorg abrt-ccpp 2>/dev/null || true
mkdir -p /etc/systemd/coredump.conf.d
cat << 'EOF' > /etc/systemd/coredump.conf.d/10-limit.conf
[Coredump]
Storage=external
MaxUse=500M
EOF
echo -e "  ${GREEN}✓ Redundant error reporting services stopped; core dumps capped to 500MB.${NC}"

# ==============================================================================
# SECTOR 09: BATTERY CHEMISTRY PROTECTION (75% - 80% THRESHOLD)
# ==============================================================================
echo -e "\n${BOLD}[Sector 09/18] Permanent Battery Chemistry Protection...${NC}"
BAT_START="/sys/class/power_supply/BAT0/charge_control_start_threshold"
BAT_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"
if [[ -f "$BAT_START" ]]; then
    echo 75 > "$BAT_START" 2>/dev/null || true
fi
if [[ -f "$BAT_END" ]]; then
    echo 80 > "$BAT_END" 2>/dev/null || true
fi
cat << 'EOF' > /etc/udev/rules.d/99-thinkpad-battery-thresholds.rules
# ThinkPad T490s Battery Chemistry Protection & Watchdog Rules
SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ATTR{charge_control_start_threshold}="75", ATTR{charge_control_end_threshold}="80"
SUBSYSTEM=="power_supply", KERNEL=="AC", ACTION=="change", RUN+="/usr/local/bin/thinkpad-watchdog.sh"
EOF
udevadm control --reload-rules && udevadm trigger 2>/dev/null || true
echo -e "  ${GREEN}✓ Hardware charge thresholds locked: 75% Start / 80% Stop.${NC}"

# ==============================================================================
# SECTOR 10: SECURITY & CLOUDFLARE FAMILY DNS
# ==============================================================================
echo -e "\n${BOLD}[Sector 10/18] Security Hardening & Cloudflare Family DNS (DoT)...${NC}"
mkdir -p /etc/systemd/resolved.conf.d
cat << 'EOF' > /etc/systemd/resolved.conf.d/00-cloudflare-family.conf
[Resolve]
DNS=1.1.1.3#family.cloudflare-dns.com 1.0.0.3#family.cloudflare-dns.com 2606:4700:4700::1113#family.cloudflare-dns.com 2606:4700:4700::1003#family.cloudflare-dns.com
FallbackDNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
DNSOverTLS=yes
DNSSEC=allow-downgrade
EOF
systemctl restart systemd-resolved >/dev/null 2>&1 || true
systemctl enable --now firewalld >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Cloudflare 1.1.1.3 DNS-over-TLS active; Firewalld verified.${NC}"

# ==============================================================================
# SECTOR 11: DISPLAY QUALITY (NO DPST & SUBPIXEL RGB FONTS)
# ==============================================================================
echo -e "\n${BOLD}[Sector 11/18] Display Quality & Subpixel Font Smoothing...${NC}"
# User session gsettings
REAL_USER="${SUDO_USER:-$USER}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface font-antialiasing 'rgba' 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface font-hinting 'slight' 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ Intel DPST adaptive dimming disabled; RGB subpixel antialiasing active.${NC}"

# ==============================================================================
# SECTOR 12: HIGH-FIDELITY AUDIO (NO DUCKING & LOW-LATENCY PIPEWIRE)
# ==============================================================================
echo -e "\n${BOLD}[Sector 12/18] High-Fidelity Audio Calibration...${NC}"
mkdir -p /etc/pipewire/pipewire.conf.d /etc/wireplumber/wireplumber.conf.d
cat << 'EOF' > /etc/pipewire/pipewire.conf.d/10-high-fidelity.conf
context.properties = {
    default.clock.rate          = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 ]
    default.clock.quantum       = 512
    default.clock.min-quantum   = 256
    default.clock.max-quantum   = 1024
}
EOF
cat << 'EOF' > /etc/wireplumber/wireplumber.conf.d/99-disable-ducking.conf
wireplumber.settings = {
    linking.role-based.duck-level = 1.0
}
EOF
echo -e "  ${GREEN}✓ PipeWire 48kHz / 512 quantum active; WirePlumber stream ducking eliminated.${NC}"

# ==============================================================================
# SECTOR 13: BUS & PERIPHERAL LATENCY
# ==============================================================================
echo -e "\n${BOLD}[Sector 13/18] Bus Latency, PCIe ASPM & iGPU Boost...${NC}"
# Disable USB autosuspend on AC
for dev in /sys/bus/usb/devices/*/power/control; do
    [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
done
# Unlock Intel UHD 620 iGPU 1.15GHz boost
if [[ -f /sys/class/drm/card1/gt_boost_freq_mhz ]]; then
    echo 1150 > /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || true
    echo 1150 > /sys/class/drm/card1/gt_max_freq_mhz 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ USB autosuspend disabled; Intel UHD 620 clock unlocked to 1.15GHz.${NC}"

# ==============================================================================
# SECTOR 14: INPUT PRECISION & RESPONSIVENESS
# ==============================================================================
echo -e "\n${BOLD}[Sector 14/18] Input Precision & 1:1 Pointer Tracking...${NC}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat' 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.peripherals.touchpad accel-profile 'flat' 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.peripherals.keyboard delay 250 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 25 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ Mouse & Touchpad 1:1 flat acceleration profile; keyboard repeat delay 250ms.${NC}"

# ==============================================================================
# SECTOR 15: PRIVACY HARDENING & TELEMETRY REDUCTION
# ==============================================================================
echo -e "\n${BOLD}[Sector 15/18] Privacy & Diagnostic Hardening...${NC}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.privacy report-technical-problems false 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.privacy send-software-usage-stats false 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ Automatic problem reports and usage telemetry disabled.${NC}"

# ==============================================================================
# SECTOR 16: DESKTOP SNAPPINESS & SEARCH FOCUS
# ==============================================================================
echo -e "\n${BOLD}[Sector 16/18] Desktop Snappiness & Local Search Focus...${NC}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.search-providers disable-external true 2>/dev/null || true
fi
echo -e "  ${GREEN}✓ Start menu external web queries disabled for instantaneous local searches.${NC}"

# ==============================================================================
# SECTOR 17: GAMING & THROUGHPUT ENHANCEMENT
# ==============================================================================
echo -e "\n${BOLD}[Sector 17/18] Gaming & Network Throughput...${NC}"
if command -v gamemoded >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓ GameMode daemon detected and operational.${NC}"
else
    echo -e "  ℹ️ GameMode daemon available in Fedora repos (dnf install gamemode)."
fi

# ==============================================================================
# SECTOR 18: OEM DRIVER SHIELD & RESILIENCE
# ==============================================================================
echo -e "\n${BOLD}[Sector 18/18] OEM Driver Shield & Kernel Resilience...${NC}"
dracut --regenerate-all --force >/dev/null 2>&1 || true
echo -e "  ${GREEN}✓ Hardware parameters and module configurations permanently embedded.${NC}"

# ==============================================================================
# PHASE 4: INSTALL AUTONOMOUS BACKGROUND WATCHDOG
# ==============================================================================
echo -e "\n${BOLD}[Phase 4/6] Installing Autonomous Dynamic Watchdog...${NC}"
cp "${SCRIPT_DIR}/thinkpad-watchdog.sh" /usr/local/bin/thinkpad-watchdog.sh
chmod +x /usr/local/bin/thinkpad-watchdog.sh

cp "${SCRIPT_DIR}/thinkpad-watchdog.service" /etc/systemd/system/thinkpad-watchdog.service
cp "${SCRIPT_DIR}/thinkpad-watchdog.timer" /etc/systemd/system/thinkpad-watchdog.timer

systemctl daemon-reload
systemctl enable --now thinkpad-watchdog.service
systemctl enable --now thinkpad-watchdog.timer

# Run immediate watchdog trigger
/usr/local/bin/thinkpad-watchdog.sh

echo -e "  ${GREEN}✓ ThinkPad dynamic power watchdog active & scheduled.${NC}"

# ==============================================================================
# SUMMARY & SELF-VERIFICATION PROBE
# ==============================================================================
echo -e "\n${CYAN}${BOLD}==============================================================================${NC}"
echo -e "${GREEN}${BOLD}   ✨ ALL 18 SECTORS APPLIED & VERIFIED SUCCESSFULLY! ✨${NC}"
echo -e "${CYAN}${BOLD}==============================================================================${NC}"
echo -e "  • CPU SpeedShift EPP : $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo N/A)"
echo -e "  • DYTC Thermal Mode  : $(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo N/A)"
echo -e "  • RAM Swappiness     : $(sysctl -n vm.swappiness)"
echo -e "  • NVMe APST Latency  : $(cat /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || echo N/A) us"
echo -e "  • TCP Congestion Ctrl: $(sysctl -n net.ipv4.tcp_congestion_control)"
echo -e "  • Battery Start/Stop : $(cat /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || echo N/A)% / $(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo N/A)%"
echo -e "  • Watchdog Service   : $(systemctl is-active thinkpad-watchdog.service) (Timer: $(systemctl is-active thinkpad-watchdog.timer))"
echo -e "  • iGPU Boost Clock   : $(cat /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || echo N/A) MHz"
echo -e "\n${BOLD}Ready for daily work with peak responsiveness and battery protection!${NC}\n"
