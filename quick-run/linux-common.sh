#!/usr/bin/env bash
###############################################################################
# Device-Base-Optimization — Common Linux Optimizations
# Works on: Fedora, Ubuntu/Debian, Arch, openSUSE, RHEL, CentOS, Mint, etc.
# Run as root: curl -fsSL <url> | sudo bash
#
# FIXED:
#   • earlyoom conflict → systemd-oomd (Fedora 41+ default)
#   • sysctl.conf deprecated → sysctl.d drop-in (idempotent)
#   • power-profiles-daemon conflict → detect & disable
#   • Browser DoH → CleanBrowsing via managed policies
###############################################################################
set -euo pipefail

BACKUP_DIR="/opt/device-optimization/backups/$(date +%Y%m%d_%H%M%S)"
LOG="/var/log/device-optimization.log"
SYSCTL_DROP="/etc/sysctl.d/99-optimization.conf"
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG") 2>&1

banner() { echo -e "\n\033[1;36m══════════════════════════════════════\033[0m"; echo -e "\033[1;33m  $1\033[0m"; echo -e "\033[1;36m══════════════════════════════════════\033[0m\n"; }
ok()     { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn()   { echo -e "\033[1;33m  ⚠ $1\033[0m"; }
fail()   { echo -e "\033[1;31m  ✘ $1\033[0m"; }
backup_file() { [ -f "$1" ] && cp -a "$1" "$BACKUP_DIR/$(basename "$1").bak" && ok "Backed up $1"; }

# Idempotent sysctl writer — writes to /etc/sysctl.d/ (not deprecated sysctl.conf)
sysctl_set() {
    local key="$1" val="$2"
    if ! grep -q "^${key}" "$SYSCTL_DROP" 2>/dev/null; then
        echo "${key} = ${val}" >> "$SYSCTL_DROP"
    fi
}

###############################################################################
# DISTRO DETECTION — universal package manager
###############################################################################
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_NAME="${PRETTY_NAME:-$ID}"
        DISTRO_FAMILY="${ID_LIKE:-$ID}"
    elif [ -f /etc/redhat-release ]; then
        DISTRO_ID="rhel"
        DISTRO_NAME="$(cat /etc/redhat-release)"
        DISTRO_FAMILY="rhel fedora"
    else
        DISTRO_ID="unknown"
        DISTRO_NAME="Unknown Linux"
        DISTRO_FAMILY="unknown"
    fi
    export DISTRO_ID DISTRO_NAME DISTRO_FAMILY
}

# Universal package install function
pkg_install() {
    local packages="$*"
    if command -v dnf &>/dev/null; then
        dnf install -y $packages 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq 2>/dev/null || true
        apt-get install -y $packages 2>/dev/null || true
    elif command -v pacman &>/dev/null; then
        pacman -Sy --noconfirm $packages 2>/dev/null || true
    elif command -v zypper &>/dev/null; then
        zypper install -y $packages 2>/dev/null || true
    elif command -v apk &>/dev/null; then
        apk add $packages 2>/dev/null || true
    else
        warn "Unknown package manager — install manually: $packages"
    fi
}

# Universal system upgrade
pkg_upgrade() {
    if command -v dnf &>/dev/null; then
        dnf upgrade -y --refresh 2>/dev/null || dnf upgrade -y
    elif command -v apt-get &>/dev/null; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq && apt-get upgrade -y
    elif command -v pacman &>/dev/null; then
        pacman -Syu --noconfirm
    elif command -v zypper &>/dev/null; then
        zypper refresh && zypper update -y
    elif command -v apk &>/dev/null; then
        apk update && apk upgrade
    fi
}

