#!/usr/bin/env bash
# Toggle between Performance and Balanced profile

set -euo pipefail

# Configuration
DEFAULT_PROFILE="Balanced"
PERFORMANCE_PROFILE="Performance"
CONFIG_DIR="${HOME}/.config/power-toggle"
LAST_PROFILE_FILE="${CONFIG_DIR}/last_profile"
LOG_FILE="${CONFIG_DIR}/power-toggle.log"

# Icons for notifications (using system icons or emoji as fallback)
declare -A PROFILE_ICONS=(
    ["Quiet"]="󰾆"  # battery icon or ⚡
    ["Balanced"]="󰁭"  # balanced scale or ⚖️
    ["Performance"]="󰓅"  # rocket or 🚀
)

# Ensure config directory exists
mkdir -p "${CONFIG_DIR}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}" >&2
}

# Function to get current profile
get_current_profile() {
    local profile
    if ! profile=$(asusctl profile get 2>/dev/null | awk '/^Active profile:/ {print $3}'); then
        log "Error: Failed to get current profile"
        return 1
    fi
    echo "${profile}"
}

# Function to set profile (sets for both AC and battery)
set_profile() {
    local profile="$1"
    log "Setting profile to: ${profile}"
    
    # Set for AC
    if ! asusctl profile set "${profile}" --ac 2>/dev/null; then
        log "Error: Failed to set AC profile to ${profile}"
        return 1
    fi
    
    # Set for battery
    if ! asusctl profile set "${profile}" --battery 2>/dev/null; then
        log "Error: Failed to set battery profile to ${profile}"
        return 1
    fi
    
    return 0
}

# Send desktop notification with icon
send_notification() {
    local profile="$1"
    local icon="${PROFILE_ICONS[$profile]:-󰓅}"  # Default to rocket if no icon
    
    if command -v notify-send &>/dev/null; then
        case "${profile}" in
            "Quiet")
                notify-send -t 3000 -i "battery" "Power Profile" "󰾆 Quiet Mode"
                ;;
            "Balanced")
                notify-send -t 3000 -i "preferences-system-power" "Power Profile" "󰁭 Balanced Mode"
                ;;
            "Performance")
                notify-send -t 3000 -i "preferences-system-performance" "Power Profile" "󰓅 Performance Mode"
                ;;
            *)
                notify-send -t 3000 "Power Profile" "${icon} ${profile} Mode"
                ;;
        esac
    else
        # Fallback: print to terminal with emoji
        echo "${icon} Switched to ${profile} mode"
    fi
}

# Validate profile exists
validate_profile() {
    local profile="$1"
    if ! asusctl profile list 2>/dev/null | grep -q "^${profile}$"; then
        log "Warning: Profile '${profile}' not found in available profiles"
        return 1
    fi
    return 0
}

# Get AC/battery status
get_power_status() {
    # This might require acpi or upower
    if command -v upower &>/dev/null; then
        upower -i $(upower -e | grep battery) 2>/dev/null | grep -q "state.*discharging" && echo "battery" || echo "ac"
    elif command -v acpi &>/dev/null; then
        acpi -a 2>/dev/null | grep -q "on-line" && echo "ac" || echo "battery"
    else
        echo "unknown"
    fi
}

# Get icon for profile display
get_profile_icon() {
    local profile="$1"
    echo "${PROFILE_ICONS[$profile]:-󰓅}"
}

