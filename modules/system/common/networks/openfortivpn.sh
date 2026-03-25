#!/usr/bin/env bash

# OpenFortiVPN Manager
# Mirrors wireguard-vpn script structure

CONFIG_DIR="$HOME/vpn"
CONFIG_FILE="$CONFIG_DIR/vpn-config"
NIX_PACKAGE="openfortivpn"
PID_FILE="/tmp/openfortivpn.pid"
LOG_FILE="/tmp/openfortivpn.log"

# Colors for TUI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}OpenFortiVPN Manager${NC}                  ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${CYAN}Current VPN status:${NC}"
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "  ${GREEN}● Active${NC} (PID: $pid)"
            # Try to show gateway from config
            if [[ -f "$CONFIG_FILE" ]]; then
                local host
                host=$(grep -E "^host\s*=" "$CONFIG_FILE" 2>/dev/null | head -1 | awk -F'=' '{print $2}' | xargs)
                [[ -n "$host" ]] && echo -e "  Gateway: ${CYAN}$host${NC}"
            fi
        else
            echo -e "  ${RED}● Not running${NC} (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "  ${RED}● Not connected${NC}"
    fi
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
    echo -e "${CYAN}OpenFortiVPN Status:${NC}"
    echo ""

    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "  ${GREEN}● Connected${NC}"
            echo -e "  PID: $pid"
            echo ""
            echo -e "${CYAN}Process info:${NC}"
            ps -p "$pid" -o pid,etime,cmd 2>/dev/null || true
        else
            echo -e "  ${RED}● Not running${NC} (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "  ${RED}● Not connected${NC}"
    fi

    echo ""

    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${CYAN}Recent log (last 10 lines):${NC}"
        tail -10 "$LOG_FILE"
    fi

    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read
}

