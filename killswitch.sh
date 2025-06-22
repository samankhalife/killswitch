#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; NC='\033[0m'

CONFIG_FILE="killswitch.conf"

get_ip_addresses() {
    MY_IPV4=$(curl -4 -s ifconfig.me)
    MY_IPV6=$(curl -6 -s ifconfig.me)
    [[ -z "$MY_IPV4" && -z "$MY_IPV6" ]] && {
        echo -e "${RED}Error: IP retrieval failed.${NC}"; exit 1;
    }
}

apply_firewall_rule() {
    [[ -n "$MY_IPV4" ]] && {
        iptables -I OUTPUT ! -s "$MY_IPV4" -j DROP
        echo -e "${GREEN}IPv4 killswitch: only $MY_IPV4 allowed.${NC}"
    }
    [[ -n "$MY_IPV6" ]] && {
        ip6tables -I OUTPUT ! -s "$MY_IPV6" -j DROP
        echo -e "${GREEN}IPv6 killswitch: only $MY_IPV6 allowed.${NC}"
    }
    save_firewall_rules
}

remove_firewall_rule() {
    [[ -n "$MY_IPV4" ]] && iptables -D OUTPUT ! -s "$MY_IPV4" -j DROP
    [[ -n "$MY_IPV6" ]] && ip6tables -D OUTPUT ! -s "$MY_IPV6" -j DROP
    save_firewall_rules
    echo -e "${GREEN}Killswitch deactivated.${NC}"
}

save_firewall_rules() {
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
}

activate_killswitch() {
    echo -e "${YELLOW}Activating killswitch...${NC}"
    get_ip_addresses
    echo -e "${CYAN}IPv4: $MY_IPV4 | IPv6: $MY_IPV6${NC}"
    apply_firewall_rule
}

deactivate_killswitch() {
    echo -e "${YELLOW}Deactivating killswitch...${NC}"
    remove_firewall_rule
}

view_rules() {
    echo -e "${YELLOW}IPv4 Rules:${NC}"; iptables -L
    echo -e "${YELLOW}IPv6 Rules:${NC}"; ip6tables -L
}

block_ip() {
    read -p "Enter IP to block: " ip
    if [[ "$ip" == *:* ]]; then
        ip6tables -A OUTPUT -d "$ip" -j DROP
    else
        iptables -A OUTPUT -d "$ip" -j DROP
    fi
    echo -e "${RED}Blocked traffic to $ip${NC}"
    save_firewall_rules
}

unblock_ip() {
    read -p "Enter IP to unblock: " ip
    if [[ "$ip" == *:* ]]; then
        ip6tables -D OUTPUT -d "$ip" -j DROP
    else
        iptables -D OUTPUT -d "$ip" -j DROP
    fi
    echo -e "${GREEN}Unblocked traffic to $ip${NC}"
    save_firewall_rules
}

configure_vpn() {
    read -p "VPN interface (e.g., tun0): " vpn
    iptables -I OUTPUT -o "$vpn" -j ACCEPT
    ip6tables -I OUTPUT -o "$vpn" -j ACCEPT
    echo -e "${GREEN}VPN traffic via $vpn allowed.${NC}"
    save_firewall_rules
}

view_interfaces() {
    echo -e "${YELLOW}Available interfaces:${NC}"
    ip -o link show | awk -F': ' '{print $2}'
}

save_config() {
    echo -e "${YELLOW}Saving config...${NC}"
    echo "MY_IPV4=$MY_IPV4" > "$CONFIG_FILE"
    echo "MY_IPV6=$MY_IPV6" >> "$CONFIG_FILE"
    echo -e "${GREEN}Saved to $CONFIG_FILE${NC}"
}

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}Loaded config.${NC}"
    else
        echo -e "${RED}No config file found.${NC}"
    fi
}

monitor_ip() {
    echo -e "${YELLOW}Monitoring IP changes... (Ctrl+C to stop)${NC}"
    while true; do
        current_ipv4=$(curl -4 -s ifconfig.me)
        current_ipv6=$(curl -6 -s ifconfig.me)
        [[ "$current_ipv4" != "$MY_IPV4" || "$current_ipv6" != "$MY_IPV6" ]] && {
            echo -e "${RED}IP changed! Re-applying killswitch...${NC}"
            activate_killswitch
        }
        sleep 2
    done
}

main_menu() {
    while true; do
        echo -e "${BLUE}==== Killswitch Menu ====${NC}"
        echo -e "${GREEN}1)${NC} Activate killswitch"
        echo -e "${GREEN}2)${NC} Deactivate killswitch"
        echo -e "${GREEN}3)${NC} View rules"
        echo -e "${GREEN}4)${NC} Block IP"
        echo -e "${GREEN}5)${NC} Unblock IP"
        echo -e "${GREEN}6)${NC} Configure VPN"
        echo -e "${GREEN}7)${NC} List interfaces"
        echo -e "${GREEN}8)${NC} Monitor IP changes"
        echo -e "${GREEN}9)${NC} Save config"
        echo -e "${GREEN}10)${NC} Load config"
        echo -e "${GREEN}11)${NC} Exit"

        read -p "Choice: " opt
        case $opt in
            1) activate_killswitch ;;
            2) deactivate_killswitch ;;
            3) view_rules ;;
            4) block_ip ;;
            5) unblock_ip ;;
            6) configure_vpn ;;
            7) view_interfaces ;;
            8) monitor_ip ;;
            9) save_config ;;
            10) load_config ;;
            11) echo -e "${RED}Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
    done
}

main_menu
