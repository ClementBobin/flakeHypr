#!/usr/bin/env bash
# Toggle power profiles based on power source (AC vs battery)
# and syncs with HyDE workflows.

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

# Mapping: asusctl profile → HyDE workflow name
declare -A WORKFLOW_MAP=(
    ["Quiet"]="powersaver"
    ["Balanced"]="default"       # or "editing"
    ["Performance"]="gaming"     # or "snappy"
)

# ── Init ──────────────────────────────────────────────────────────────────────
mkdir -p "${CONFIG_DIR}"

# ── Helpers ───────────────────────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}" >&2
}

get_current_profile() {
    local output
    output=$(asusctl profile -p 2>/dev/null) || \
    output=$(asusctl profile get 2>/dev/null)
    
    echo "$output" | awk '
        /^Active profile:/ { print $3; exit }
        /^Profile:/ { print $2; exit }
        /^active:/ { print $2; exit }
        { print $NF }
    '
}

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
    local status_file
    status_file=$(find /sys/class/power_supply/ -name "status" 2>/dev/null | head -1)
    if [[ -n "$status_file" ]]; then
        grep -qi "discharging" "$status_file" && echo "battery" || echo "ac"
        return
    fi
    echo "unknown"
}

asus_set_profile() {
    local profile="$1"
    log "asusctl: setting profile → ${profile}"
    asusctl profile set "${profile}" --ac      2>/dev/null || log "Warning: failed to set AC profile"
    asusctl profile set "${profile}" --battery 2>/dev/null || log "Warning: failed to set battery profile"
}

tune_apply() {
    local tune_profile="$1"
    if [[ -x "${TUNE_SCRIPT}" ]]; then
        log "power-tuning: applying → ${tune_profile}"
        sudo "${TUNE_SCRIPT}" profile "${tune_profile}" \
            >> "${LOG_FILE}" 2>&1 || log "Warning: power-tuning returned non-zero for ${tune_profile}"
    else
        log "Notice: ${TUNE_SCRIPT} not found — skipping kernel tuning"
    fi
}

# Apply matching HyDE workflow
apply_workflow() {
    local profile="$1"
    local wf="${WORKFLOW_MAP[$profile]:-}"
    if [[ -n "$wf" ]] && command -v hyde-shell &>/dev/null; then
        log "hyde-shell workflows: setting → ${wf}"
        hyde-shell workflows --set "$wf" &>/dev/null || log "Warning: failed to set workflow ${wf}"
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
            "Power & Workflow Profile" \
            "${icon} ${profile} (${source_tag})"
    else
        echo "${icon} Switched to ${profile} [${source_tag}]"
    fi
}

# ── Toggle logic ──────────────────────────────────────────────────────────────
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
        if [[ "$current" == "$PROFILE_PERFORMANCE" ]]; then
            if [[ -f "$LAST_PROFILE_FILE" ]]; then
                target=$(cat "$LAST_PROFILE_FILE")
                rm -f "$LAST_PROFILE_FILE"
            else
                target="$PROFILE_BALANCED"
            fi
        else
            echo "$current" > "$LAST_PROFILE_FILE"
            target="$PROFILE_PERFORMANCE"
        fi
    else
        if [[ "$current" == "$PROFILE_PERFORMANCE" ]]; then
            current="$PROFILE_BALANCED"
            asus_set_profile "$PROFILE_BALANCED"
            tune_apply "${TUNE_PROFILE[$PROFILE_BALANCED]}"
        fi

        if [[ "$current" == "$PROFILE_QUIET" ]]; then
            if [[ -f "$LAST_PROFILE_FILE" ]]; then
                target=$(cat "$LAST_PROFILE_FILE")
                [[ "$target" == "$PROFILE_PERFORMANCE" ]] && target="$PROFILE_BALANCED"
                rm -f "$LAST_PROFILE_FILE"
            else
                target="$PROFILE_BALANCED"
            fi
        else
            echo "$current" > "$LAST_PROFILE_FILE"
            target="$PROFILE_QUIET"
        fi
    fi

    if ! validate_profile "$target"; then
        log "Error: profile '${target}' not found in asusctl — aborting"
        return 1
    fi

    asus_set_profile "$target"
    tune_apply "${TUNE_PROFILE[$target]}"
    apply_workflow "$target"

    local confirmed
    confirmed=$(get_current_profile)
    log "Applied: ${confirmed}"
    send_notification "$target" "$source"
}

set_explicit() {
    local target="$1"
    local source
    source=$(get_power_source)

    if [[ "$source" == "battery" && "$target" == "$PROFILE_PERFORMANCE" ]]; then
        echo "Warning: Performance mode blocked on battery" >&2
        return 1
    fi

    if ! validate_profile "$target"; then
        echo "Invalid profile: ${target}" >&2
        return 1
    fi

    asus_set_profile "$target"
    tune_apply "${TUNE_PROFILE[$target]}"
    apply_workflow "$target"
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
        list_profiles() {
            local current
            current=$(get_current_profile)
            echo "Available profiles:"
            asusctl profile list 2>/dev/null | while read -r p; do
                local icon="${PROFILE_ICONS[$p]:-?}"
                local tune="${TUNE_PROFILE[$p]:-?}"
                local wf="${WORKFLOW_MAP[$p]:-?}"
                echo "  ${icon} ${p} → tune: ${tune} | workflow: ${wf}"
            done
        }
        list_profiles
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        echo "Usage: $0 [command]"
        ;;
    *)
        toggle_performance
        ;;
esac