# Main toggle function
toggle_performance() {
    local current_profile target_profile power_status
    
    power_status=$(get_power_status)
    log "Power status: ${power_status}"
    
    if ! current_profile=$(get_current_profile); then
        log "Aborting due to error"
        return 1
    fi
    
    log "Current profile: ${current_profile}"
    
    # If we're already on Performance, switch back to last saved profile or default
    if [ "${current_profile}" = "${PERFORMANCE_PROFILE}" ]; then
        if [ -f "${LAST_PROFILE_FILE}" ]; then
            target_profile=$(cat "${LAST_PROFILE_FILE}")
            log "Switching back to saved profile: ${target_profile}"
            rm -f "${LAST_PROFILE_FILE}"
        else
            target_profile="${DEFAULT_PROFILE}"
            log "Switching to default profile: ${target_profile}"
        fi
    else
        # We're not on Performance, so save current and switch to Performance
        echo "${current_profile}" > "${LAST_PROFILE_FILE}"
        target_profile="${PERFORMANCE_PROFILE}"
        log "Saved current profile and switching to: ${target_profile}"
    fi
    
    # Validate target profile exists before setting
    if validate_profile "${target_profile}"; then
        if set_profile "${target_profile}"; then
            log "Successfully switched to: $(get_current_profile)"
            send_notification "${target_profile}"
        fi
    else
        log "Aborting: Invalid target profile '${target_profile}'"
        return 1
    fi
}

# List available profiles with icons
list_profiles() {
    echo "Available profiles:"
    asusctl profile list 2>/dev/null | while read -r profile; do
        local icon=$(get_profile_icon "${profile}")
        if [ "$(get_current_profile)" = "${profile}" ]; then
            echo "  ${icon} ${profile} (active)"
        else
            echo "  ${icon} ${profile}"
        fi
    done
}

# Show current status with icons
show_status() {
    local current_profile saved_profile power_status power_icon
    
    current_profile=$(get_current_profile || echo "unknown")
    power_status=$(get_power_status)
    
    # Power source icon
    case "${power_status}" in
        "ac") power_icon="󰚥" ;;
        "battery") power_icon="󰁹" ;;
        *) power_icon="󰾅" ;;
    esac
    
    echo "Current profile: $(get_profile_icon "${current_profile}") ${current_profile}"
    echo "Power source: ${power_icon} ${power_status}"
    
    if [ -f "${LAST_PROFILE_FILE}" ]; then
        saved_profile=$(cat "${LAST_PROFILE_FILE}")
        echo "Saved profile: $(get_profile_icon "${saved_profile}") ${saved_profile}"
    fi
    
    # Show AC/battery specific settings
    echo -e "\nProfile settings:"
    asusctl profile get 2>/dev/null | grep -E "profile|--" | sed 's/^/  /'
}

# Handle command line arguments
case "${1:-}" in
    reset)
        rm -f "${LAST_PROFILE_FILE}"
        log "Reset saved profile. Will use default (${DEFAULT_PROFILE}) next time."
        send_notification "Balanced"  # Default to balanced icon
        echo "Saved profile reset."
        ;;
    list)
        list_profiles
        ;;
    status)
        show_status
        ;;
    set)
        if [ -n "${2:-}" ]; then
            target="${2}"
            if validate_profile "${target}"; then
                if set_profile "${target}"; then
                    echo "Successfully set profile to: $(get_profile_icon "${target}") ${target}"
                    send_notification "${target}"
                else
                    echo "Failed to set profile" >&2
                    exit 1
                fi
            else
                echo "Invalid profile: ${target}" >&2
                echo "Available profiles:"
                asusctl profile list 2>/dev/null | while read -r p; do
                    echo "  $(get_profile_icon "${p}") ${p}"
                done
                exit 1
            fi
        else
            echo "Usage: $0 set <profile>" >&2
            echo "Example: $0 set Balanced" >&2
            exit 1
        fi
        ;;
    help|--help|-h)
        echo "Power Profile Toggle Script"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no command)    Toggle between Performance and saved/default profile"
        echo "  set <profile>   Set to specific profile (Quiet/Balanced/Performance)"
        echo "  reset           Reset saved profile"
        echo "  list            List all available profiles"
        echo "  status          Show current and saved profile"
        echo "  help            Show this help message"
        echo ""
        echo "Available profiles:"
        echo "  󰾆 Quiet"
        echo "  󰁭 Balanced"
        echo "  󰓅 Performance"
        ;;
    *)
        toggle_performance
        ;;
esac