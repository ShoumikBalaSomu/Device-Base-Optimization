#!/usr/bin/env bash
# Network Optimization — TCP BBR, buffer tuning, MTU optimization
set -euo pipefail

echo "🌐 Configuring Network..."

cat >> /etc/sysctl.conf << 'EOF'
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
EOF

sysctl -p
echo "✔ Network optimized — TCP BBR + buffer tuning applied"
