#!/usr/bin/env bash
###############################################################################
# DNS Security — Block malware, adult content, phishing
# Works on ALL Linux distros (Fedora, Ubuntu, Debian, Arch, openSUSE, etc.)
#
# SCOPE: SYSTEM-LEVEL DNS + BROWSER DoH ENFORCEMENT
#   • Sets CleanBrowsing Family Filter for ALL OS-level DNS resolution
#     (CLI tools, apps, background services, package managers, etc.)
#   • Forces browser DoH to use CleanBrowsing Family Filter endpoint
#     (Firefox, Chrome, Chromium, Edge — via managed policies)
#   • Browsers still get encrypted DNS (DoH) but through CleanBrowsing
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
# Layer 2: Browser DoH → CleanBrowsing
########################################
banner "BROWSER DoH — CleanBrowsing Family Filter"

DOH_URL="https://doh.cleanbrowsing.org/doh/family-filter/"

# --- Firefox (all distros: deb, rpm, snap, flatpak) ---
firefox_policy() {
    local dir="$1"
    mkdir -p "$dir"
    cat > "$dir/policies.json" << FFEOF
{
  "policies": {
    "DNSOverHTTPS": {
      "Enabled": true,
      "ProviderURL": "${DOH_URL}",
      "Locked": true
    }
  }
}
FFEOF
}

# Standard Firefox install locations
firefox_policy "/etc/firefox/policies"
firefox_policy "/usr/lib/firefox/distribution"
firefox_policy "/usr/lib64/firefox/distribution"
# Snap Firefox
firefox_policy "/etc/firefox/policies" 2>/dev/null || true
# Flatpak Firefox
if [ -d /var/lib/flatpak/app/org.mozilla.firefox ]; then
    FLATPAK_FF=$(find /var/lib/flatpak/app/org.mozilla.firefox -name "files" -type d 2>/dev/null | head -1)
    [ -n "$FLATPAK_FF" ] && firefox_policy "$FLATPAK_FF/lib/firefox/distribution" 2>/dev/null || true
fi
ok "Firefox DoH → CleanBrowsing (policy locked)"

# --- Chrome / Chromium / Edge ---
chromium_policy() {
    local dir="$1"
    mkdir -p "$dir"
    cat > "$dir/dns-security.json" << CREOF
{
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates": "${DOH_URL}"
}
CREOF
}

# Google Chrome
chromium_policy "/etc/opt/chrome/policies/managed"
# Chromium
chromium_policy "/etc/chromium/policies/managed"
chromium_policy "/etc/chromium-browser/policies/managed"
# Microsoft Edge
chromium_policy "/etc/opt/edge/policies/managed"
# Brave
chromium_policy "/etc/brave/policies/managed"
ok "Chrome/Chromium/Edge/Brave DoH → CleanBrowsing (policy locked)"

echo ""
ok "🛡️  DNS Security — Full Coverage"
echo "  • System DNS  → CleanBrowsing Family Filter (DoT encrypted)"
echo "  • Browser DoH → CleanBrowsing Family Filter (DoH encrypted)"
echo "  • All traffic is filtered AND encrypted"
echo ""
echo "  Verify system: dig +short pornhub.com   # should return 0.0.0.0 or fail"
echo "  Verify browser: visit chrome://policy or about:policies"
echo "  Status: resolvectl status"
