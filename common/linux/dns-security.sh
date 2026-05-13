#!/usr/bin/env bash
# DNS Security — Block malware, adult content, phishing via CleanBrowsing + Cloudflare Family
# Works on all Fedora devices
set -euo pipefail

echo "🛡️ Configuring DNS Security..."

mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dns-security.conf << 'EOF'
[Resolve]
# Primary: CleanBrowsing Family Filter (blocks malware + adult + phishing)
DNS=185.228.168.168#family-filter-dns.cleanbrowsing.org
DNS=185.228.169.168#family-filter-dns.cleanbrowsing.org
# IPv6
DNS=2a0d:2a00:1::1#family-filter-dns.cleanbrowsing.org
DNS=2a0d:2a00:2::1#family-filter-dns.cleanbrowsing.org
# Fallback: Cloudflare Family (blocks malware + adult)
FallbackDNS=1.1.1.3#family.cloudflare-dns.com
FallbackDNS=1.0.0.3#family.cloudflare-dns.com
# Enable DNS-over-TLS
DNSOverTLS=opportunistic
DNSSEC=allow-downgrade
Domains=~.
EOF

systemctl restart systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true

echo "✔ DNS Security active — malware + adult content blocked"
echo "✔ DNS-over-TLS enabled for encrypted queries"
echo ""
echo "Test: resolvectl status"
echo "Verify: nslookup malware-test.cleanbrowsing.org (should fail)"