# Universal cleanup
pkg_cleanup() {
    if command -v dnf &>/dev/null; then
        dnf autoremove -y 2>/dev/null || true
        dnf clean all 2>/dev/null || true
    elif command -v apt-get &>/dev/null; then
        apt-get autoremove -y 2>/dev/null || true
        apt-get autoclean -y 2>/dev/null || true
    elif command -v pacman &>/dev/null; then
        pacman -Sc --noconfirm 2>/dev/null || true
    elif command -v zypper &>/dev/null; then
        zypper clean --all 2>/dev/null || true
    elif command -v apk &>/dev/null; then
        apk cache clean 2>/dev/null || true
    fi
}

# Map package names per distro (handles naming differences)
# FIX: Removed earlyoom — conflicts with systemd-oomd on Fedora 41+
map_packages() {
    local category="$1"
    case "$category" in
        core)
            if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
                echo "tuned tuned-utils irqbalance thermald powertop tlp tlp-rdw firewalld hdparm"
            elif command -v apt-get &>/dev/null; then
                echo "tuned irqbalance thermald powertop tlp firewalld hdparm"
            elif command -v pacman &>/dev/null; then
                echo "irqbalance thermald powertop tlp firewalld hdparm"
            elif command -v zypper &>/dev/null; then
                echo "tuned irqbalance thermald powertop tlp firewalld hdparm"
            else
                echo "irqbalance powertop tlp firewalld hdparm"
            fi
            ;;
        audio)
            if command -v dnf &>/dev/null; then
                echo "pipewire pipewire-pulseaudio wireplumber"
            elif command -v apt-get &>/dev/null; then
                echo "pipewire pipewire-pulse wireplumber"
            elif command -v pacman &>/dev/null; then
                echo "pipewire pipewire-pulse wireplumber"
            elif command -v zypper &>/dev/null; then
                echo "pipewire pipewire-pulseaudio wireplumber"
            else
                echo "pipewire wireplumber"
            fi
            ;;
        gpu)
            if command -v dnf &>/dev/null; then
                echo "intel-media-driver libva-utils mesa-dri-drivers"
            elif command -v apt-get &>/dev/null; then
                echo "intel-media-va-driver vainfo mesa-utils"
            elif command -v pacman &>/dev/null; then
                echo "intel-media-driver libva-utils mesa"
            elif command -v zypper &>/dev/null; then
                echo "intel-media-driver libva-utils Mesa-dri"
            else
                echo "libva-utils"
            fi
            ;;
    esac
}

###############################################################################
detect_distro
banner "DEVICE-BASE-OPTIMIZATION — Universal Linux"
echo "  Detected: $DISTRO_NAME ($DISTRO_ID)"
echo ""
###############################################################################

banner "1/8 — SYSTEM UPDATE & PACKAGES"
pkg_upgrade
pkg_install $(map_packages core)
pkg_install $(map_packages audio)
pkg_install $(map_packages gpu)
ok "System updated & packages installed on $DISTRO_ID"

banner "2/8 — CPU & PERFORMANCE"
systemctl enable --now irqbalance 2>/dev/null || true
# tuned — available on most distros
if command -v tuned-adm &>/dev/null; then
    systemctl enable --now tuned 2>/dev/null || true
    tuned-adm profile balanced 2>/dev/null || true
    ok "tuned → balanced profile"
fi

# FIX: Use tuned-ppd as bridge (provides power-profiles-daemon D-Bus API via tuned)
# This lets GNOME/KDE power mode switching work with tuned profiles
pkg_install tuned-ppd 2>/dev/null || true
if systemctl list-unit-files tuned-ppd.service &>/dev/null 2>&1; then
    # tuned-ppd available — it replaces power-profiles-daemon's D-Bus API
    if systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
        systemctl disable --now power-profiles-daemon 2>/dev/null || true
    fi
    # Unmask if previously masked by our script
    systemctl unmask power-profiles-daemon 2>/dev/null || true
    systemctl enable --now tuned-ppd 2>/dev/null || true
    ok "tuned-ppd bridge active (GUI power modes → tuned profiles)"
