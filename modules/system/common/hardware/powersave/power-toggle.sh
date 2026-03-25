#!/usr/bin/env bash
# Toggle power profiles based on power source (AC vs battery)
#
# AC mode:    Balanced ↔ Performance  (full performance available on AC)
# Battery:    Quiet ↔ Balanced        (never Performance on battery — longevity)
#
# Each toggle also calls power-tuning to apply low-level kernel settings.

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
CONFIG_DIR="${HOME}/.config/power-toggle"
LAST_PROFILE_FILE="${CONFIG_DIR}/last_profile"
LOG_FILE="${CONFIG_DIR}/power-toggle.log"
TUNE_SCRIPT="${HOME}/.local/bin/power-tuning.sh"

# Profiles available to asusctl
PROFILE_QUIET="Quiet"
PROFILE_BALANCED="Balanced"
PROFILE_PERFORMANCE="Performance"

# Nerd Font icons
declare -A PROFILE_ICONS=(
    ["Quiet"]="󰾆"
    ["Balanced"]="󰁭"
    ["Performance"]="󰓅"
)

# notify icons
declare -A PROFILE_ICONS_HEADER=(
    ["Quiet"]="battery-caution-symbolic"
    ["Balanced"]="preferences-system-power"
    ["Performance"]="thunderbolt"
)
PROFILE_ICONS_HEADER_DEFAULT="system-run"

# Mapping: asusctl profile → power-tuning profile
declare -A TUNE_PROFILE=(
    ["Quiet"]="max-powersave"
    ["Balanced"]="balanced"
    ["Performance"]="max-performance"
)

# ── Init ──────────────────────────────────────────────────────────────────────
mkdir -p "${CONFIG_DIR}"

# ── Helpers ───────────────────────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}" >&2
}

get_current_profile() {
    asusctl profile get 2>/dev/null | awk '/^Active profile:/ {print $3}'
}

# Detect power source: prints "ac" or "battery"
get_power_source() {
    if command -v upower &>/dev/null; then
        local bat
        bat=$(upower -e 2>/dev/null | grep -i battery | head -1)
        if [[ -n "$bat" ]]; then
            upower -i "$bat" 2>/dev/null | grep -q "state:.*discharging" \
                && echo "battery" || echo "ac"
            return
        fi
    fi
    if command -v acpi &>/dev/null; then
        acpi -a 2>/dev/null | grep -q "on-line" && echo "ac" || echo "battery"
        return
    fi
    # Fallback: read sysfs directly
    local status_file
    status_file=$(find /sys/class/power_supply/ -name "status" 2>/dev/null | head -1)
    if [[ -n "$status_file" ]]; then
        grep -qi "discharging" "$status_file" && echo "battery" || echo "ac"
        return
    fi
    echo "unknown"
}

# Apply asusctl profile (AC and battery slots)
asus_set_profile() {
    local profile="$1"
    log "asusctl: setting profile → ${profile}"
    asusctl profile set "${profile}" --ac      2>/dev/null || log "Warning: failed to set AC profile"
    asusctl profile set "${profile}" --battery 2>/dev/null || log "Warning: failed to set battery profile"
}

# Apply low-level kernel tuning via power-tuning.sh
tune_apply() {
    local tune_profile="$1"
    if [[ -x "${TUNE_SCRIPT}" ]]; then
        log "power-tuning: applying → ${tune_profile}"
        sudo "${TUNE_SCRIPT}" profile "${tune_profile}" \
            >> "${LOG_FILE}" 2>&1 || log "Warning: power-tuning returned non-zero for ${tune_profile}"
    else
        log "Notice: ${TUNE_SCRIPT} not found or not executable — skipping kernel tuning"
    fi
}

validate_profile() {
    local profile="$1"
    asusctl profile list 2>/dev/null | grep -qxF "${profile}"
}

send_notification() {
    local profile="$1"
    local source="$2"
    local icon="${PROFILE_ICONS[$profile]:-󰓅}"
    local icon_header="${PROFILE_ICONS_HEADER[$profile]:-${PROFILE_ICONS_HEADER_DEFAULT}}"
    local source_tag
    source_tag=$([ "$source" = "ac" ] && echo "⚡ AC" || echo "🔋 Battery")

    if command -v notify-send &>/dev/null; then
        notify-send -t 3000 \
            -i "${icon_header}" \
            "Power Profile" \
            "${icon} ${profile} (${source_tag})"
    else
        echo "${icon} Switched to ${profile} [${source_tag}]"
    fi
}

