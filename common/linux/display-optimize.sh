#!/usr/bin/env bash
# Display Optimization — Intel GPU tuning, VA-API, color management
set -euo pipefail

echo "🖼️ Configuring Display..."

dnf install -y intel-media-driver libva-utils mesa-dri-drivers 2>/dev/null || true

# Intel i915 GPU optimization
cat > /etc/modprobe.d/i915-optimization.conf << 'EOF'
options i915 enable_guc=2 enable_fbc=1 fastboot=1 enable_psr=1
EOF

# VA-API hardware video acceleration
echo 'export LIBVA_DRIVER_NAME=iHD' > /etc/profile.d/vaapi.sh
echo 'export VDPAU_DRIVER=va_gl' >> /etc/profile.d/vaapi.sh

# X11 Intel driver
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