else
    # No tuned-ppd — keep power-profiles-daemon if present
    warn "tuned-ppd not available — power-profiles-daemon untouched"
fi

# FIX: Use systemd-oomd instead of earlyoom (Fedora 41+ default OOM daemon)
# earlyoom polls memory at intervals — running both causes conflicts / kill storms
if systemctl is-active --quiet earlyoom 2>/dev/null; then
    warn "Disabling earlyoom (conflicts with systemd-oomd)"
    systemctl disable --now earlyoom 2>/dev/null || true
fi
# Enable systemd-oomd (uses PSI — Pressure Stall Information)
if systemctl list-unit-files systemd-oomd.service &>/dev/null; then
    systemctl enable --now systemd-oomd 2>/dev/null || true
    ok "systemd-oomd enabled (PSI-based OOM protection)"
else
    # Fallback: earlyoom for older distros without systemd-oomd
    if command -v earlyoom &>/dev/null; then
        systemctl enable --now earlyoom 2>/dev/null || true
        ok "earlyoom enabled (fallback — no systemd-oomd available)"
    else
        warn "No OOM daemon available — install systemd-oomd or earlyoom"
    fi
fi

# FIX: Use sysctl.d drop-in instead of deprecated /etc/sysctl.conf
backup_file /etc/sysctl.conf
touch "$SYSCTL_DROP"
sysctl_set vm.swappiness                 10
sysctl_set vm.dirty_ratio                15
sysctl_set vm.dirty_background_ratio     5
sysctl_set vm.vfs_cache_pressure         50
sysctl_set fs.inotify.max_user_watches   524288
sysctl_set fs.inotify.max_user_instances 1024
sysctl --system 2>/dev/null || true
ok "CPU + kernel sysctl tuned (via sysctl.d drop-in)"

banner "3/8 — NETWORK (TCP BBR)"
# FIX: Use sysctl.d drop-in for network settings
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
sysctl_set net.ipv4.conf.all.accept_redirects   0
sysctl_set net.ipv6.conf.all.accept_redirects   0
sysctl --system 2>/dev/null || true
ok "TCP BBR + network hardening applied (via sysctl.d)"

banner "4/8 — DNS SECURITY (System-Level)"

## Layer 1: System DNS — CleanBrowsing Family Filter ##
if systemctl is-active systemd-resolved &>/dev/null || systemctl is-enabled systemd-resolved &>/dev/null; then
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/dns-security.conf << 'EOF'
[Resolve]
DNS=185.228.168.168#family-filter-dns.cleanbrowsing.org 185.228.169.168#family-filter-dns.cleanbrowsing.org
FallbackDNS=1.1.1.3#family.cloudflare-dns.com 1.0.0.3#family.cloudflare-dns.com
DNSOverTLS=opportunistic
DNSSEC=allow-downgrade
Domains=~.
EOF
    systemctl enable --now systemd-resolved 2>/dev/null || true
    systemctl restart systemd-resolved 2>/dev/null || true
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
    ok "System DNS → CleanBrowsing Family Filter (via systemd-resolved)"
