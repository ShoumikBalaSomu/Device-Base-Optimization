#!/usr/bin/env bash
# ==============================================================================
# ThinkPad T490s Battery Charging Mode Switcher
# Repository: ShoumikBalaSomu/Device-Base-Optimization
# Device: Lenovo ThinkPad T490s (20NYS64T00)
#
# Usage:
#   thinkpad-charge-mode full     -> Charge to 100% (Continuous lightning bolt icon)
#   thinkpad-charge-mode protect  -> Battery health guard (Stops at 80%)
#   thinkpad-charge-mode status   -> Display current thresholds & charging state
# ==============================================================================
set -euo pipefail

ACTION="${1:-status}"

BAT_START="/sys/class/power_supply/BAT0/charge_control_start_threshold"
BAT_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"
CONFIG_FILE="/etc/thinkpad-charge-mode.conf"

send_notification() {
    local title="$1"
    local msg="$2"
    local real_user="${SUDO_USER:-$USER}"
    if [[ -n "$real_user" && "$real_user" != "root" ]]; then
        local user_uid=$(id -u "$real_user" 2>/dev/null || echo 1000)
        sudo -u "$real_user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${user_uid}/bus" \
            notify-send -a "ThinkPad Power" -i "battery-good-charging" "$title" "$msg" 2>/dev/null || true
    fi
}

# Status query requires no root privileges
if [[ "$ACTION" != "status" ]] && [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

case "$ACTION" in
    full|100)
        echo 0 > "$BAT_START" 2>/dev/null || true
        echo 100 > "$BAT_END" 2>/dev/null || true
        echo "MODE=full" > "$CONFIG_FILE"
        udevadm trigger --subsystem-match=power_supply 2>/dev/null || true
        send_notification "⚡ Full Charge Mode Active" "Charging unlocked up to 100%. Continuous charging indicator active."
        echo "✓ Switched to FULL CHARGE mode: Charging to 100% (Charging indicator active)."
        ;;
    protect|80)
        echo 75 > "$BAT_START" 2>/dev/null || true
        echo 80 > "$BAT_END" 2>/dev/null || true
        echo "MODE=protect" > "$CONFIG_FILE"
        udevadm trigger --subsystem-match=power_supply 2>/dev/null || true
        send_notification "🔋 Battery Protection Mode Active" "Threshold set to 75%-80%. Charging pauses at 80% to preserve battery health."
        echo "✓ Switched to BATTERY PROTECTION mode: Threshold set to 75%-80% (Halts at 80%)."
        ;;
    status)
        MODE="protect"
        [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
        echo "=============================================================================="
        echo "                 THINKPAD T490s BATTERY CHARGE STATUS"
        echo "=============================================================================="
        echo "  • Active Charge Mode : ${MODE^^}"
        echo "  • Start Threshold    : $(cat "$BAT_START" 2>/dev/null || echo N/A)%"
        echo "  • Stop Threshold     : $(cat "$BAT_END" 2>/dev/null || echo N/A)%"
        echo "  • Hardware Status    : $(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo N/A)"
        echo "  • AC Charger Online  : $(cat /sys/class/power_supply/AC/online 2>/dev/null || echo N/A)"
        echo "  • UPower State       : $(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep state: | awk '{print $2}')"
        echo "  • Battery Percentage : $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo N/A)%"
        echo "=============================================================================="
        ;;
    *)
        echo "Usage: thinkpad-charge-mode [full|protect|status]"
        exit 1
        ;;
esac
