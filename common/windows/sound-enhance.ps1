<# Sound Enhancement — Audio priority + Dolby Atmos #>
Write-Host "🔊 Configuring Sound..."

# Maximize audio thread priority
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10 -Type DWord -Force
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "Scheduling Category" -Value "High" -Type String -Force

# Enable Dolby services
@("DolbyDAXAPI") | ForEach-Object {
    $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
    if ($s) { Set-Service -Name $_ -StartupType Automatic; Start-Service $_ -ErrorAction SilentlyContinue }
}

Write-Host "✔ Audio priority maximized + Dolby Atmos enabled"
