<# Display Optimization — GPU scheduling + HDR + font rendering #>
Write-Host "🖼️ Configuring Display..."

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -Type DWord -Force

# Enable HDR
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings" -Name "EnableHDRForPlayback" -Value 1 -Type DWord -Force

Write-Host "✔ GPU scheduling + HDR + ClearType optimized"