elif [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    # Fallback: NetworkManager DNS
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/dns-security.conf << 'EOF'
[global-dns-domain-*]
servers=185.228.168.168,185.228.169.168,1.1.1.3,1.0.0.3
EOF
    systemctl restart NetworkManager 2>/dev/null || true
    ok "System DNS → CleanBrowsing Family Filter (via NetworkManager)"
else
    # Last resort: direct resolv.conf
    backup_file /etc/resolv.conf
    cat > /etc/resolv.conf << 'EOF'
# Device-Base-Optimization — DNS Security
nameserver 185.228.168.168
nameserver 185.228.169.168
nameserver 1.1.1.3
EOF
    # Prevent overwrite
    chattr +i /etc/resolv.conf 2>/dev/null || true
    ok "System DNS → CleanBrowsing Family Filter (via resolv.conf)"
fi

## Cleanup: Remove old browser DoH managed policies (user's choice now) ##
# Firefox — remove managed DoH policies
for dir in /etc/firefox/policies /usr/lib/firefox/distribution /usr/lib64/firefox/distribution; do
    if [ -f "$dir/policies.json" ] && grep -q "DNSOverHTTPS" "$dir/policies.json" 2>/dev/null; then
        rm -f "$dir/policies.json"
    fi
done 2>/dev/null || true

# Chrome / Chromium / Edge / Brave — remove managed DoH policies
for dir in /etc/opt/chrome/policies/managed /etc/chromium/policies/managed /etc/chromium-browser/policies/managed /etc/opt/edge/policies/managed /etc/brave/policies/managed; do
    [ -f "$dir/dns-security.json" ] && rm -f "$dir/dns-security.json"
done 2>/dev/null || true
ok "System DNS → CleanBrowsing | Browser DoH → user's choice"

banner "5/8 — SOUND (PipeWire + Above 100%)"
# PipeWire config — works on any distro with PipeWire
if command -v pipewire &>/dev/null || [ -d /etc/pipewire ]; then
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
    # Volume above 100% (up to 150%)
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
elif command -v pulseaudio &>/dev/null; then
    # Fallback for PulseAudio (older distros)
    backup_file /etc/pulse/daemon.conf
    mkdir -p /etc/pulse
    if ! grep -q "flat-volumes" /etc/pulse/daemon.conf 2>/dev/null; then
        cat >> /etc/pulse/daemon.conf << 'EOF'
### Device-Base-Optimization — Audio ###
default-sample-rate = 48000
alternate-sample-rate = 44100
flat-volumes = no
EOF
    fi
    ok "PulseAudio 48kHz configured (use PipeWire for 150% volume)"
else
    warn "No PipeWire or PulseAudio found — skipping audio config"
fi

banner "6/8 — DISPLAY (Intel GPU)"
# i915 module config — universal
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/i915-optimization.conf << 'EOF'
options i915 enable_guc=2 enable_fbc=1 fastboot=1 enable_psr=1
EOF

# VA-API env vars
mkdir -p /etc/profile.d
echo 'export LIBVA_DRIVER_NAME=iHD' > /etc/profile.d/vaapi.sh
echo 'export VDPAU_DRIVER=va_gl' >> /etc/profile.d/vaapi.sh
chmod +x /etc/profile.d/vaapi.sh
ok "Intel i915 GPU + VA-API acceleration"

banner "7/8 — FIREWALL"
if command -v firewall-cmd &>/dev/null; then
    systemctl enable --now firewalld 2>/dev/null || true
    firewall-cmd --set-default-zone=public 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    ok "firewalld active"
elif command -v ufw &>/dev/null; then
    ufw --force enable 2>/dev/null || true
    ufw default deny incoming 2>/dev/null || true
    ufw default allow outgoing 2>/dev/null || true
    ok "ufw firewall active"
elif command -v iptables &>/dev/null; then
    # Basic iptables rules
    iptables -P INPUT DROP 2>/dev/null || true
    iptables -P FORWARD DROP 2>/dev/null || true
    iptables -P OUTPUT ACCEPT 2>/dev/null || true
    iptables -A INPUT -i lo -j ACCEPT 2>/dev/null || true
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    ok "iptables basic firewall active"
else
    warn "No firewall tool found — install firewalld or ufw"
fi

banner "8/8 — CLEANUP"
pkg_cleanup
journalctl --vacuum-size=100M 2>/dev/null || true
ok "Cleaned"

banner "✅ COMMON OPTIMIZATIONS COMPLETE"
echo "  Distro:  $DISTRO_NAME"
echo "  Backup:  $BACKUP_DIR"
echo "  Sysctl:  $SYSCTL_DROP"
echo "  Log:     $LOG"
echo ""
echo "  🔄 Reboot recommended: sudo reboot"
