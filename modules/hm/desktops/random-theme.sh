#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/hyde/themes"

pick_random_theme() {
    mapfile -t THEMES < <(ls -1 "$THEMES_DIR" 2>/dev/null)
    if [ ${#THEMES[@]} -eq 0 ]; then
        echo "No themes found in $THEMES_DIR" >&2
        return 1
    fi
    echo "${THEMES[$RANDOM % ${#THEMES[@]}]}"
}

show_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Wrapper to change theme and optionally set a random wallpaper.

Options:
  -h, --help            Show this help menu
  -r, --random-theme    Apply a random theme
  -a, --all             Apply a random theme and a random wallpaper

Examples:
    $0 -r               # Apply a random theme
    $0 -a               # Apply a random theme and a random wallpaper
EOF
}

APPLY_RANDOM_THEME=false
APPLY_RANDOM_WALLPAPER=false
SPECIFIED_THEME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -r|--random-theme)
            APPLY_RANDOM_THEME=true
            shift
            ;;
        -a | --all)
            APPLY_RANDOM_THEME=true
            APPLY_RANDOM_WALLPAPER=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Determine which theme to apply
if [ "$APPLY_RANDOM_THEME" = true ]; then
    THEME_TO_APPLY=$(pick_random_theme) || exit 1
fi

# Apply theme if set
if [ -n "$THEME_TO_APPLY" ]; then
    echo "Applying theme: $THEME_TO_APPLY"
    "$HOME/.local/lib/hyde/theme.switch.sh" -s "$THEME_TO_APPLY"
fi

# Apply random wallpaper if requested
if [ "$APPLY_RANDOM_WALLPAPER" = true ]; then
    echo "Applying random wallpaper..."
    "$HOME/.local/lib/hyde/wallpaper.sh" -r
fi

# Wait for theme application if backgrounded
wait