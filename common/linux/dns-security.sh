#!/usr/bin/env bash
###############################################################################
# DNS Security — Block malware, adult content, phishing
# Works on ALL Linux distros (Fedora, Ubuntu, Debian, Arch, openSUSE, etc.)
#
# 3-LAYER DoH BYPASS DEFENSE:
#   Layer 1: System DNS  → systemd-resolved / NetworkManager / resolv.conf
#   Layer 2: Browser policies → lock DoH off in Firefox, Chrome, Chromium,
#                                Brave, Vivaldi (enterprise managed policy)
#   Layer 3: Canary domain → NXDOMAIN for use-application-dns.net in /etc/hosts
#                            (Firefox kill-switch) + hosts entries for DoH servers
###############################################################################
set -euo pipefail

ok()   { echo -e "\033[1;32m  ✔ $1\033[0m"; }
warn() { echo -e "\033[1;33m  ⚠ $1\033[0m"; }
banner() { echo -e "\n\033[1;36m[══ $1 ══]\033[0m"; }

###############################################################################
# LAYER 1: SYSTEM DNS (systemd-resolved / NetworkManager / resolv.conf)
###############################################################################
banner "LAYER 1 — SYSTEM DNS"

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
    ok "DNS Security active via systemd-resolved"

elif [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/dns-security.conf << 'EOF'
[global-dns-domain-*]
servers=185.228.168.168,185.228.169.168,1.1.1.3,1.0.0.3
EOF
    systemctl restart NetworkManager 2>/dev/null || true
    ok "DNS Security active via NetworkManager"

else
    cp -a /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true
    cat > /etc/resolv.conf << 'EOF'
# Device-Base-Optimization — DNS Security
nameserver 185.228.168.168
nameserver 185.228.169.168
nameserver 1.1.1.3
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true
    ok "DNS Security active via resolv.conf"
fi

###############################################################################
# LAYER 2: BROWSER ENTERPRISE POLICIES (disable built-in DoH in each browser)
# Without this, browsers bypass system DNS entirely via their own DoH!
###############################################################################
banner "LAYER 2 — BROWSER DoH POLICIES"

# ──────────────────────────────────────────────────────────────────────────────
# Firefox: DNSOverHTTPS Enabled=false + Locked=true via enterprise policies.json
# Works for: Firefox, Firefox ESR, Librewolf (same policy path)
# ──────────────────────────────────────────────────────────────────────────────
FF_POLICY='{
  "policies": {
    "DNSOverHTTPS": {
      "Enabled": false,
      "Locked": true
    }
  }
}'

# System-wide policy path (preferred — works for all users)
mkdir -p /etc/firefox/policies
echo "$FF_POLICY" > /etc/firefox/policies/policies.json
ok "Firefox: DoH disabled via /etc/firefox/policies/policies.json"

# Also write to Firefox ESR and common installation dirs if they exist
for FF_DIR in \
    /usr/lib/firefox/distribution \
    /usr/lib64/firefox/distribution \
    /usr/lib/firefox-esr/distribution \
    /opt/firefox/distribution; do
    if [ -d "$(dirname "$FF_DIR")" ]; then
        mkdir -p "$FF_DIR"
        echo "$FF_POLICY" > "$FF_DIR/policies.json"
    fi
done

# Flatpak Firefox (if installed)
FF_FLATPAK="/var/lib/flatpak/app/org.mozilla.firefox/current/active/files/lib/firefox/distribution"
if [ -d "$(dirname "$FF_FLATPAK")" ]; then
    mkdir -p "$FF_FLATPAK"
    echo "$FF_POLICY" > "$FF_FLATPAK/policies.json"
    ok "Firefox (Flatpak): DoH disabled"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Chrome / Chromium / Brave / Vivaldi: DnsOverHttpsMode=off managed policy
# Each browser reads from its own managed policy directory
# ──────────────────────────────────────────────────────────────────────────────
CHROME_POLICY='{"DnsOverHttpsMode": "off"}'

