#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — Common Fedora 44 Optimizations
# Safe for ALL devices. Run as root.
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization.log"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok() { echo -e "\033[1;32m  ✔ $1\033[0m"; }

backup_file() { [ -f "$1" ] && cp -a "$1" "$BACKUP_DIR/$(basename "$1").bak"; }

banner "1/8 — SYSTEM UPDATE"
dnf upgrade -y --refresh 2>/dev/null || dnf upgrade -y
dnf install -y tuned tuned-utils irqbalance earlyoom \
    pipewire pipewire-pulseaudio wireplumber \
    intel-media-driver libva-utils mesa-dri-drivers \
    thermald powertop tlp tlp-rdw firewalld 2>/dev/null || true
ok "System updated & packages installed"

banner "2/8 — CPU & PERFORMANCE"
systemctl enable --now tuned irqbalance earlyoom 2>/dev/null || true
tuned-adm profile balanced 2>/dev/null || true
backup_file /etc/sysctl.conf
cat >> /etc/sysctl.conf << 'EOF'
### Device-Base-Optimization — Performance ###
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5
vm.vfs_cache_pressure=50
fs.inotify.max_user_watches=524288
EOF
sysctl -p 2>/dev/null || true
ok "CPU governor + kernel sysctl tuned"

banner "3/8 — NETWORK (TCP BBR)"
cat >> /etc/sysctl.conf << 'EOF'
### Device-Base-Optimization — Network ###
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_mtu_probing=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.all.accept_redirects=0
net.ipv6.conf.all.accept_redirects=0
EOF
sysctl -p 2>/dev/null || true
ok "TCP BBR + network hardening applied"

banner "4/8 — DNS SECURITY (Block Malware & Adult)"
mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dns-security.conf << 'EOF'
[Resolve]
DNS=185.228.168.168#family-filter-dns.cleanbrowsing.org 185.228.169.168#family-filter-dns.cleanbrowsing.org
FallbackDNS=1.1.1.3#family.cloudflare-dns.com 1.0.0.3#family.cloudflare-dns.com
DNSOverTLS=opportunistic
DNSSEC=allow-downgrade
Domains=~.
EOF
systemctl restart systemd-resolved 2>/dev/null || true
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
ok "DNS → CleanBrowsing Family Filter (malware+adult blocked, DoT on)"

banner "5/8 — SOUND (PipeWire + Above 100%)"
mkdir -p /etc/pipewire/pipewire.conf.d /etc/wireplumber/wireplumber.conf.d
cat > /etc/pipewire/pipewire.conf.d/99-optimization.conf << 'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 ]
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
EOF
cat > /etc/wireplumber/wireplumber.conf.d/99-volume-above-100.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [ { node.name = "~alsa_output.*" } ]
    actions = {
      update-props = { volume.max = 1.5 }
    }
  }
]
EOF
ok "PipeWire 48kHz + volume up to 150%"

banner "6/8 — DISPLAY (Intel GPU)"
cat > /etc/modprobe.d/i915-optimization.conf << 'EOF'
options i915 enable_guc=2 enable_fbc=1 fastboot=1 enable_psr=1
EOF
echo 'export LIBVA_DRIVER_NAME=iHD' > /etc/profile.d/vaapi.sh
ok "Intel i915 GPU + VA-API acceleration"

banner "7/8 — FIREWALL"
systemctl enable --now firewalld 2>/dev/null || true
firewall-cmd --set-default-zone=public 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true
ok "Firewall active"

banner "8/8 — CLEANUP"
dnf autoremove -y 2>/dev/null || true
dnf clean all 2>/dev/null || true
journalctl --vacuum-size=100M 2>/dev/null || true
ok "Cleaned"

banner "✅ COMMON OPTIMIZATIONS COMPLETE"
echo "  Backup: $BACKUP_DIR | Log: $LOG"
echo "  🔄 Reboot recommended: sudo reboot"
