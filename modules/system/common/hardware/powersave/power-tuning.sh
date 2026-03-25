#!/usr/bin/env bash
# power-tuning.sh — Low-level kernel power settings for ASUS Vivobook Pro 16
#
# Profiles:
#   max-performance   AC only — full boost, no power saving
#   balanced          AC/battery — schedutil, sensible defaults
#   max-powersave     Battery — deep savings, WiFi PS, capped frequency
#
# Called by powermode-toggle.sh automatically, or standalone.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="/tmp/power-settings-backup.conf"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# ── Backup / Restore ──────────────────────────────────────────────────────────

backup_current_settings() {
    log "Backing up current settings → ${SETTINGS_FILE}"
    {
        echo "# Power settings backup — $(date)"
        echo "cpu_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown)"
        [[ -f /sys/module/pcie_aspm/parameters/policy ]] && \
            echo "pcie_aspm=$(cat /sys/module/pcie_aspm/parameters/policy)"
        # Runtime PM — stored as path|value pairs
        for ctrl in /sys/bus/pci/devices/*/power/control; do
            [[ -f "$ctrl" ]] && echo "runtime_pm:${ctrl}|$(cat "$ctrl")"
        done
    } > "$SETTINGS_FILE"
}

restore_settings() {
    [[ -f "$SETTINGS_FILE" ]] || { log "No backup at ${SETTINGS_FILE}"; return 1; }
    log "Restoring settings from ${SETTINGS_FILE}"

    local cpu_governor=""
    while IFS= read -r line; do
        case "$line" in
            cpu_governor=*)
                cpu_governor="${line#cpu_governor=}"
                ;;
            runtime_pm:*)
                local payload="${line#runtime_pm:}"
                local path="${payload%%|*}"
                local val="${payload#*|}"
                echo "$val" | sudo tee "$path" >/dev/null || true
                ;;
        esac
    done < "$SETTINGS_FILE"

    [[ -n "$cpu_governor" ]] && set_cpu_governor "$cpu_governor"
    log "Restore complete"
}

# ── CPU ───────────────────────────────────────────────────────────────────────

set_cpu_governor() {
    local governor="$1"
    local available
    available=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null || echo "")

    if [[ ! " $available " =~ " $governor " ]]; then
        log "Error: governor '${governor}' not available (have: ${available})"
        return 1
    fi

    log "CPU governor → ${governor}"
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [[ -f "$f" ]] && echo "$governor" | sudo tee "$f" >/dev/null
    done
}

# Reset frequency limits to hardware maximums (remove any cap)
clear_cpu_freq_limits() {
    log "CPU freq limits → hardware max"
    for cpu_dir in /sys/devices/system/cpu/cpu*/cpufreq/; do
        local cpuinfo_max="${cpu_dir}cpuinfo_max_freq"
        local cpuinfo_min="${cpu_dir}cpuinfo_min_freq"
        [[ -f "${cpu_dir}scaling_max_freq" && -f "$cpuinfo_max" ]] && \
            cat "$cpuinfo_max" | sudo tee "${cpu_dir}scaling_max_freq" >/dev/null
        [[ -f "${cpu_dir}scaling_min_freq" && -f "$cpuinfo_min" ]] && \
            cat "$cpuinfo_min" | sudo tee "${cpu_dir}scaling_min_freq" >/dev/null
    done
}

set_cpu_max_freq() {
    local max_mhz="$1"
    log "CPU max freq → ${max_mhz} MHz"
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        [[ -f "$f" ]] && echo $((max_mhz * 1000)) | sudo tee "$f" >/dev/null
    done
}

set_cpu_boost() {
    local state="$1"   # "1" = on, "0" = off
    local label
    label=$([ "$state" = "1" ] && echo "enabled" || echo "disabled")

    # AMD: /sys/devices/system/cpu/cpufreq/boost
    if [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
        echo "$state" | sudo tee /sys/devices/system/cpu/cpufreq/boost >/dev/null
        log "CPU boost → ${label} (AMD sysfs)"
        return
    fi
    # Intel: /sys/devices/system/cpu/intel_pstate/no_turbo (inverted)
    if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
        local no_turbo=$(( 1 - state ))
        echo "$no_turbo" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null
        log "CPU boost → ${label} (Intel no_turbo)"
        return
    fi
    log "Notice: no CPU boost control found"
}

# ── PCIe ASPM ─────────────────────────────────────────────────────────────────

set_pcie_aspm() {
    local policy="$1"
    local aspm_file="/sys/module/pcie_aspm/parameters/policy"

    if [[ ! -f "$aspm_file" ]]; then
        log "PCIe ASPM sysfs not available (kernel param pcie_aspm=force needed)"
        return 0
    fi

    local available
    available=$(cat "$aspm_file" | tr -d '[]')
    if [[ ! " $available " =~ " $policy " ]]; then
        log "Warning: ASPM policy '${policy}' not available (have: ${available})"
        return 0
    fi

    log "PCIe ASPM → ${policy}"
    echo "$policy" | sudo tee "$aspm_file" >/dev/null
}

# ── Runtime PM ────────────────────────────────────────────────────────────────

set_runtime_pm() {
    local mode="$1"   # "auto" or "on"
    log "Runtime PM (PCI) → ${mode}"

    for ctrl in /sys/bus/pci/devices/*/power/control; do
        [[ -f "$ctrl" ]] && echo "$mode" | sudo tee "$ctrl" >/dev/null || true
    done

    # USB — skip obvious input devices
    log "Runtime PM (USB) → ${mode} (skipping input devices)"
    for ctrl in /sys/bus/usb/devices/*/power/control; do
        [[ -f "$ctrl" ]] || continue
        local product_file
        product_file="$(dirname "$ctrl")/product"
        if [[ -f "$product_file" ]]; then
            local product
            product=$(cat "$product_file" 2>/dev/null || echo "")
            [[ "$product" =~ (Keyboard|Mouse|HID|Touchpad) ]] && continue
        fi
        echo "$mode" | sudo tee "$ctrl" >/dev/null || true
    done
}

# ── WiFi ──────────────────────────────────────────────────────────────────────

set_wifi_power_save() {
    local mode="$1"   # "on" or "off"

    if ! command -v iw &>/dev/null; then
        log "Notice: iw not found — skipping WiFi power save"
        return 0
    fi

    log "WiFi power save → ${mode}"
    for iface_dir in /sys/class/net/*/wireless; do
        [[ -d "$iface_dir" ]] || continue
        local iface
        iface=$(basename "$(dirname "$iface_dir")")
        iw dev "$iface" set power_save "$mode" 2>/dev/null \
            || log "Warning: could not set power_save for ${iface}"
    done
}

# ── NVMe / disk ───────────────────────────────────────────────────────────────

set_nvme_power_policy() {
    local policy="$1"   # "min_power" or "balanced" or "performance"
    log "NVMe APST → ${policy}"
    for dev in /sys/class/nvme/nvme*/power/pm_qos_latency_tolerance_us; do
        [[ -f "$dev" ]] || continue
        case "$policy" in
            min_power)   echo 1000000 | sudo tee "$dev" >/dev/null ;;  # 1 s tolerance
            balanced)    echo   10000 | sudo tee "$dev" >/dev/null ;;  # 10 ms
            performance) echo       0 | sudo tee "$dev" >/dev/null ;;  # no latency tolerance
        esac
    done
}

