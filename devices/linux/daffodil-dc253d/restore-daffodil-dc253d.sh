#!/usr/bin/env bash
# ==============================================================================
#  🔄 DAFFODIL DC253D FACTORY RESTORATION & ROLLBACK SCRIPT
#  Hardware Target: Daffodil Computers Ltd. DC253D (Intel Raptor Lake-U)
# ==============================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Requesting sudo privileges for rollback..."
    exec sudo bash "$0" "$@"
fi

echo "Rolling back Daffodil DC253D optimizations..."

# 1. Stop and disable watchdog services
systemctl stop daffodil-watchdog.timer daffodil-watchdog.service 2>/dev/null || true
systemctl disable daffodil-watchdog.timer daffodil-watchdog.service 2>/dev/null || true
rm -f /etc/systemd/system/daffodil-watchdog.service /etc/systemd/system/daffodil-watchdog.timer
rm -f /etc/udev/rules.d/99-daffodil-battery.rules
rm -f /usr/local/bin/daffodil-watchdog.sh /usr/local/bin/daffodil-charge-mode
rm -f /etc/daffodil-charge-mode.conf
systemctl daemon-reload
udevadm control --reload-rules 2>/dev/null || true

# 2. Remove sysctls
rm -f /etc/sysctl.d/99-daffodil-dc253d-performance.conf
sysctl --system >/dev/null 2>&1 || true

# 3. Remove modprobe & environment configs
rm -f /etc/modprobe.d/nvme-daffodil.conf
rm -f /etc/modprobe.d/i915-daffodil.conf
rm -f /etc/modprobe.d/audio-daffodil.conf
rm -f /etc/modprobe.d/uvcvideo-daffodil.conf
rm -f /etc/udev/rules.d/99-daffodil-camera.rules
rm -f /etc/environment.d/10-mesa-shader.conf
rm -f /etc/modules-load.d/bbr.conf

# 4. Remove resolved config
rm -f /etc/systemd/resolved.conf.d/00-cloudflare-family.conf
systemctl restart systemd-resolved 2>/dev/null || true

# 5. Remove audio & camera configs
rm -f /etc/pipewire/pipewire.conf.d/10-high-fidelity.conf
rm -f /etc/wireplumber/wireplumber.conf.d/99-disable-ducking.conf
rm -f /etc/wireplumber/wireplumber.conf.d/50-camera-priority.conf
rm -f /etc/pipewire/pipewire.conf.d/20-echo-cancel.conf

# 6. Re-enable default services
systemctl enable NetworkManager-wait-online.service 2>/dev/null || true

# 7. Restore kernel command line
if command -v grubby >/dev/null 2>&1; then
    grubby --update-kernel=ALL --remove-args="split_lock_mitigate=0 nowatchdog transparent_hugepage=madvise loglevel=3" >/dev/null 2>&1 || true
fi

echo "Rollback completed. A system reboot is recommended to restore all default kernel parameters."
