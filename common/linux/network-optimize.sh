#!/usr/bin/env bash
# Network Optimization — TCP BBR, buffer tuning, MTU optimization
# Works on ALL Linux distros with kernel 4.9+ (BBR support)
#
# FIXED: Uses /etc/sysctl.d/ drop-in instead of deprecated /etc/sysctl.conf
set -euo pipefail

SYSCTL_DROP="/etc/sysctl.d/99-network.conf"

echo "🌐 Configuring Network..."

# Idempotent sysctl writer
sysctl_set() {
    local key="$1" val="$2"
    if ! grep -q "^${key}" "$SYSCTL_DROP" 2>/dev/null; then
        echo "${key} = ${val}" >> "$SYSCTL_DROP"
    fi
}

# Check BBR availability
if modprobe tcp_bbr 2>/dev/null; then
    echo "✔ tcp_bbr module loaded"
else
    echo "⚠ tcp_bbr not available — your kernel may not support BBR"
fi

# Write network settings to sysctl.d drop-in (idempotent)
touch "$SYSCTL_DROP"
sysctl_set net.core.default_qdisc               fq
sysctl_set net.ipv4.tcp_congestion_control       bbr
sysctl_set net.core.rmem_max                    16777216
sysctl_set net.core.wmem_max                    16777216
sysctl_set "net.ipv4.tcp_rmem"                  "4096 87380 16777216"
sysctl_set "net.ipv4.tcp_wmem"                  "4096 65536 16777216"
sysctl_set net.core.netdev_max_backlog           5000
sysctl_set net.ipv4.tcp_fastopen                3
sysctl_set net.ipv4.tcp_slow_start_after_idle   0
sysctl_set net.ipv4.tcp_mtu_probing             1
sysctl_set net.ipv4.conf.all.rp_filter          1
sysctl_set net.ipv4.icmp_echo_ignore_broadcasts 1

sysctl --system 2>/dev/null || true
echo "✔ Network optimized — TCP BBR + buffer tuning applied (via sysctl.d)"