# ── Profiles ──────────────────────────────────────────────────────────────────

apply_power_profile() {
    local profile="$1"

    backup_current_settings

    case "$profile" in
        # ── AC only ───────────────────────────────────────────────────────────
        max-performance)
            log "Profile: max-performance (AC)"
            set_cpu_governor    "performance"
            set_cpu_boost       "1"
            clear_cpu_freq_limits
            set_pcie_aspm       "performance"
            set_runtime_pm      "on"
            set_wifi_power_save "off"
            set_nvme_power_policy "performance"
            ;;

        # ── AC/battery neutral ────────────────────────────────────────────────
        balanced)
            log "Profile: balanced"
            set_cpu_governor    "schedutil"
            set_cpu_boost       "1"
            clear_cpu_freq_limits
            set_pcie_aspm       "default"
            set_runtime_pm      "auto"
            set_wifi_power_save "on"
            set_nvme_power_policy "balanced"
            ;;

        # ── Battery — maximise longevity ──────────────────────────────────────
        max-powersave)
            log "Profile: max-powersave (battery)"
            set_cpu_governor    "powersave"
            set_cpu_boost       "0"          # disable boost → less heat, less wear
            set_cpu_max_freq    "2000"        # cap at 2 GHz
            set_pcie_aspm       "powersupersave"
            set_runtime_pm      "auto"
            set_wifi_power_save "on"
            set_nvme_power_policy "min_power"
            ;;

        *)
            log "Unknown profile: ${profile}"
            log "Valid: max-performance | balanced | max-powersave"
            return 1
            ;;
    esac

    log "Profile '${profile}' applied"
}