# ── Toggle logic ──────────────────────────────────────────────────────────────
#
# AC:      current=Performance → switch to saved/Balanced
#          current≠Performance → save current, switch to Performance
#
# Battery: current=Quiet       → switch to saved/Balanced
#          current≠Quiet       → save current, switch to Quiet
#          (Performance on battery is blocked)
#
toggle_performance() {
    local source current target

    source=$(get_power_source)
    current=$(get_current_profile)

    if [[ -z "$current" ]]; then
        log "Error: could not read current profile — aborting"
        return 1
    fi

    log "Source: ${source} | Current profile: ${current}"

    if [[ "$source" == "ac" ]]; then
        # ── AC mode ──────────────────────────────────────────────────────────
        if [[ "$current" == "$PROFILE_PERFORMANCE" ]]; then
            # Already on Performance → go back to saved or Balanced
            if [[ -f "$LAST_PROFILE_FILE" ]]; then
                target=$(cat "$LAST_PROFILE_FILE")
                rm -f "$LAST_PROFILE_FILE"
                log "AC: Performance → restoring saved profile: ${target}"
            else
                target="$PROFILE_BALANCED"
                log "AC: Performance → fallback to Balanced"
            fi
        else
            # Not on Performance → boost to Performance, save current
            echo "$current" > "$LAST_PROFILE_FILE"
            target="$PROFILE_PERFORMANCE"
            log "AC: ${current} → Performance (saved previous)"
        fi
    else
        # ── Battery mode ─────────────────────────────────────────────────────
        # Hard block: never apply Performance on battery
        if [[ "$current" == "$PROFILE_PERFORMANCE" ]]; then
            log "Battery: Performance detected — forcing Balanced for longevity"
            current="$PROFILE_BALANCED"
            asus_set_profile "$PROFILE_BALANCED"
            tune_apply "${TUNE_PROFILE[$PROFILE_BALANCED]}"
        fi

        if [[ "$current" == "$PROFILE_QUIET" ]]; then
            # Already on Quiet → go back to saved or Balanced
            if [[ -f "$LAST_PROFILE_FILE" ]]; then
                target=$(cat "$LAST_PROFILE_FILE")
                # Never restore Performance on battery
                [[ "$target" == "$PROFILE_PERFORMANCE" ]] && target="$PROFILE_BALANCED"
                rm -f "$LAST_PROFILE_FILE"
                log "Battery: Quiet → restoring saved profile: ${target}"
            else
                target="$PROFILE_BALANCED"
                log "Battery: Quiet → fallback to Balanced"
            fi
        else
            # Not on Quiet → drop to Quiet (max power save), save current
            echo "$current" > "$LAST_PROFILE_FILE"
            target="$PROFILE_QUIET"
            log "Battery: ${current} → Quiet (saved previous)"
        fi
    fi

    if ! validate_profile "$target"; then
        log "Error: profile '${target}' not found in asusctl — aborting"
        return 1
    fi

    asus_set_profile "$target"
    tune_apply "${TUNE_PROFILE[$target]}"

    local confirmed
    confirmed=$(get_current_profile)
    log "Applied: ${confirmed}"
    send_notification "$target" "$source"
}

# ── Commands ──────────────────────────────────────────────────────────────────
list_profiles() {
    local current
    current=$(get_current_profile)
    echo "Available profiles:"
    asusctl profile list 2>/dev/null | while read -r p; do
        local icon="${PROFILE_ICONS[$p]:-?}"
        local tune="${TUNE_PROFILE[$p]:-?}"
        if [[ "$current" == "$p" ]]; then
            echo "  ${icon} ${p} (active) → tune: ${tune}"
        else
            echo "  ${icon} ${p} → tune: ${tune}"
        fi
    done
}

show_status() {
    local current source
    current=$(get_current_profile)
    source=$(get_power_source)

    local source_icon
    case "$source" in
        ac)      source_icon="󰚥" ;;
        battery) source_icon="󰁹" ;;
        *)       source_icon="󰾅" ;;
    esac

    echo "Power source : ${source_icon} ${source}"
    echo "Profile      : ${PROFILE_ICONS[$current]:-?} ${current}"
    echo "Tune profile : ${TUNE_PROFILE[$current]:-unknown}"

    if [[ -f "$LAST_PROFILE_FILE" ]]; then
        local saved
        saved=$(cat "$LAST_PROFILE_FILE")
        echo "Saved profile: ${PROFILE_ICONS[$saved]:-?} ${saved}"
    fi

    echo ""
    echo "Raw asusctl output:"
    asusctl profile get 2>/dev/null | sed 's/^/  /'
}

set_explicit() {
    local target="$1"
    local source
    source=$(get_power_source)

    # Guard: block Performance on battery
    if [[ "$source" == "battery" && "$target" == "$PROFILE_PERFORMANCE" ]]; then
        echo "Warning: Performance mode blocked on battery (use AC to protect longevity)" >&2
        return 1
    fi

    if ! validate_profile "$target"; then
        echo "Invalid profile: ${target}" >&2
        echo "Available: $(asusctl profile list 2>/dev/null | tr '\n' ' ')" >&2
        return 1
    fi

    asus_set_profile "$target"
    tune_apply "${TUNE_PROFILE[$target]}"
    echo "Set to: ${PROFILE_ICONS[$target]:-?} ${target}"
    send_notification "$target" "$source"
}

# ── Entry point ───────────────────────────────────────────────────────────────
case "${1:-}" in
    set)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 set <Quiet|Balanced|Performance>" >&2; exit 1
        fi
        set_explicit "$2"
        ;;
    reset)
        rm -f "$LAST_PROFILE_FILE"
        log "Saved profile cleared"
        echo "Saved profile reset."
        ;;
    list)
        list_profiles
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        cat <<EOF
powermode-toggle — AC/battery-aware power profile toggle

Usage: $0 [command]

  (none)             Toggle profile based on power source
                       AC:      Balanced ↔ Performance
                       Battery: Balanced ↔ Quiet  (Performance blocked)
  set <profile>      Force a specific profile (Performance blocked on battery)
  reset              Clear saved profile
  list               List profiles with tune mappings
  status             Show current state
  help               This help

Profile → tuning map:
  Quiet       → max-powersave  (battery longevity mode)
  Balanced    → balanced
  Performance → max-performance (AC only)
EOF
        ;;
    *)
        toggle_performance
        ;;
esac