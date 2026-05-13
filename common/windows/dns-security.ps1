<#
    DNS Security — Block malware, adult content, phishing
    3-LAYER DoH BYPASS DEFENSE:
      Layer 1: System DNS  → Adapters + Windows DoH registry → CleanBrowsing
      Layer 2: Browser policies → lock DoH off in Chrome, Edge, Firefox, Brave
      Layer 3: Canary domain + hosts → Firefox kill-switch + DoH hostname block
#>

function Write-OK   { param($msg) Write-Host "  ✔ $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

###############################################################################
# LAYER 1: SYSTEM DNS + WINDOWS DOH
###############################################################################
Write-Host ""
Write-Host "╚══ LAYER 1 — SYSTEM DNS ══" -ForegroundColor Cyan

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex `
        -ServerAddresses @("185.228.168.168", "185.228.169.168", "1.1.1.3", "1.0.0.3")
}

# Enable Windows DoH and point it at CleanBrowsing
$dnscacheKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
New-Item -Path $dnscacheKey -Force | Out-Null
Set-ItemProperty -Path $dnscacheKey -Name "EnableAutoDoh" -Value 2 -Type DWord -Force

netsh dns add encryption server=185.228.168.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=185.228.169.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null

ipconfig /flushdns | Out-Null
Write-OK "System DNS → CleanBrowsing Family (malware+adult blocked, DoH enabled)"

###############################################################################
# LAYER 2: BROWSER ENTERPRISE POLICIES (disable built-in DoH)
# Without this, Chrome/Firefox use their OWN DoH and bypass system DNS!
###############################################################################
Write-Host ""
Write-Host "╚══ LAYER 2 — BROWSER DoH POLICIES ══" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────────────────
# Chrome / Edge / Brave — Chromium registry policy
# ─────────────────────────────────────────────────────────────────────────
$chromiumBrowsers = @{
    "Google Chrome" = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    "Microsoft Edge" = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    "Brave"         = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
    "Chromium"      = "HKLM:\SOFTWARE\Policies\Chromium"
    "Vivaldi"       = "HKLM:\SOFTWARE\Policies\Vivaldi"
}

foreach ($browser in $chromiumBrowsers.GetEnumerator()) {
    try {
        New-Item -Path $browser.Value -Force | Out-Null
        # DnsOverHttpsMode = off  — disables Secure DNS / DoH completely
        Set-ItemProperty -Path $browser.Value -Name "DnsOverHttpsMode" `
            -Value "off" -Type String -Force
        Write-OK "$($browser.Key): DoH disabled via registry policy"
    } catch {
        Write-Warn "$($browser.Key): Could not write registry policy (may not be installed)"
    }
}

# ─────────────────────────────────────────────────────────────────────────
# Firefox — enterprise policies.json (Locked=true prevents user override)
# ─────────────────────────────────────────────────────────────────────────
$ffPolicy = @"
{
  "policies": {
    "DNSOverHTTPS": {
      "Enabled": false,
      "Locked": true
    }
  }
}
"@

# Common Firefox installation paths on Windows
$ffDirs = @(
    "$env:ProgramFiles\Mozilla Firefox\distribution",
    "${env:ProgramFiles(x86)}\Mozilla Firefox\distribution",
    "$env:ProgramFiles\Firefox ESR\distribution"
)
foreach ($dir in $ffDirs) {
    if (Test-Path (Split-Path $dir -Parent)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Set-Content -Path "$dir\policies.json" -Value $ffPolicy -Encoding UTF8
        Write-OK "Firefox: DoH disabled via $dir\policies.json"
    }
}

# Also write Firefox registry policy (Windows-specific)
try {
    $ffRegKey = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"
    New-Item -Path $ffRegKey -Force | Out-Null
    # network.trr.mode 5 = disabled (user cannot override)
    $ffPrefKey = "$ffRegKey\Preferences"
    New-Item -Path $ffPrefKey -Force | Out-Null
    Set-ItemProperty -Path $ffPrefKey -Name "network.trr.mode" -Value 5 -Type DWord -Force
    Write-OK "Firefox: DoH disabled via registry (network.trr.mode=5)"
} catch {
    Write-Warn "Firefox registry policy: write failed (continuing)"
}

###############################################################################
# LAYER 3: CANARY DOMAIN + HOSTS BLOCK
# Firefox's kill-switch: blocks use-application-dns.net → auto-disables DoH
###############################################################################
Write-Host ""
Write-Host "╚══ LAYER 3 — CANARY DOMAIN + HOSTS BLOCK ══" -ForegroundColor Cyan

$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
$hostsContent = Get-Content $hostsFile -Raw -ErrorAction SilentlyContinue

# Firefox DoH canary domain kill-switch
if ($hostsContent -notmatch 'use-application-dns\.net') {
    $canaryBlock = @"

# Device-Base-Optimization - Firefox DoH kill-switch (canary domain)
# Firefox sees this and automatically disables its built-in DoH
0.0.0.0  use-application-dns.net
"@
    Add-Content -Path $hostsFile -Value $canaryBlock -Encoding ASCII
    Write-OK "Firefox canary domain blocked (DoH auto-disable)"
} else {
    Write-OK "Firefox canary domain already in hosts"
}

# Block known DoH provider hostnames
if ($hostsContent -notmatch 'DoH resolver block') {
    $dohBlock = @"

# Device-Base-Optimization - DoH resolver block
# Prevents browsers from reaching public DoH servers directly
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
"@
    Add-Content -Path $hostsFile -Value $dohBlock -Encoding ASCII
    Write-OK "Known DoH resolver hostnames blocked in hosts file"
} else {
    Write-OK "DoH resolver block already in hosts file"
}

ipconfig /flushdns | Out-Null
Write-Host ""
Write-OK "🛡️  DNS Security: 3-layer protection active"
Write-Host "  Layer 1: System DNS → CleanBrowsing Family (malware+adult blocked)" -ForegroundColor Gray
Write-Host "  Layer 2: Browser policies → DoH locked off (Chrome/Edge/Firefox/Brave)" -ForegroundColor Gray
Write-Host "  Layer 3: Canary domain + hosts → DoH bypasses blocked at hostname level" -ForegroundColor Gray
Write-Host ""
Write-Host "  Verify Firefox: about:policies → DNSOverHTTPS = false" -ForegroundColor DarkGray
Write-Host "  Verify Chrome:  chrome://policy  → DnsOverHttpsMode = off" -ForegroundColor DarkGray
Write-Host "  Verify Edge:    edge://policy    → DnsOverHttpsMode = off" -ForegroundColor DarkGray