# ── Status ────────────────────────────────────────────────────────────────────

show_current_settings() {
    log "=== Current Power Settings ==="
    log "CPU governor : $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown)"

    local min_khz max_khz
    min_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null || echo 0)
    max_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo 0)
    log "CPU freq     : $((min_khz / 1000)) MHz – $((max_khz / 1000)) MHz"

    # Boost
    if [[ -f /sys/devices/system/cpu/cpufreq/boost ]]; then
        local boost
        boost=$(cat /sys/devices/system/cpu/cpufreq/boost)
        log "CPU boost    : $([ "$boost" = "1" ] && echo enabled || echo disabled) (AMD)"
    elif [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
        local no_turbo
        no_turbo=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)
        log "CPU boost    : $([ "$no_turbo" = "0" ] && echo enabled || echo disabled) (Intel)"
    fi

    if [[ -f /sys/module/pcie_aspm/parameters/policy ]]; then
        log "PCIe ASPM    : $(cat /sys/module/pcie_aspm/parameters/policy)"
    fi

    # Sample first 3 PCI runtime PM entries
    local n=0
    for ctrl in /sys/bus/pci/devices/*/power/control; do
        [[ $n -lt 3 && -f "$ctrl" ]] || continue
        local dev_id
        dev_id=$(basename "$(dirname "$(dirname "$ctrl")")")
        log "Runtime PM   : ${dev_id} → $(cat "$ctrl")"
        (( n++ )) || true
    done
}

# ── Help ──────────────────────────────────────────────────────────────────────

show_help() {
    cat <<EOF
power-tuning — Low-level kernel power settings

Usage: $0 [command] [options]

Commands:
  profile <name>          Apply a named profile
  governor <name>         Set CPU governor directly
  freq-limits [min] [max] Set CPU freq limits in MHz (omit to clear caps)
  boost <on|off>          Enable/disable CPU boost/turbo
  pcie-aspm <policy>      Set PCIe ASPM policy
  runtime-pm <auto|on>    Set runtime power management
  wifi-powersave <on|off> Set WiFi power save
  backup                  Save current settings
  restore                 Restore saved settings
  status                  Show current settings
  help                    This help

Profiles:
  max-performance   Full performance, no power saving       (AC only)
  balanced          schedutil, auto PM, WiFi PS             (AC/battery)
  max-powersave     powersave governor, boost off, 2 GHz cap (battery)

Examples:
  sudo $0 profile max-powersave
  sudo $0 governor schedutil
  sudo $0 boost off
  sudo $0 freq-limits 800 2000

Note: Most commands require root (sudo).
EOF
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    [[ $EUID -ne 0 ]] && log "Warning: most operations need root (sudo)"

    case "${1:-help}" in
        profile)       apply_power_profile "${2:-balanced}" ;;
        governor)      set_cpu_governor    "${2:?Usage: $0 governor <name>}" ;;
        freq-limits)
            if [[ "${2:-}" == "clear" || -z "${2:-}" ]]; then
                clear_cpu_freq_limits
            else
                [[ -n "${3:-}" ]] && set_cpu_max_freq "$3"
                # min not exposed as standalone command, call sysfs directly
                log "Note: use 'profile' command for full freq management"
            fi
            ;;
        boost)         set_cpu_boost "$([ "${2:-on}" = "on" ] && echo 1 || echo 0)" ;;
        pcie-aspm)     set_pcie_aspm      "${2:?Usage: $0 pcie-aspm <policy>}" ;;
        runtime-pm)    set_runtime_pm     "${2:-auto}" ;;
        wifi-powersave) set_wifi_power_save "${2:-on}" ;;
        backup)        backup_current_settings ;;
        restore)       restore_settings ;;
        status)        show_current_settings ;;
        help|*)        show_help ;;
    esac
}

main "$@"