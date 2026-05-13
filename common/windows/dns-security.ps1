<#
    DNS Security — Block malware, adult content, phishing

    SCOPE: SYSTEM-LEVEL DNS ONLY
      • Sets CleanBrowsing Family Filter for all Windows DNS resolution
        (apps, background services, Windows Update, etc.)
      • Browser DoH is intentionally NOT touched — users are free to use
        any DoH provider (Cloudflare, Google, NextDNS, etc.) in their browser
#>

function Write-OK   { param($msg) Write-Host "  ✔ $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  ⚠ $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╚══ SYSTEM DNS — CleanBrowsing Family Filter ══" -ForegroundColor Cyan

# Set CleanBrowsing on all active network adapters
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex `
        -ServerAddresses @("185.228.168.168", "185.228.169.168", "1.1.1.3", "1.0.0.3")
    Write-OK "Adapter '$($adapter.Name)' → CleanBrowsing DNS"
}

# Enable Windows DoH and register CleanBrowsing as the DoH provider
# (This makes Windows itself use DoH to CleanBrowsing — not browser DoH)
$dnscacheKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
New-Item -Path $dnscacheKey -Force | Out-Null
Set-ItemProperty -Path $dnscacheKey -Name "EnableAutoDoh" -Value 2 -Type DWord -Force

netsh dns add encryption server=185.228.168.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=185.228.169.168 `
    dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null

ipconfig /flushdns | Out-Null
Write-OK "Windows system DoH → CleanBrowsing Family Filter"

Write-Host ""
Write-OK "🛡️  System DNS → CleanBrowsing Family Filter"
Write-Host "  • Malware, phishing, and adult content blocked at OS level" -ForegroundColor Gray
Write-Host "  • All apps and Windows services use filtered DNS" -ForegroundColor Gray
Write-Host "  • Browser DoH: user's choice — not restricted by this script" -ForegroundColor Gray
Write-Host ""
Write-Host "  Verify: nslookup pornhub.com   # should return 0.0.0.0 or fail" -ForegroundColor DarkGray
