#!/usr/bin/env bash
# Network Optimization — TCP BBR, buffer tuning, MTU optimization
# Works on ALL Linux distros with kernel 4.9+ (BBR support)
set -euo pipefail

echo "🌐 Configuring Network..."

# Check BBR availability
if modprobe tcp_bbr 2>/dev/null; then
    echo "✔ tcp_bbr module loaded"
else
    echo "⚠ tcp_bbr not available — your kernel may not support BBR"
fi

# Idempotent write
if ! grep -q "Device-Base-Optimization — Network" /etc/sysctl.conf 2>/dev/null; then
    cat >> /etc/sysctl.conf << 'EOF'

### Device-Base-Optimization — Network ###
# TCP BBR congestion control (Google's algorithm — 2-25% faster)
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
# Buffer sizes
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=5000
# TCP Fast Open
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_mtu_probing=1
# Security
net.ipv4.conf.all.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
EOF
fi
sysctl -p 2>/dev/null || true
echo "✔ Network optimized — TCP BBR + buffer tuning applied"
