#!/usr/bin/env bash
# ==============================================================================
#  🛡️ DAFFODIL DC253D AUTONOMOUS POWER & BATTERY WATCHDOG DAEMON
#  Hardware: Daffodil Computers Ltd. DC253D (Intel Core i3-1315U / Emdoor IDL528)
#  OS: Fedora Linux 44 (Kernel 7.2.4 x86_64)
#  Repository: ShoumikBalaSomu/Device-Base-Optimization
# ==============================================================================

set -euo pipefail

LOCK_FILE="/var/lock/daffodil-watchdog.lock"
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

LOG_FILE="/var/log/daffodil-watchdog.log"
CONFIG_FILE="/etc/daffodil-charge-mode.conf"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null || true
}

# Ensure mode config exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "MODE=protect" > "$CONFIG_FILE"
fi
source "$CONFIG_FILE"
CHARGE_MODE="${MODE:-protect}"

# Determine Power State: AC vs Battery
IS_AC=0
for ac in /sys/class/power_supply/AD*/online /sys/class/power_supply/AC*/online; do
    if [[ -f "$ac" ]] && [[ "$(cat "$ac" 2>/dev/null)" == "1" ]]; then
        IS_AC=1
        break
    fi
done

# Fallback check on BAT0 status
if [[ $IS_AC -eq 0 ]] && [[ -f /sys/class/power_supply/BAT0/status ]]; then
    bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "")
    if [[ "$bat_status" == "Charging" || "$bat_status" == "Full" ]]; then
        IS_AC=1
    fi
fi

if [[ $IS_AC -eq 1 ]]; then
    # ==========================================================================
    # AC POWER PROFILE: MAXIMUM UNLEASHED PERFORMANCE
    # ==========================================================================
    log "Power Source: AC Mains Connected -> Unleashing Peak Hardware Performance"

    # 1. CPU SpeedShift EPP = performance (0)
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo performance > "$epp" 2>/dev/null || true
    done

    # 2. CPU Energy Performance Bias = 0 (Performance)
    for epb in /sys/devices/system/cpu/cpu*/power/energy_perf_bias; do
        [[ -f "$epb" ]] && echo 0 > "$epb" 2>/dev/null || true
    done

    # 3. Ensure all 8 logical cores (2 P-Cores with HT + 4 E-Cores) are online
    for cpu in /sys/devices/system/cpu/cpu[1-7]/online; do
        [[ -f "$cpu" ]] && echo 1 > "$cpu" 2>/dev/null || true
    done

    # 4. CPU Scaling Frequency uncap
    for fmax in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        if [[ -f "$fmax" ]]; then
            cpu_num=$(basename "$(dirname "$(dirname "$fmax")")" | sed 's/cpu//')
            if [[ "$cpu_num" -le 3 ]]; then
                echo 4500000 > "$fmax" 2>/dev/null || true
            else
                echo 3300000 > "$fmax" 2>/dev/null || true
            fi
        fi
    done

    # 5. PCIe ASPM Link State Sleep = Performance
    if [[ -f /sys/module/pcie_aspm/parameters/policy ]]; then
        echo performance > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
    fi

    # 6. USB Autosuspend = Disabled (on) to stop peripheral disconnects
    for dev in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
    done

    # 7. Intel Raptor Lake UHD Graphics Max Boost (1250 MHz)
    for card in /sys/class/drm/card1 /sys/class/drm/card0; do
        if [[ -f "$card/gt_boost_freq_mhz" ]]; then
            echo 1250 > "$card/gt_boost_freq_mhz" 2>/dev/null || true
            echo 1250 > "$card/gt_max_freq_mhz" 2>/dev/null || true
        fi
    done

    # 8. Wi-Fi Low Latency (Power Save OFF)
    for wiface in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
        iw dev "$wiface" set power_save off 2>/dev/null || true
    done

    # 9. Audio Power Save = 0 (Eliminate DAC popping & crackling)
    if [[ -f /sys/module/snd_hda_intel/parameters/power_save ]]; then
        echo 0 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null || true
    fi

    # 10. NVMe DRAM-less MAP1202 Zero APST Sleep Latency
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 0 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # 11. Touchpad & Intel LPSS I2C Controller Shield
    for dev in /sys/bus/pci/drivers/intel-lpss/*/power/control /sys/bus/i2c/devices/i2c-SYNA*/power/control; do
        [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
    done

else
    # ==========================================================================
    # BATTERY POWER PROFILE: EXTREME BATTERY SAVER (8-10+ HRS RUNTIME)
    # ==========================================================================
    log "Power Source: Battery Discharged -> Activating Extreme Battery Saver"

    # 1. CPU SpeedShift EPP = balance_power
    for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [[ -f "$epp" ]] && echo balance_power > "$epp" 2>/dev/null || true
    done

    # 2. CPU Energy Performance Bias = 15 (Power Saver)
    for epb in /sys/devices/system/cpu/cpu*/power/energy_perf_bias; do
        [[ -f "$epb" ]] && echo 15 > "$epb" 2>/dev/null || true
    done

    # 3. Cap CPU max frequency on battery to base clock (~2.0GHz P / 1.5GHz E)
    for fmax in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        if [[ -f "$fmax" ]]; then
            cpu_num=$(basename "$(dirname "$(dirname "$fmax")")" | sed 's/cpu//')
            if [[ "$cpu_num" -le 3 ]]; then
                echo 2000000 > "$fmax" 2>/dev/null || true
            else
                echo 1500000 > "$fmax" 2>/dev/null || true
            fi
        fi
    done

    # 4. PCIe ASPM Link State = powersupersave
    if [[ -f /sys/module/pcie_aspm/parameters/policy ]]; then
        echo powersupersave > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
    fi

    # 5. USB Autosuspend = Enabled (auto) for non-camera peripherals
    for dev in /sys/bus/usb/devices/*/power/control; do
        d_dir=$(dirname "$dev")
        # Exclude USB webcams (Chicony/Sunplus 04f2:b650 or Video class) from autosuspend
        if [[ -f "$d_dir/idVendor" && -f "$d_dir/idProduct" ]]; then
            v=$(cat "$d_dir/idVendor" 2>/dev/null || echo "")
            p=$(cat "$d_dir/idProduct" 2>/dev/null || echo "")
            if [[ "$v" == "04f2" && "$p" == "b650" ]]; then
                echo on > "$dev" 2>/dev/null || true
                continue
            fi
        fi
        [[ -f "$dev" ]] && echo auto > "$dev" 2>/dev/null || true
    done
    # Guarantee camera is always ON and autosuspend disabled
    for d in /sys/bus/usb/devices/*; do
        if [[ -f "$d/idVendor" && -f "$d/idProduct" ]]; then
            v=$(cat "$d/idVendor" 2>/dev/null || echo "")
            p=$(cat "$d/idProduct" 2>/dev/null || echo "")
            if [[ "$v" == "04f2" && "$p" == "b650" ]]; then
                echo on > "$d/power/control" 2>/dev/null || true
                echo -1 > "$d/power/autosuspend" 2>/dev/null || true
            fi
        fi
    done

    # 6. Intel Raptor Lake UHD Graphics Capped to 400 MHz
    for card in /sys/class/drm/card1 /sys/class/drm/card0; do
        if [[ -f "$card/gt_boost_freq_mhz" ]]; then
            echo 400 > "$card/gt_boost_freq_mhz" 2>/dev/null || true
            echo 400 > "$card/gt_max_freq_mhz" 2>/dev/null || true
        fi
    done

    # 7. Wi-Fi Power Save = ON
    for wiface in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
        iw dev "$wiface" set power_save on 2>/dev/null || true
    done

    # 8. Audio Power Save = 1 (Codec sleeps when idle)
    if [[ -f /sys/module/snd_hda_intel/parameters/power_save ]]; then
        echo 1 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null || true
    fi

    # 9. NVMe APST Sleep Enabled (standard 100000us)
    if [[ -f /sys/module/nvme_core/parameters/default_ps_max_latency_us ]]; then
        echo 100000 > /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || true
    fi

    # 10. Touchpad & Intel LPSS I2C Controller Shield (Guaranteed Active)
    for dev in /sys/bus/pci/drivers/intel-lpss/*/power/control /sys/bus/i2c/devices/i2c-SYNA*/power/control; do
        [[ -f "$dev" ]] && echo on > "$dev" 2>/dev/null || true
    done
fi

# ==============================================================================
# BATTERY CHEMISTRY PROTECTION & 80% HARDWARE CHARGE STOP ENFORCEMENT
# ==============================================================================
if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    BAT_CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0)
    BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

    # 1. Enforce kernel threshold attributes if available
    if [[ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]]; then
        if [[ "$CHARGE_MODE" == "protect" ]]; then
            echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
        else
            echo 100 > /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || true
        fi
    fi

    if [[ -f /sys/class/power_supply/BAT0/charge_control_limit_max ]]; then
        if [[ "$CHARGE_MODE" == "protect" ]]; then
            echo 80 > /sys/class/power_supply/BAT0/charge_control_limit_max 2>/dev/null || true
        else
            echo 100 > /sys/class/power_supply/BAT0/charge_control_limit_max 2>/dev/null || true
        fi
    fi

    # 2. Hardware EC Stop-Charging Sequence & Thermal Guard when reaching 80% on AC
    if [[ $IS_AC -eq 1 && "$CHARGE_MODE" == "protect" && "$BAT_CAP" -ge 80 ]]; then
        # Send direct EC charger stop command (Method SPPC: CHGR=0, ECMD=0x37)
        python3 -c "
