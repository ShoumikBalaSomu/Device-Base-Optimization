#!/usr/bin/env bash
# System Cleanup — Remove unnecessary services, free resources
set -euo pipefail

echo "🧹 Running System Cleanup..."

# Disable unnecessary services
DISABLE_SERVICES=(
    "bluetooth.service"       # re-enable if needed
    "cups.service"            # re-enable if printing needed
    "ModemManager.service"
    "avahi-daemon.service"
    "packagekit.service"
)
for svc in "${DISABLE_SERVICES[@]}"; do
    systemctl disable --now "$svc" 2>/dev/null || true
done

# Clean package cache
dnf autoremove -y 2>/dev/null || true
dnf clean all 2>/dev/null || true

# Trim journal logs
journalctl --vacuum-size=100M 2>/dev/null || true

# Clear temp files
rm -rf /tmp/* /var/tmp/* 2>/dev/null || true

echo "✔ Unnecessary services disabled"
echo "✔ Package cache + logs cleaned"
