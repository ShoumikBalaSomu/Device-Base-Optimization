#!/usr/bin/env bash
# ==============================================================================
#  🔋 DAFFODIL DC253D BATTERY CHARGING CONTROLLER (SILENT)
#  Hardware Target: Daffodil Computers Ltd. DC253D (Intel Raptor Lake-U)
# ==============================================================================

set -euo pipefail

CONFIG_FILE="/etc/daffodil-charge-mode.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

get_current_mode() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        echo "${MODE:-protect}"
    else
        echo "protect"
    fi
}

show_status() {
    local cur_mode
    cur_mode=$(get_current_mode)
    local cap
    cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
    local status
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "N/A")
    local e_now
    e_now=$(cat /sys/class/power_supply/BAT0/energy_now 2>/dev/null || echo "0")
    local e_full
    e_full=$(cat /sys/class/power_supply/BAT0/energy_full 2>/dev/null || echo "0")
    local e_design
    e_design=$(cat /sys/class/power_supply/BAT0/energy_full_design 2>/dev/null || echo "0")
    
    echo -e "${CYAN}${BOLD}=== Daffodil DC253D Battery Chemistry Status ===${NC}"
    echo -e "  • Current Charge Level : ${BOLD}${cap}%${NC} (${status})"
    if [[ "$cur_mode" == "protect" ]]; then
        echo -e "  • Active Charge Mode   : ${GREEN}${BOLD}PROTECT${NC} (Stop Charging at 80% Active - Silent)"
    else
        echo -e "  • Active Charge Mode   : ${YELLOW}${BOLD}FULL${NC} (100% Express Charge for Travel)"
    fi

    local ppd_profile
    ppd_profile=$(gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Get "net.hadess.PowerProfiles" "ActiveProfile" 2>/dev/null | awk -F"'" '{print $2}' || echo "N/A")
    local tuned_profile
    tuned_profile=$(tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p' || echo "N/A")
    echo -e "  • Desktop Power Mode   : ${CYAN}${BOLD}${ppd_profile^^}${NC} (TuneD: ${tuned_profile})"
    if [[ "$e_design" -gt 0 && "$e_full" -gt 0 ]]; then
        local health
        health=$(awk "BEGIN {printf \"%.1f\", ($e_full / $e_design) * 100}")
        echo -e "  • Battery Cell Health  : ${GREEN}${health}%${NC} (${e_full} uWh / ${e_design} uWh)"
    fi
    echo -e "  • Hardware Model       : Daffodil DC253D / Ganfeng SR Real Battery (55.2 Wh)"
}

set_mode() {
    local target="$1"
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}🔑 Requesting administrative privileges (sudo)...${NC}"
        exec sudo bash "$0" "$@"
    fi

    if [[ "$target" == "protect" ]]; then
        echo "MODE=protect" > "$CONFIG_FILE"
        if [[ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]]; then
            echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ Switched to Li-ion Battery Protection Mode: Stop charging at 80% (Silent).${NC}"
    elif [[ "$target" == "full" ]]; then
        echo "MODE=full" > "$CONFIG_FILE"
        if [[ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]]; then
            echo 100 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ Switched to Full Charge Mode: Charge to 100% unlocked for travel.${NC}"
    else
        echo -e "${RED}Invalid mode: $target${NC}"
        echo "Usage: daffodil-charge-mode [protect | full | status]"
        exit 1
    fi

    # Trigger watchdog to re-evaluate state immediately
    if [[ -x /usr/local/bin/daffodil-watchdog.sh ]]; then
        /usr/local/bin/daffodil-watchdog.sh
    fi
}

case "${1:-status}" in
    protect|protection|80)
        set_mode "protect"
        ;;
    full|100)
        set_mode "full"
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: daffodil-charge-mode [protect | full | status]"
        exit 1
        ;;
esac
