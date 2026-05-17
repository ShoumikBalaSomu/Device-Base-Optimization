<# Display Optimization — GPU scheduling + HDR + font rendering #>
Write-Host "🖼️ Configuring Display..."

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -Type DWord -Force

# Enable HDR
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\VideoSettings" -Name "EnableHDRForPlayback" -Value 1 -Type DWord -Force

# Install Dolby Vision & HEVC Extensions
Write-Host "🎬 Installing Dolby Vision & HEVC Extensions..."
winget install --id "9pltg1lwphlf" --source msstore --accept-package-agreements --accept-source-agreements --silent 2>$null
$winget1 = $LASTEXITCODE
winget install --id "9NMZLZ57R3T7" --source msstore --accept-package-agreements --accept-source-agreements --silent 2>$null

if ($winget1 -ne 0) {
    Write-Host "⚠ Winget failed to install Dolby Vision. Adding fallback Python tool..." -ForegroundColor Yellow
    $fallbackDir = "C:\DeviceOptimization\Scripts\DolbyVision"
    New-Item -Path $fallbackDir -ItemType Directory -Force | Out-Null
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/balu100/dolby-vision-for-windows/main/enable_dolby_vision_hdmi.py" -OutFile "$fallbackDir\enable_dolby_vision_hdmi.py" -UseBasicParsing
        Write-Host "✔ Fallback script downloaded to $fallbackDir\enable_dolby_vision_hdmi.py" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Failed to download fallback script." -ForegroundColor Red
    }
}

Write-Host "💡 Note: To fully enable Dolby Vision on non-supported monitors, refer to: https://github.com/balu100/dolby-vision-for-windows"

Write-Host "✔ GPU scheduling + HDR + Dolby Vision + ClearType optimized"
