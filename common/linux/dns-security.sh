#!/usr/bin/env bash
# DNS Security — Block malware, adult content, phishing
# Works on ALL Linux distros (Fedora, Ubuntu, Debian, Arch, openSUSE, etc.)
set -euo pipefail

echo "🛡️ Configuring DNS Security..."

# Method 1: systemd-resolved (Fedora, Ubuntu 18+, Arch, etc.)
if systemctl is-active systemd-resolved &>/dev/null || systemctl is-enabled systemd-resolved &>/dev/null; then
    mkdir -p /etc/systemd/resolved.conf.d
    cat > /etc/systemd/resolved.conf.d/dns-security.conf << 'EOF'
[Resolve]
# CleanBrowsing Family Filter — blocks malware + adult + phishing
DNS=185.228.168.168#family-filter-dns.cleanbrowsing.org
DNS=185.228.169.168#family-filter-dns.cleanbrowsing.org
DNS=2a0d:2a00:1::1#family-filter-dns.cleanbrowsing.org
DNS=2a0d:2a00:2::1#family-filter-dns.cleanbrowsing.org
# Fallback: Cloudflare Family
FallbackDNS=1.1.1.3#family.cloudflare-dns.com
FallbackDNS=1.0.0.3#family.cloudflare-dns.com
DNSOverTLS=opportunistic
DNSSEC=allow-downgrade
Domains=~.
EOF
    systemctl enable --now systemd-resolved 2>/dev/null || true
    systemctl restart systemd-resolved
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
    echo "✔ DNS Security active via systemd-resolved"

# Method 2: NetworkManager
elif [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/dns-security.conf << 'EOF'
[global-dns-domain-*]
servers=185.228.168.168,185.228.169.168,1.1.1.3,1.0.0.3
EOF
    systemctl restart NetworkManager 2>/dev/null || true
    echo "✔ DNS Security active via NetworkManager"

# Method 3: Direct resolv.conf (Alpine, minimal installs)
else
    cp -a /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true
    cat > /etc/resolv.conf << 'EOF'
# Device-Base-Optimization — DNS Security
nameserver 185.228.168.168
nameserver 185.228.169.168
nameserver 1.1.1.3
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true
    echo "✔ DNS Security active via resolv.conf"
fi

echo "✔ Malware + adult content blocked via CleanBrowsing Family Filter"
echo ""
echo "Test: dig +short example.com (should resolve)"
echo "Test: dig +short pornhub.com (should return 0.0.0.0 or fail)"
