#!/usr/bin/env bash
# ==============================================================================
# ThinkPad T490s Autonomous AC/Battery Optimization Watchdog
# Repository: ShoumikBalaSomu/Device-Base-Optimization
# Device: Lenovo ThinkPad T490s (20NYS64T00)
# ==============================================================================
set -euo pipefail

BAT_START="/sys/class/power_supply/BAT0/charge_control_start_threshold"
BAT_END="/sys/class/power_supply/BAT0/charge_control_end_threshold"
CONFIG_FILE="/etc/thinkpad-charge-mode.conf"

# ------------------------------------------------------------------------------
# 1. Dual-Mode Battery Charging Guard (Full 100% vs Protect 80%)
# ------------------------------------------------------------------------------
MODE="protect"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

if [[ "$MODE" == "protect" ]]; then
    [[ -f "$BAT_START" ]] && echo 75 > "$BAT_START" 2>/dev/null || true
    [[ -f "$BAT_END" ]] && echo 80 > "$BAT_END" 2>/dev/null || true
else
    [[ -f "$BAT_START" ]] && echo 0 > "$BAT_START" 2>/dev/null || true
    [[ -f "$BAT_END" ]] && echo 100 > "$BAT_END" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 2. Query AC vs Battery State (Multi-Source Scan: AC + USB-PD Ports)
# ------------------------------------------------------------------------------
AC_ONLINE=0
for ac_dev in /sys/class/power_supply/*/online; do
    if [[ -f "$ac_dev" && "$ac_dev" != *"BAT"* ]]; then
        val=$(cat "$ac_dev" 2>/dev/null || echo 0)
        if [[ "$val" -eq 1 ]]; then
            AC_ONLINE=1
            break
        fi
    fi
done

if [[ "$AC_ONLINE" -eq 1 ]]; then
    # --------------------------------------------------------------------------
    # ON AC POWER: MAXIMUM PERFORMANCE MODE
    # --------------------------------------------------------------------------
    # 1. Synchronize GNOME Quick Settings & TuneD via D-Bus net.hadess.PowerProfiles
    gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles \
        --method org.freedesktop.DBus.Properties.Set "net.hadess.PowerProfiles" "ActiveProfile" '<"performance">' 2>/dev/null || true

    # 2. CPU: Intel SpeedShift EPP = performance
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo performance > "$epp" 2>/dev/null || true
    done
    
    # 3. ThinkPad EC DYTC Platform Profile -> performance (sustained 4.80GHz Turbo boost)
    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo performance > /sys/firmware/acpi/platform_profile 2>/dev/null || true
    fi

    # 4. NVMe SSD: Zero APST sleep latency
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 0 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # 5. Intel UHD 620 iGPU: Full 1.15GHz boost clock
    if [[ -f /sys/class/drm/card1/gt_boost_freq_mhz ]]; then
        echo 1150 > /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || true
        echo 1150 > /sys/class/drm/card1/gt_max_freq_mhz 2>/dev/null || true
    fi

    # 6. USB Autosuspend: Disabled on AC for zero peripheral latency
    for dev in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
    done

    logger -t thinkpad-watchdog "Power state: AC Connected -> Maximum Performance Mode Synchronized (GNOME=performance, TuneD=throughput-performance, EPP=performance, DYTC=performance, GPU=1150MHz, APST=0)"
else
    # --------------------------------------------------------------------------
    # ON BATTERY: EXTREME BATTERY SAVER MODE (~8-10+ Hours Runtime)
    # --------------------------------------------------------------------------
    # 1. Synchronize GNOME Quick Settings & TuneD via D-Bus net.hadess.PowerProfiles
    gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles \
        --method org.freedesktop.DBus.Properties.Set "net.hadess.PowerProfiles" "ActiveProfile" '<"power-saver">' 2>/dev/null || true

    # 2. CPU: Intel SpeedShift EPP -> balance_power
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo balance_power > "$epp" 2>/dev/null || true
    done

    # 3. ThinkPad EC DYTC Platform Profile -> low-power
    if [[ -f /sys/firmware/acpi/platform_profile ]]; then
        echo low-power > /sys/firmware/acpi/platform_profile 2>/dev/null || true
    fi

    # 4. NVMe SSD: Standard APST power savings
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 100000 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # 5. Intel UHD 620 iGPU: Conservative frequency
    if [[ -f /sys/class/drm/card1/gt_boost_freq_mhz ]]; then
        echo 800 > /sys/class/drm/card1/gt_boost_freq_mhz 2>/dev/null || true
    fi

    # 6. USB Autosuspend: Enabled on Battery
    for dev in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$dev" ]] && echo auto > "$dev" 2>/dev/null || true
    done

    logger -t thinkpad-watchdog "Power state: Battery -> Extreme Battery Saver Active (GNOME=power-saver, TuneD=powersave, EPP=balance_power, DYTC=low-power, USB=auto)"
fi
