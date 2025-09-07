#!/usr/bin/env bash
# Toggle between Performance and default profile

# Configuration
DEFAULT_PROFILE="Balanced"
PERFORMANCE_PROFILE="Performance"
CONFIG_DIR="$HOME/.config/power-toggle"
LAST_PROFILE_FILE="$CONFIG_DIR/last_profile"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Function to get current profile
get_current_profile() {
    asusctl profile -p 2>/dev/null | awk '/Active profile is/ {print $4}'
}

# Function to set profile
set_profile() {
    local profile="$1"
    asusctl profile -P "$profile"
}

# Main toggle function
toggle_performance() {
    local current_profile
    current_profile=$(get_current_profile)
    
    # If we're already on Performance, switch back to last saved profile or default
    if [ "$current_profile" = "$PERFORMANCE_PROFILE" ]; then
        local target_profile
        
        if [ -f "$LAST_PROFILE_FILE" ]; then
            target_profile=$(cat "$LAST_PROFILE_FILE")
            echo "Switching back to saved profile: $target_profile"
            rm -f "$LAST_PROFILE_FILE"
        else
            target_profile="$DEFAULT_PROFILE"
            echo "Switching to default profile: $target_profile"
        fi
        
        set_profile "$target_profile"
        
    else
        # We're not on Performance, so save current and switch to Performance
        echo "$current_profile" > "$LAST_PROFILE_FILE"
        echo "Switching to Performance profile"
        set_profile "$PERFORMANCE_PROFILE"
    fi
    
    # Show new status
    echo "Current profile: $(get_current_profile)"
}

# Handle command line arguments
case "${1:-}" in
    reset)
        rm -f "$LAST_PROFILE_FILE"
        echo "Reset saved profile. Will use default ($DEFAULT_PROFILE) next time."
        ;;
    help|--help|-h)
        echo "Power Profile Toggle Script"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no command)    Toggle between Performance and saved/default profile"
        echo "  reset           Reset saved profile"
        echo "  help            Show this help message"
        ;;
    *)
        toggle_performance
        ;;
esac