import os, time
try:
    fd = os.open('/dev/port', os.O_RDWR)
    def inb(p): os.lseek(fd, p, os.SEEK_SET); return os.read(fd, 1)[0]
    def outb(p, v): os.lseek(fd, p, os.SEEK_SET); os.write(fd, bytes([v]))
    def wait(m, v):
        for _ in range(500):
            if (inb(0x66) & m) == v: return True
            time.sleep(0.0001)
        return False
    def wr(a, v):
        if wait(2, 0):
            outb(0x66, 0x81)
            if wait(2, 0):
                outb(0x62, a)
                if wait(2, 0):
                    outb(0x62, v)
                    return True
        return False
    wr(0x67, 0x00)
    wr(0x68, 0x00)
    wr(0x20, 0x37)
    os.close(fd)
except Exception: pass
" 2>/dev/null || true

        # Protect battery cells from simultaneous high-voltage + high-thermal stress
        for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
            [[ -f "$epp" ]] && echo balance_power > "$epp" 2>/dev/null || true
        done
        log "Battery level ${BAT_CAP}% >= 80%: Hardware stop-charge command and thermal protection engaged (silent, no notifications)."
    fi
fi

# ==============================================================================
# SILENT PERIODIC RE-TRIM FOR MAXIO DRAM-LESS NVMe
# ==============================================================================
TRIM_MARKER="/tmp/.daffodil_last_trim"
if [[ ! -f "$TRIM_MARKER" || $(($(date +%s) - $(stat -c %Y "$TRIM_MARKER" 2>/dev/null || echo 0))) -gt 604800 ]]; then
    touch "$TRIM_MARKER"
    fstrim -av >> "$LOG_FILE" 2>&1 || true
    log "Weekly silent fstrim executed successfully."
fi

exit 0
