#!/usr/bin/env bash
# ==============================================================================
# ThinkPad T490s Autonomous AC/Battery Optimization Watchdog
# Repository: ShoumikBalaSomu/Device-Base-Optimization
# Device: Lenovo ThinkPad T490s (20NYS64T00)
# ==============================================================================
set -euo pipefail

AC_FILE="/sys/class/power_supply/AC/online"
BAT_START="/sys/class/power_supply/BAT0/charge_control_start_threshold"
BAT_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"

# ------------------------------------------------------------------------------
# 1. Permanent Battery Chemistry Protection (75% Start - 80% Stop)
# ------------------------------------------------------------------------------
if [[ -f "$BAT_START" ]]; then
    echo 75 > "$BAT_START" 2>/dev/null || true
fi
if [[ -f "$BAT_END" ]]; then
    echo 80 > "$BAT_END" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 2. Query AC vs Battery State
# ------------------------------------------------------------------------------
AC_ONLINE=1
if [[ -f "$AC_FILE" ]]; then
    AC_ONLINE=$(cat "$AC_FILE" 2>/dev/null || echo 1)
fi

if [[ "$AC_ONLINE" -eq 1 ]]; then
    # --------------------------------------------------------------------------
    # ON AC POWER: MAXIMUM PERFORMANCE MODE
    # --------------------------------------------------------------------------
    # CPU: Intel SpeedShift EPP = performance (EPP 0 equivalent in intel_pstate)
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo performance > "$epp" 2>/dev/null || true
    done
    
    # ThinkPad EC DYTC Platform Profile -> performance
    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo performance > /sys/firmware/acpi/platform_profile 2>/dev/null || true
    fi

    # NVMe SSD: Zero APST sleep latency
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 0 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # Intel UHD 620 iGPU: Full 1.15GHz boost clock
    if [[ -f /sys/class/drm/card1/gt_boost_freq_mhz ]]; then
        echo 1150 > /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || true
        echo 1150 > /sys/class/drm/card1/gt_max_freq_mhz 2>/dev/null || true
    fi

    # USB Autosuspend: Disabled on AC for zero peripheral latency
    for dev in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
    done

    logger -t thinkpad-watchdog "Power state: AC Connected -> Maximum Performance Unleashed (EPP=performance, DYTC=performance, GPU=1150MHz, APST=0, USB=on)"
else
    # --------------------------------------------------------------------------
    # ON BATTERY: EXTREME BATTERY SAVER MODE (~8-10+ Hours Runtime)
    # --------------------------------------------------------------------------
    # CPU: Intel SpeedShift EPP -> balance_power
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo balance_power > "$epp" 2>/dev/null || true
    done

    # ThinkPad EC DYTC Platform Profile -> low-power
    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo low-power > /sys/firmware/acpi/platform_profile 2>/dev/null || true
    fi

    # NVMe SSD: Standard APST power savings
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 100000 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # Intel UHD 620 iGPU: Conservative frequency
    if [[ -f /sys/class/drm/card1/gt_boost_freq_mhz ]]; then
        echo 800 > /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || true
    fi

    # USB Autosuspend: Enabled on Battery
    for dev in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$dev" ]] && echo auto > "$dev" 2>/dev/null || true
    done

    logger -t thinkpad-watchdog "Power state: Battery -> Extreme Battery Saver Active (EPP=balance_power, DYTC=low-power, USB=auto)"
fi