declare -A CHROMIUM_POLICY_DIRS=(
    ["Google Chrome"]="/etc/opt/chrome/policies/managed"
    ["Chromium"]="/etc/chromium/policies/managed"
    ["Brave"]="/etc/brave/policies/managed"
    ["Vivaldi"]="/etc/vivaldi/policies/managed"
    ["Microsoft Edge"]="/etc/opt/edge/policies/managed"
    ["Ungoogled Chromium"]="/etc/chromium/policies/managed"
)

for BROWSER in "${!CHROMIUM_POLICY_DIRS[@]}"; do
    DIR="${CHROMIUM_POLICY_DIRS[$BROWSER]}"
    mkdir -p "$DIR"
    echo "$CHROME_POLICY" > "$DIR/disable-doh.json"
    chmod 644 "$DIR/disable-doh.json"
    ok "$BROWSER: DoH disabled via $DIR/disable-doh.json"
done

###############################################################################
# LAYER 3: CANARY DOMAIN + /etc/hosts BLOCK (Firefox kill-switch fallback)
# Firefox checks use-application-dns.net at startup — if it resolves to 0.0.0.0
# or returns NXDOMAIN, Firefox auto-disables DoH. This catches cases where
# policy files are missing or the browser isn't managed.
###############################################################################
banner "LAYER 3 — CANARY DOMAIN + HOSTS BLOCK"

# Block Firefox's DoH canary domain — triggers automatic DoH disable
if ! grep -q 'use-application-dns.net' /etc/hosts; then
    cat >> /etc/hosts << 'EOF'

# Device-Base-Optimization — Firefox DoH kill-switch (canary domain)
# Firefox sees this as NXDOMAIN and automatically disables its built-in DoH
0.0.0.0  use-application-dns.net
EOF
    ok "Firefox canary domain blocked (DoH auto-disable)"
else
    ok "Firefox canary domain already in /etc/hosts"
fi

# Block the IP addresses of the most common public DoH resolvers in /etc/hosts
# This prevents DoH even if a browser ignores the policy (belt-and-suspenders)
DOH_BLOCK_COMMENT="# Device-Base-Optimization — DoH resolver block"
if ! grep -q 'DoH resolver block' /etc/hosts; then
    cat >> /etc/hosts << 'EOF'

# Device-Base-Optimization — DoH resolver block
# Blocks direct HTTPS connections to known public DoH providers
# so browsers cannot bypass system DNS even without policy enforcement
0.0.0.0  dns.google
0.0.0.0  dns64.dns.google
0.0.0.0  cloudflare-dns.com
0.0.0.0  mozilla.cloudflare-dns.com
0.0.0.0  doh.opendns.com
0.0.0.0  doh.familyshield.opendns.com
0.0.0.0  dns.nextdns.io
0.0.0.0  doh.cleanbrowsing.org
0.0.0.0  doh2.cleanbrowsing.org
0.0.0.0  freedns.controld.com
0.0.0.0  dns.quad9.net
0.0.0.0  dns10.quad9.net
0.0.0.0  doh.adguard.com
0.0.0.0  unfiltered.adguard-dns.com
EOF
    ok "Known DoH resolver hostnames blocked in /etc/hosts"
else
    ok "DoH resolver block already in /etc/hosts"
fi

echo ""
ok "🛡️  DNS Security: 3-layer protection active"
echo "  Layer 1: System DNS → CleanBrowsing Family (malware+adult blocked)"
echo "  Layer 2: Browser policies → DoH locked off (Firefox/Chrome/Brave/Vivaldi)"
echo "  Layer 3: Canary domain + hosts → DoH bypasses blocked at hostname level"
echo ""
echo "  Verify: dig +short use-application-dns.net   # must return 0.0.0.0"
echo "  Verify: dig +short pornhub.com               # must return 0.0.0.0 or fail"
echo "  Firefox: about:policies → check DNSOverHTTPS = false"
echo "  Chrome:  chrome://policy  → check DnsOverHttpsMode = off"
