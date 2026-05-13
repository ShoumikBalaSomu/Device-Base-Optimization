#!/usr/bin/env bash
# System Cleanup — Remove unnecessary services, free resources
# Works on ALL Linux distros
set -euo pipefail

echo "🧹 Running System Cleanup..."

# Disable unnecessary services (gracefully — only if they exist)
OPTIONAL_DISABLE=(
    "ModemManager.service"
    "avahi-daemon.service"
    "packagekit.service"
)
for svc in "${OPTIONAL_DISABLE[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null; then
        systemctl disable --now "$svc" 2>/dev/null || true
        echo "  Disabled: $svc"
    fi
done

# Clean package cache — per distro
if command -v dnf &>/dev/null; then
    dnf autoremove -y 2>/dev/null || true
    dnf clean all 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    apt-get autoremove -y 2>/dev/null || true
    apt-get autoclean -y 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -Sc --noconfirm 2>/dev/null || true
elif command -v zypper &>/dev/null; then
    zypper clean --all 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk cache clean 2>/dev/null || true
fi

# Trim journal logs (systemd)
journalctl --vacuum-size=100M 2>/dev/null || true

# Clear temp files
rm -rf /tmp/device-optimization-* 2>/dev/null || true

echo "✔ Unnecessary services disabled"
echo "✔ Package cache + logs cleaned"
