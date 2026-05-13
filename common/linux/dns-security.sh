#!/usr/bin/env bash
###############################################################################
# DNS Security — Block malware, adult content, phishing
# Works on ALL Linux distros (Fedora, Ubuntu, Debian, Arch, openSUSE, etc.)
#
# SCOPE: SYSTEM-LEVEL DNS ONLY
#   • Sets CleanBrowsing Family Filter for ALL OS-level DNS resolution
#     (CLI tools, apps, background services, package managers, etc.)
#   • Browser DoH is intentionally NOT touched — users are free to use
#     any DoH provider (Cloudflare, Google, NextDNS, etc.) in their browser
###############################################################################
set -euo pipefail

ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }
banner() { echo -e "\n\033[1;36m[══ $1 ══]\033[0m"; }

banner "SYSTEM DNS — CleanBrowsing Family Filter"

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
    ok "System DNS → CleanBrowsing (via systemd-resolved + DoT)"

# Method 2: NetworkManager (distros without systemd-resolved)
elif [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/dns-security.conf << 'EOF'
[global-dns-domain-*]
servers=185.228.168.168,185.228.169.168,1.1.1.3,1.0.0.3
EOF
    systemctl restart NetworkManager 2>/dev/null || true
    ok "System DNS → CleanBrowsing (via NetworkManager)"

# Method 3: Direct resolv.conf (Alpine, minimal/embedded installs)
else
    cp -a /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true
    cat > /etc/resolv.conf << 'EOF'
# Device-Base-Optimization — DNS Security
nameserver 185.228.168.168
nameserver 185.228.169.168
nameserver 1.1.1.3
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true
    ok "System DNS → CleanBrowsing (via resolv.conf)"
fi

echo ""
ok "🛡️  System DNS → CleanBrowsing Family Filter"
echo "  • Malware, phishing, and adult content blocked at OS level"
echo "  • All apps, CLI tools, and system services use filtered DNS"
echo "  • Browser DoH: user's choice — not restricted by this script"
echo ""
echo "  Verify: dig +short pornhub.com   # should return 0.0.0.0 or fail"
echo "  Status: resolvectl status"
