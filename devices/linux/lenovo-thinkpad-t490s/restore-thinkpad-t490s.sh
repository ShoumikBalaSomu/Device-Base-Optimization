#!/usr/bin/env bash
# ==============================================================================
# ThinkPad T490s 1-Click Rollback Script
# Reverts all 21 sectors to stock Fedora / Lenovo defaults
# Repository: ShoumikBalaSomu/Device-Base-Optimization
# ==============================================================================
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Requesting administrative privileges (sudo)..."
    exec sudo bash "$0" "$@"
fi

echo "Reverting ThinkPad T490s optimizations to stock defaults..."

# 1. Stop and disable watchdog service & timer
systemctl disable --now thinkpad-watchdog.service thinkpad-watchdog.timer 2>/dev/null || true
rm -f /etc/systemd/system/thinkpad-watchdog.service /etc/systemd/system/thinkpad-watchdog.timer
rm -f /usr/local/bin/thinkpad-watchdog.sh
rm -f /usr/local/bin/thinkpad-charge-mode
systemctl daemon-reload

# 2. Remove configuration files
rm -f /etc/sysctl.d/99-thinkpad-t490s-performance.conf
rm -f /etc/modprobe.d/nvme-thinkpad.conf
rm -f /etc/modprobe.d/i915-thinkpad.conf
rm -f /etc/modprobe.d/thinkpad_acpi.conf
rm -f /etc/modprobe.d/uvcvideo-thinkpad.conf
rm -f /etc/modprobe.d/snd-hda-intel-thinkpad.conf
rm -f /etc/modules-load.d/bbr.conf
rm -f /etc/environment.d/10-mesa-shader.conf
rm -f /etc/environment.d/20-intel-vaapi.conf
rm -f /etc/systemd/resolved.conf.d/00-cloudflare-family.conf
rm -f /etc/pipewire/pipewire.conf.d/10-high-fidelity.conf
rm -f /etc/pipewire/pipewire.conf.d/20-latency-lock.conf
rm -f /etc/wireplumber/wireplumber.conf.d/99-disable-ducking.conf
rm -f /etc/udev/rules.d/99-thinkpad-battery-thresholds.rules
rm -f /etc/udev/rules.d/99-thinkpad-camera.rules
rm -f /etc/thinkpad-charge-mode.conf
rm -f /etc/opt/chrome/policies/managed/default_managed_policy.json
rm -f /etc/chromium/policies/managed/default_managed_policy.json
rm -f /etc/firefox/policies/policies.json

# 3. Reload services & sysctl
systemctl unmask fprintd.service pcscd.service pcscd.socket switcheroo-control.service ModemManager.service hibernate.target hybrid-sleep.target 2>/dev/null || true
sysctl --system >/dev/null 2>&1 || true
systemctl restart systemd-resolved 2>/dev/null || true
udevadm control --reload-rules 2>/dev/null || true

# 4. Reset battery threshold to full charge
if [[ -f /sys/class/power_supply/BAT0/charge_control_start_threshold ]]; then
    echo 0 > /sys/class/power_supply/BAT0/charge_control_start_threshold 2>/dev/null || true
fi
if [[ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]]; then
    echo 100 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
fi

# 5. Reset GNOME desktop settings to Fedora defaults
REAL_USER="${SUDO_USER:-$USER}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.interface font-antialiasing 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.interface font-hinting 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.mouse accel-profile 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.touchpad accel-profile 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.touchpad speed 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.touchpad tap-to-click 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.touchpad natural-scroll 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.keyboard delay 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.peripherals.keyboard repeat-interval 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.privacy report-technical-problems 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.privacy send-software-usage-stats 2>/dev/null || true
    sudo -u "$REAL_USER" gsettings reset org.gnome.desktop.search-providers disable-external 2>/dev/null || true
fi

# 6. Check Btrfs snapshots
if [[ -d /.snapshots ]]; then
    echo -e "\nAvailable Btrfs safety snapshots:"
    ls -la /.snapshots
fi

echo -e "\n✓ All settings reverted to stock Fedora Linux defaults successfully."
