<# DNS Security — Block malware, adult content, phishing #>
Write-Host "🛡️ Configuring DNS Security..."

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($adapter in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @("185.228.168.168","185.228.169.168")
}
# Enable DNS-over-HTTPS
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDoh" -Value 2 -Type DWord -Force

# Add CleanBrowsing as DoH provider
netsh dns add encryption server=185.228.168.168 dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null
netsh dns add encryption server=185.228.169.168 dohtemplate=https://doh.cleanbrowsing.org/doh/family-filter/ 2>$null

ipconfig /flushdns | Out-Null
Write-Host "✔ DNS → CleanBrowsing Family (malware+adult blocked, DoH enabled)"