do_up() {
    # Find all config files in CONFIG_DIR starting with "vpn"
    local configs=()
    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r file; do
            configs+=("$(basename "$file")")
        done < <(find "$CONFIG_DIR" -maxdepth 1 \( -name "vpn-config*" -o -name "openforti*.conf" \) -type f | sort)
    fi

    # Fallback: use default config file if no configs found by pattern
    if [[ ${#configs[@]} -eq 0 && -f "$CONFIG_FILE" ]]; then
        configs+=("$(basename "$CONFIG_FILE")")
    fi

    if [[ ${#configs[@]} -eq 0 ]]; then
        clear
        print_header
        echo -e "${RED}No OpenFortiVPN configs found in $CONFIG_DIR${NC}"
        echo -e "Expected files matching: vpn-config* or openforti*.conf"
        echo ""
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read
        return
    fi

    local chosen_config
    if [[ ${#configs[@]} -eq 1 ]]; then
        chosen_config="${configs[0]}"
    else
        select_with_arrows "Select OpenFortiVPN config to start:" "${configs[@]}"
        local result=$?
        if [[ $result -eq 255 ]] || [[ $result -lt 0 ]] || [[ $result -ge ${#configs[@]} ]]; then
            return
        fi
        chosen_config="${configs[$result]}"
    fi

    clear
    print_header
    echo -e "${YELLOW}Starting VPN with: ${chosen_config}${NC}"
    echo ""

    # Check if already running
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${RED}VPN is already running (PID: $pid)${NC}"
            echo -e "${CYAN}Press Enter to continue...${NC}"
            read
            return
        fi
        rm -f "$PID_FILE"
    fi

    # Prompt for sudo password (always needed since we lose the TTY when
    # detaching). Also prompt for VPN password if not in config.
    # We collect both here while we still have an interactive terminal.
    echo -e "${CYAN}Sudo password required to launch VPN:${NC}"
    read -rsp "  [sudo] password for $USER: " sudo_pass
    echo ""

    if ! echo "$sudo_pass" | sudo -S true 2>/dev/null; then
        echo -e "${RED}✗ Incorrect sudo password.${NC}"
        echo ""; echo -e "${CYAN}Press Enter to continue...${NC}"; read; return
    fi

    local vpn_pass=""
    if ! grep -qE "^password\s*=" "$CONFIG_DIR/$chosen_config" 2>/dev/null; then
        echo -e "${CYAN}No password in config — enter VPN account password:${NC}"
        read -rsp "  VPN password: " vpn_pass
        echo ""
    fi

    echo -e "${CYAN}Connecting... (output below)${NC}"; echo ""

    # Build the openfortivpn command as an array
    local cmd=(openfortivpn -c "$CONFIG_DIR/$chosen_config")
    [[ -n "$vpn_pass" ]] && cmd+=(--password="$vpn_pass")

    # Launch: feed sudo password via a here-string, detach with setsid+nohup
    # The subshell writes its PID before exec-ing into sudo so PID stays stable
    nix-shell -p "$NIX_PACKAGE" --run "
        setsid bash -c '
            echo \$\$ > \"$PID_FILE\"
            exec echo \"$sudo_pass\" | sudo -S ${cmd[*]}
        ' > \"$LOG_FILE\" 2>&1 &
    "

    echo -e "${CYAN}── log ─────────────────────────────────────${NC}"
    sleep 1
    tail -f "$LOG_FILE" &
    local tail_pid=$!
    sleep 5
    kill "$tail_pid" 2>/dev/null
    wait "$tail_pid" 2>/dev/null
    echo -e "${CYAN}────────────────────────────────────────────${NC}"; echo ""

    if [[ -f "$PID_FILE" ]] && [[ -s "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo -e "${GREEN}✓ VPN connected (PID: $(cat "$PID_FILE"))${NC}"
    else
        echo -e "${RED}✗ VPN failed to connect — full log: $LOG_FILE${NC}"
        tail -5 "$LOG_FILE" 2>/dev/null || true
    fi

    echo ""; echo -e "${CYAN}Press Enter to continue...${NC}"; read
}

do_down() {
    clear
    print_header

    if [[ ! -f "$PID_FILE" ]]; then
        echo -e "${RED}No active OpenFortiVPN session found.${NC}"
        echo ""
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read
        return
    fi

    local pid
    pid=$(cat "$PID_FILE")

    if ! kill -0 "$pid" 2>/dev/null; then
        echo -e "${RED}VPN is not running (stale PID file removed).${NC}"
        rm -f "$PID_FILE"
        echo ""
        echo -e "${CYAN}Press Enter to continue...${NC}"
        read
        return
    fi

    echo -e "${YELLOW}Stopping VPN (PID: $pid)...${NC}"
    sudo kill "$pid" 2>/dev/null || true
    sleep 1

    # Force kill if still running
    if kill -0 "$pid" 2>/dev/null; then
        sudo kill -9 "$pid" 2>/dev/null || true
    fi

    rm -f "$PID_FILE"
    echo -e "${GREEN}✓ VPN stopped${NC}"
    sleep 2
}

do_config() {
    clear
    print_header
    echo -e "${CYAN}OpenFortiVPN Configuration:${NC}"
    echo ""

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}No config file found at: $CONFIG_FILE${NC}"
        echo ""
        echo -e "Create one with the format:"
        echo -e "${YELLOW}host = vpn.example.com${NC}"
        echo -e "${YELLOW}port = 443${NC}"
        echo -e "${YELLOW}username = your_username${NC}"
        echo -e "${YELLOW}password = your_password  # or leave empty to prompt${NC}"
        echo -e "${YELLOW}trusted-cert = <fingerprint>${NC}"
    else
        echo -e "${CYAN}Config file: ${YELLOW}$CONFIG_FILE${NC}"
        echo ""
        # Show config but mask password field
        while IFS= read -r line; do
            if echo "$line" | grep -qiE "^(password|passwd)\s*="; then
                local key
                key=$(echo "$line" | cut -d'=' -f1)
                echo -e "${key}= ${RED}[hidden]${NC}"
            else
                echo "$line"
            fi
        done < "$CONFIG_FILE"
    fi

    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read
}

do_edit() {
    local files=()

    if [[ -d "$CONFIG_DIR" ]]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$CONFIG_DIR" -maxdepth 1 \( -name "vpn-config*" -o -name "openforti*.conf" \) -type f | sort)
    fi

    # If no files found, offer to create default
    if [[ ${#files[@]} -eq 0 ]]; then
        clear
        print_header
        echo -e "${YELLOW}No config files found. Create default config at $CONFIG_FILE? [y/N]${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            mkdir -p "$CONFIG_DIR"
            cat > "$CONFIG_FILE" <<'EOF'
host = vpn.example.com
port = 443
username = your_username
# password = your_password
# trusted-cert = <fingerprint>
# set-dns = 1
# pppd-use-peerdns = 1
EOF
            echo -e "${GREEN}✓ Created $CONFIG_FILE${NC}"
            sleep 1
            ${EDITOR:-nano} "$CONFIG_FILE"
        fi
        return
    fi

    local file_names=()
    for f in "${files[@]}"; do
        file_names+=("$(basename "$f")")
    done
    file_names+=("[ Open config directory ]")

    select_with_arrows "Select file to edit:" "${file_names[@]}"
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
        # Try common file managers in order
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
        select_with_arrows "OpenFortiVPN Manager - Main Menu" "${options[@]}"
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
        echo "Usage: openfortivpn-vpn [up|down|status|config|edit|menu]"
        echo ""
        echo "  up      - Start VPN (select from available configs)"
        echo "  down    - Stop running VPN"
        echo "  status  - Show current VPN status"
        echo "  config  - Display current configuration"
        echo "  edit    - Edit config files (TUI picker)"
        echo "  menu    - Show interactive TUI menu (default)"
        exit 1
        ;;
esac