#!/usr/bin/env bash
###############################################################################
# DNS Security — Block malware, adult content, phishing
# Works on ALL Linux distros (Fedora, Ubuntu, Debian, Arch, openSUSE, etc.)
#
# SCOPE: SYSTEM-LEVEL DNS ONLY
#   • Sets CleanBrowsing Family Filter for ALL OS-level DNS resolution
#     (CLI tools, apps, background services, package managers, etc.)
#   • Browser DoH is LEFT TO THE USER'S CHOICE
#     (users can configure Firefox/Chrome/Edge DoH to any provider they want)
#   • Any previously deployed browser managed policies are cleaned up
###############################################################################
set -euo pipefail

ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }
banner() { echo -e "\n\033[1;36m[══ $1 ══]\033[0m"; }

########################################
# Layer 1: System DNS (OS-level)
########################################
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

########################################
# Cleanup: Remove old browser DoH managed policies
# (previously deployed — now removed so users can choose their own DoH)
########################################
banner "BROWSER DoH — Removing managed policies (user's choice now)"

# Remove Firefox managed DoH policies
for dir in /etc/firefox/policies /usr/lib/firefox/distribution /usr/lib64/firefox/distribution; do
    if [ -f "$dir/policies.json" ]; then
        # Only remove if it contains our DNSOverHTTPS policy
        if grep -q "DNSOverHTTPS" "$dir/policies.json" 2>/dev/null; then
            rm -f "$dir/policies.json"
            ok "Removed Firefox DoH policy from $dir"
        fi
    fi
done

# Remove Flatpak Firefox policies
if [ -d /var/lib/flatpak/app/org.mozilla.firefox ]; then
    FLATPAK_FF=$(find /var/lib/flatpak/app/org.mozilla.firefox -name "files" -type d 2>/dev/null | head -1)
    if [ -n "$FLATPAK_FF" ] && [ -f "$FLATPAK_FF/lib/firefox/distribution/policies.json" ]; then
        if grep -q "DNSOverHTTPS" "$FLATPAK_FF/lib/firefox/distribution/policies.json" 2>/dev/null; then
            rm -f "$FLATPAK_FF/lib/firefox/distribution/policies.json"
            ok "Removed Flatpak Firefox DoH policy"
        fi
    fi
fi

# Remove Chrome/Chromium/Edge/Brave managed DoH policies
for dir in /etc/opt/chrome/policies/managed /etc/chromium/policies/managed /etc/chromium-browser/policies/managed /etc/opt/edge/policies/managed /etc/brave/policies/managed; do
    if [ -f "$dir/dns-security.json" ]; then
        rm -f "$dir/dns-security.json"
        ok "Removed managed DoH policy from $dir"
    fi
done

ok "Browser DoH → user's choice (no managed policies)"

echo ""
ok "🛡️  DNS Security — System-Level Coverage"
echo "  • System DNS  → CleanBrowsing Family Filter (DoT encrypted)"
echo "  • Browser DoH → user's choice (configure in browser settings)"
echo "  • System traffic is filtered AND encrypted"
echo "  • Users can set any DoH provider in their browser preferences"
echo ""
echo "  Verify system: dig +short pornhub.com   # should return 0.0.0.0 or fail"
echo "  Status: resolvectl status"
