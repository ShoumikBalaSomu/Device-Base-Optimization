<#
    DNS Security — Block malware, adult content, phishing

    SCOPE: SYSTEM-LEVEL DNS ONLY
      • Sets CleanBrowsing Family Filter for all Windows DNS resolution
        (apps, background services, Windows Update, etc.)
      • Browser DoH is LEFT TO THE USER'S CHOICE
        (users can configure Chrome/Firefox/Edge DoH to any provider they want)
      • Any previously deployed browser managed policies are cleaned up
#>

function Write-OK   { param($msg) Write-Host "  ✔ $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╚══ SYSTEM DNS — CleanBrowsing Family Filter ══" -ForegroundColor Cyan

########## Layer 1: System DNS (OS-level) ##########

# Set CleanBrowsing on all active network adapters
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex `
        -ServerAddresses @("185.228.168.168", "185.228.169.168", "1.1.1.3", "1.0.0.3")
    Write-OK "Adapter '$($adapter.Name)' → CleanBrowsing DNS"
}

# Enable Windows DoH and register CleanBrowsing as the DoH provider
$dnscacheKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
New-Item -Path $dnscacheKey -Force | Out-Null
Set-ItemProperty -Path $dnscacheKey -Name "EnableAutoDoh" -Value 2 -Type DWord -Force

netsh dns add encryption server=185.228.168.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=185.228.169.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=1.1.1.3 `
    dohtemplate=https://family.cloudflare-dns.com/dns-query 2>$null
netsh dns add encryption server=1.0.0.3 `
    dohtemplate=https://family.cloudflare-dns.com/dns-query 2>$null

ipconfig /flushdns | Out-Null
Write-OK "Windows system DoH → CleanBrowsing Family Filter"

########## Cleanup: Remove old browser DoH managed policies ##########
# Previously deployed policies locked browser DoH — now removed so users can choose

Write-Host ""
Write-Host "╚══ BROWSER DoH — Removing managed policies (user's choice now) ══" -ForegroundColor Cyan

# --- Google Chrome: Remove DoH policy keys ---
$chromeKey = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (Test-Path $chromeKey) {
    Remove-ItemProperty -Path $chromeKey -Name "DnsOverHttpsMode" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $chromeKey -Name "DnsOverHttpsTemplates" -ErrorAction SilentlyContinue
    Write-OK "Chrome DoH policy removed (user's choice)"
}

# --- Microsoft Edge: Remove DoH policy keys ---
$edgeKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (Test-Path $edgeKey) {
    Remove-ItemProperty -Path $edgeKey -Name "DnsOverHttpsMode" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $edgeKey -Name "DnsOverHttpsTemplates" -ErrorAction SilentlyContinue
    Write-OK "Edge DoH policy removed (user's choice)"
}

# --- Mozilla Firefox: Remove DoH policy keys ---
$firefoxKey = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS"
if (Test-Path $firefoxKey) {
    Remove-Item -Path $firefoxKey -Recurse -Force -ErrorAction SilentlyContinue
    Write-OK "Firefox DoH policy removed (user's choice)"
}

# --- Brave Browser: Remove DoH policy keys ---
$braveKey = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
if (Test-Path $braveKey) {
    Remove-ItemProperty -Path $braveKey -Name "DnsOverHttpsMode" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $braveKey -Name "DnsOverHttpsTemplates" -ErrorAction SilentlyContinue
    Write-OK "Brave DoH policy removed (user's choice)"
}

Write-Host ""
Write-OK "🛡️  DNS Security — System-Level Coverage"
Write-Host "  • System DNS  → CleanBrowsing Family Filter (DoH encrypted)" -ForegroundColor Gray
Write-Host "  • Browser DoH → user's choice (configure in browser settings)" -ForegroundColor Gray
Write-Host "  • System traffic is filtered AND encrypted" -ForegroundColor Gray
Write-Host "  • Users can set any DoH provider in their browser preferences" -ForegroundColor Gray
Write-Host ""
Write-Host "  Verify system:  nslookup pornhub.com   # should return 0.0.0.0 or fail" -ForegroundColor DarkGray
