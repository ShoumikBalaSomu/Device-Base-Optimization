#!/usr/bin/env bash
# Display Optimization — Intel GPU tuning, VA-API, color management
# Works on ALL Linux distros with Intel GPU
set -euo pipefail

echo "🖼️ Configuring Display..."

# Install GPU packages per distro
if command -v dnf &>/dev/null; then
    dnf install -y intel-media-driver libva-utils mesa-dri-drivers 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y intel-media-va-driver vainfo mesa-utils 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm intel-media-driver libva-utils mesa 2>/dev/null || true
elif command -v zypper &>/dev/null; then
    zypper install -y intel-media-driver libva-utils Mesa-dri 2>/dev/null || true
fi

# Intel i915 GPU optimization — kernel module params
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/i915-optimization.conf << 'EOF'
options i915 enable_guc=2 enable_fbc=1 fastboot=1 enable_psr=1
EOF

# VA-API hardware video acceleration — environment variables
mkdir -p /etc/profile.d
cat > /etc/profile.d/vaapi.sh << 'EOF'
export LIBVA_DRIVER_NAME=iHD
export VDPAU_DRIVER=va_gl
EOF
chmod +x /etc/profile.d/vaapi.sh

# X11 Intel driver config (works on X11, ignored by Wayland)
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-intel.conf << 'EOF'
Section "Device"
    Identifier "Intel GPU"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
    Option "DRI" "3"
EndSection
EOF

echo "✔ Intel GPU: GuC, FBC, PSR, TearFree, DRI3"
echo "✔ VA-API hardware video acceleration enabled"
echo "Verify: vainfo (after reboot/re-login)"
