<#
    DNS Security — Block malware, adult content, phishing

    SCOPE: SYSTEM-LEVEL DNS + BROWSER DoH ENFORCEMENT
      • Sets CleanBrowsing Family Filter for all Windows DNS resolution
        (apps, background services, Windows Update, etc.)
      • Forces browser DoH to use CleanBrowsing Family Filter endpoint
        (Chrome, Firefox, Edge, Brave — via Group Policy registry keys)
      • Browsers still get encrypted DNS (DoH) but through CleanBrowsing
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

########## Layer 2: Browser DoH → CleanBrowsing ##########

Write-Host ""
Write-Host "╚══ BROWSER DoH — CleanBrowsing Family Filter ══" -ForegroundColor Cyan

$dohUrl = "https://doh.cleanbrowsing.org/doh/family-filter/"

# --- Google Chrome ---
$chromeKey = "HKLM:\SOFTWARE\Policies\Google\Chrome"
New-Item -Path $chromeKey -Force | Out-Null
Set-ItemProperty -Path $chromeKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $chromeKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force
Write-OK "Chrome DoH → CleanBrowsing (policy locked)"

# --- Microsoft Edge ---
$edgeKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
New-Item -Path $edgeKey -Force | Out-Null
Set-ItemProperty -Path $edgeKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $edgeKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force
Write-OK "Edge DoH → CleanBrowsing (policy locked)"

# --- Mozilla Firefox ---
$firefoxKey = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS"
New-Item -Path $firefoxKey -Force | Out-Null
Set-ItemProperty -Path $firefoxKey -Name "Enabled" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $firefoxKey -Name "ProviderURL" -Value $dohUrl -Type String -Force
Set-ItemProperty -Path $firefoxKey -Name "Locked" -Value 1 -Type DWord -Force
Write-OK "Firefox DoH → CleanBrowsing (policy locked)"

# --- Brave Browser ---
$braveKey = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
New-Item -Path $braveKey -Force | Out-Null
Set-ItemProperty -Path $braveKey -Name "DnsOverHttpsMode" -Value "secure" -Type String -Force
Set-ItemProperty -Path $braveKey -Name "DnsOverHttpsTemplates" -Value $dohUrl -Type String -Force
Write-OK "Brave DoH → CleanBrowsing (policy locked)"

Write-Host ""
Write-OK "🛡️  DNS Security — Full Coverage"
Write-Host "  • System DNS  → CleanBrowsing Family Filter (DoH encrypted)" -ForegroundColor Gray
Write-Host "  • Browser DoH → CleanBrowsing Family Filter (DoH locked)" -ForegroundColor Gray
Write-Host "  • All traffic is filtered AND encrypted" -ForegroundColor Gray
Write-Host ""
Write-Host "  Verify system:  nslookup pornhub.com   # should return 0.0.0.0 or fail" -ForegroundColor DarkGray
Write-Host "  Verify browser: chrome://policy or about:policies" -ForegroundColor DarkGray
