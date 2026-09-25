#!/usr/bin/env bash

# WireGuard VPN Manager
# Extended with: config (show), edit (TUI file picker)

CONFIG_DIR="$HOME/vpn"
NIX_PACKAGE="wireguard-tools"

# Colors for TUI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     ${GREEN}WireGuard VPN Manager${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${CYAN}Current active interfaces:${NC}"
    nix-shell -p "$NIX_PACKAGE" --run "sudo wg show" 2>/dev/null || echo "  No active interfaces"
    echo ""
}

select_with_arrows() {
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local key

    tput civis  # hide cursor
    clear

    while true; do
        # ── Render ──────────────────────────────────────────────────────────
        tput cup 0 0
        tput ed   # clear from cursor to end of screen

        print_header
        print_status

        echo -e "${YELLOW}${title}${NC}"
        echo ""

        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${GREEN}› ${options[$i]}${NC}"
            else
                echo -e "    ${options[$i]}"
            fi
        done

        echo ""
        echo -e "${CYAN}Use ↑/↓ arrows to navigate, Enter to select, q to quit${NC}"

        # ── Input ────────────────────────────────────────────────────────────
        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A')  # up
                    (( selected-- ))
                    [[ $selected -lt 0 ]] && selected=$(( ${#options[@]} - 1 ))
                    ;;
                '[B')  # down
                    (( selected++ ))
                    [[ $selected -ge ${#options[@]} ]] && selected=0
                    ;;
            esac
        elif [[ $key == "" ]]; then  # Enter
            tput cnorm
            return $selected
        elif [[ $key == "q" ]] || [[ $key == "Q" ]]; then
            tput cnorm
            return 255
        fi
    done
}

# ─── Actions ────────────────────────────────────────────────────────────────

do_status() {
    clear
    print_header
    echo -e "${CYAN}WireGuard Status:${NC}"
    echo ""
    nix-shell -p "$NIX_PACKAGE" --run "sudo wg show"
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read
}

do_down() {
    local interfaces=()

    while IFS= read -r line; do
        if [[ $line =~ interface:\ ([^,]+) ]]; then
            interfaces+=("${BASH_REMATCH[1]}")
        fi
    done < <(nix-shell -p "$NIX_PACKAGE" --run "sudo wg show" 2>/dev/null)

    if [[ ${#interfaces[@]} -eq 0 ]]; then
        clear
        print_header
        echo -e "${RED}No active WireGuard interfaces found.${NC}"
        echo ""
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read
        return
    fi

    if [[ ${#interfaces[@]} -eq 1 ]]; then
        clear
        print_header
        echo -e "${YELLOW}Bringing down interface: ${interfaces[0]}${NC}"
        nix-shell -p "$NIX_PACKAGE" --run "sudo wg-quick down ${interfaces[0]}"
        echo ""
        echo -e "${GREEN}✓ Interface ${interfaces[0]} is down${NC}"
        sleep 2
    else
        select_with_arrows "Select interface to bring down:" "${interfaces[@]}"
        local result=$?

        if [[ $result -ne 255 ]] && [[ $result -ge 0 ]] && [[ $result -lt ${#interfaces[@]} ]]; then
            clear
            print_header
            echo -e "${YELLOW}Bringing down interface: ${interfaces[$result]}${NC}"
            nix-shell -p "$NIX_PACKAGE" --run "sudo wg-quick down ${interfaces[$result]}"
            echo ""
            echo -e "${GREEN}✓ Interface ${interfaces[$result]} is down${NC}"
            sleep 2
        fi
    fi
}

do_up() {
    local configs=()
    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r file; do
            configs+=("$(basename "$file")")
        done < <(find "$CONFIG_DIR" -maxdepth 1 -name "wg*.conf" -type f | sort)
    fi

    if [[ ${#configs[@]} -eq 0 ]]; then
        clear
        print_header
        echo -e "${RED}No WireGuard configs found in $CONFIG_DIR/wg*.conf${NC}"
        echo ""
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read
        return
    fi

    if [[ ${#configs[@]} -eq 1 ]]; then
        local config="${configs[0]}"
        clear
        print_header
        echo -e "${YELLOW}Starting VPN with: ${config}${NC}"
        nix-shell -p "$NIX_PACKAGE" --run "sudo wg-quick up \"$CONFIG_DIR/$config\""
        echo ""
        echo -e "${GREEN}✓ VPN started with ${config}${NC}"
        sleep 2
    else
        select_with_arrows "Select WireGuard config to start:" "${configs[@]}"
        local result=$?

        if [[ $result -ne 255 ]] && [[ $result -ge 0 ]] && [[ $result -lt ${#configs[@]} ]]; then
            local config="${configs[$result]}"
            clear
            print_header
            echo -e "${YELLOW}Starting VPN with: ${config}${NC}"
            nix-shell -p "$NIX_PACKAGE" --run "sudo wg-quick up \"$CONFIG_DIR/$config\""
            echo ""
            echo -e "${GREEN}✓ VPN started with ${config}${NC}"
            sleep 2
        fi
    fi
}

do_config() {
    local configs=()
    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r file; do
            configs+=("$file")
        done < <(find "$CONFIG_DIR" -maxdepth 1 -name "wg*.conf" -type f | sort)
    fi

    clear
    print_header
    echo -e "${CYAN}WireGuard Configuration Files:${NC}"
    echo ""

    if [[ ${#configs[@]} -eq 0 ]]; then
        echo -e "${RED}No WireGuard configs found in $CONFIG_DIR/wg*.conf${NC}"
    else
        for conf in "${configs[@]}"; do
            echo -e "${YELLOW}── $(basename "$conf") ──────────────────────────${NC}"
            # Mask PrivateKey and PresharedKey values
            while IFS= read -r line; do
                if echo "$line" | grep -qiE "^(PrivateKey|PresharedKey)\s*="; then
                    local key
                    key=$(echo "$line" | cut -d'=' -f1)
                    echo -e "${key} = ${RED}[hidden]${NC}"
                else
                    echo "$line"
                fi
            done < "$conf"
            echo ""
        done
    fi

    echo -e "${CYAN}Press Enter to continue...${NC}"
    read
}

do_edit() {
    local files=()

    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$CONFIG_DIR" -maxdepth 1 -name "wg*.conf" -type f | sort)
    fi

    if [[ ${#files[@]} -eq 0 ]]; then
        clear
        print_header
        echo -e "${YELLOW}No WireGuard config files found. Create one at $CONFIG_DIR/wg0.conf? [y/N]${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            mkdir -p "$CONFIG_DIR"
            local new_conf="$CONFIG_DIR/wg0.conf"
            cat > "$new_conf" <<'EOF'
[Interface]
PrivateKey = <your_private_key>
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <server_public_key>
# PresharedKey = <optional_preshared_key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
            echo -e "${GREEN}✓ Created $new_conf${NC}"
            sleep 1
            ${EDITOR:-nano} "$new_conf"
        fi
        return
    fi

    local file_names=()
    for f in "${files[@]}"; do
        file_names+=("$(basename "$f")")
    done
    file_names+=("[ Open config directory ]")

    select_with_arrows "Select WireGuard config to edit:" "${file_names[@]}"
    local result=$?

    if [[ $result -eq 255 ]]; then
        return
    fi

    # Last option = open directory
    if [[ $result -eq ${#files[@]} ]]; then
        clear
        print_header
        echo -e "${CYAN}Opening config directory: $CONFIG_DIR${NC}"
        echo ""
        ls -la "$CONFIG_DIR"
        echo ""
        echo -e "${YELLOW}Opening in file manager...${NC}"
        if command -v xdg-open &>/dev/null; then
            xdg-open "$CONFIG_DIR" &
        elif command -v nautilus &>/dev/null; then
            nautilus "$CONFIG_DIR" &
        elif command -v dolphin &>/dev/null; then
            dolphin "$CONFIG_DIR" &
        else
            echo -e "${RED}No file manager found. Directory: $CONFIG_DIR${NC}"
        fi
        sleep 2
        return
    fi

    clear
    print_header
    echo -e "${CYAN}Editing: ${files[$result]}${NC}"
    echo ""
    ${EDITOR:-nano} "${files[$result]}"
}

# ─── Main menu ───────────────────────────────────────────────────────────────

main_menu() {
    local options=(
        "Start VPN (up)"
        "Stop VPN (down)"
        "Show Status"
        "Show Config"
        "Edit Config"
        "Exit"
    )

    while true; do
        select_with_arrows "WireGuard VPN Manager - Main Menu" "${options[@]}"
        local choice=$?

        case $choice in
            0) do_up ;;
            1) do_down ;;
            2) do_status ;;
            3) do_config ;;
            4) do_edit ;;
            5|255)
                clear
                exit 0
                ;;
        esac
    done
}

# ─── CLI entrypoint ──────────────────────────────────────────────────────────

case "${1:-}" in
    up)     do_up ;;
    down)   do_down ;;
    status) do_status ;;
    config) do_config ;;
    edit)   do_edit ;;
    menu|"") main_menu ;;
    *)
        echo "Usage: wireguard-vpn [up|down|status|config|edit|menu]"
        echo ""
        echo "  up      - Start VPN (select from available configs)"
        echo "  down    - Stop VPN (select from active interfaces)"
        echo "  status  - Show current WireGuard status"
        echo "  config  - Display configuration (keys hidden)"
        echo "  edit    - Edit config files (TUI picker)"
        echo "  menu    - Show interactive TUI menu (default)"
        exit 1
        ;;
esac