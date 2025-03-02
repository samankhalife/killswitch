#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

activate_killswitch() {
    echo -e "${YELLOW}Activating killswitch...${NC}"
    MY_IPV4=$(curl -4 -s ifconfig.me)
    MY_IPV6=$(curl -6 -s ifconfig.me)

    if [ -z "$MY_IPV4" ] && [ -z "$MY_IPV6" ]; then
        echo -e "${RED}Error: Could not retrieve the current IP addresses.${NC}"
        exit 1
    fi

    echo -e "${CYAN}Your current IPv4 address is: $MY_IPV4${NC}"
    echo -e "${CYAN}Your current IPv6 address is: $MY_IPV6${NC}"

    if [ -n "$MY_IPV4" ]; then
        iptables -I OUTPUT ! -s $MY_IPV4 -j DROP
        echo -e "${GREEN}Killswitch activated for IPv4: Only traffic from IP address $MY_IPV4 is allowed.${NC}"
    fi

    if [ -n "$MY_IPV6" ]; then
        ip6tables -I OUTPUT ! -s $MY_IPV6 -j DROP
        echo -e "${GREEN}Killswitch activated for IPv6: Only traffic from IP address $MY_IPV6 is allowed.${NC}"
    fi

    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
}

deactivate_killswitch() {
    echo -e "${YELLOW}Deactivating killswitch...${NC}"
    iptables -D OUTPUT ! -s $MY_IPV4 -j DROP
    ip6tables -D OUTPUT ! -s $MY_IPV6 -j DROP
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    echo -e "${GREEN}Killswitch deactivated.${NC}"
}

# نمایش قوانین iptables
view_rules() {
    echo -e "${YELLOW}Current iptables rules (IPv4):${NC}"
    iptables -L
    echo -e "${YELLOW}Current ip6tables rules (IPv6):${NC}"
    ip6tables -L
}

block_ip() {
    read -p "Enter the IP address to block: " ip_to_block
    if [[ "$ip_to_block" =~ .*:.* ]]; then
        ip6tables -A OUTPUT -d $ip_to_block -j DROP
        echo -e "${RED}Blocked IPv6 traffic to $ip_to_block${NC}"
        ip6tables-save > /etc/iptables/rules.v6
    else
        iptables -A OUTPUT -d $ip_to_block -j DROP
        echo -e "${RED}Blocked IPv4 traffic to $ip_to_block${NC}"
        iptables-save > /etc/iptables/rules.v4
    fi
}

unblock_ip() {
    read -p "Enter the IP address to unblock: " ip_to_unblock
    if [[ "$ip_to_unblock" =~ .*:.* ]]; then
        ip6tables -D OUTPUT -d $ip_to_unblock -j DROP
        echo -e "${GREEN}Unblocked IPv6 traffic to $ip_to_unblock${NC}"
        ip6tables-save > /etc/iptables/rules.v6
    else
        iptables -D OUTPUT -d $ip_to_unblock -j DROP
        echo -e "${GREEN}Unblocked IPv4 traffic to $ip_to_unblock${NC}"
        iptables-save > /etc/iptables/rules.v4
    fi
}

configure_vpn() {
    read -p "Enter your VPN interface name (e.g., tun0): " vpn_interface
    iptables -I OUTPUT -o $vpn_interface -j ACCEPT
    ip6tables -I OUTPUT -o $vpn_interface -j ACCEPT
    echo -e "${GREEN}VPN traffic through $vpn_interface is now allowed (IPv4 and IPv6).${NC}"
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
}

view_interfaces() {
    echo -e "${YELLOW}Available network interfaces:${NC}"
    ifconfig -a | awk '/^[a-zA-Z0-9]/ {print $1}'
}

save_config() {
    echo -e "${YELLOW}Saving configuration to killswitch.conf...${NC}"
    echo "MY_IPV4=$MY_IPV4" > killswitch.conf
    echo "MY_IPV6=$MY_IPV6" >> killswitch.conf
    echo -e "${GREEN}Configuration saved.${NC}"
}

load_config() {
    if [ -f killswitch.conf ]; then
        echo -e "${YELLOW}Loading configuration from killswitch.conf...${NC}"
        source killswitch.conf
        echo -e "${GREEN}Configuration loaded.${NC}"
    else
        echo -e "${RED}No configuration file found.${NC}"
    fi
}

monitor_ip() {
    while true; do
        current_ipv4=$(curl -4 -s ifconfig.me)
        current_ipv6=$(curl -6 -s ifconfig.me)

        if [ "$current_ipv4" != "$MY_IPV4" ] || [ "$current_ipv6" != "$MY_IPV6" ]; then
            echo -e "${RED}IP has changed. Activating killswitch...${NC}"
            activate_killswitch
        fi
        sleep 2
    done
}

while true; do
    echo -e "${BLUE}==== Killswitch Menu ====${NC}"
    echo -e "${GREEN}1)${NC} ${CYAN}Activate killswitch${NC}"
    echo -e "${GREEN}2)${NC} ${CYAN}Deactivate killswitch${NC}"
    echo -e "${GREEN}3)${NC} ${CYAN}View iptables rules${NC}"
    echo -e "${GREEN}4)${NC} ${CYAN}Block an IP${NC}"
    echo -e "${GREEN}5)${NC} ${CYAN}Unblock an IP${NC}"
    echo -e "${GREEN}6)${NC} ${CYAN}Configure VPN interface${NC}"
    echo -e "${GREEN}7)${NC} ${CYAN}View available network interfaces${NC}"
    echo -e "${GREEN}8)${NC} ${CYAN}Monitor IP changes${NC}"
    echo -e "${GREEN}9)${NC} ${CYAN}Save current configuration${NC}"
    echo -e "${GREEN}10)${NC} ${CYAN}Load saved configuration${NC}"
    echo -e "${GREEN}11)${NC} ${RED}Exit${NC}"

    read -p "Enter your choice (number or keyword): " user_choice

    case $user_choice in
        1 | "activate" | "Activate" )
            activate_killswitch
            ;;
        2 | "deactivate" | "Deactivate" )
            deactivate_killswitch
            ;;
        3 | "view" | "View" )
            view_rules
            ;;
        4 | "block" | "Block" )
            block_ip
            ;;
        5 | "unblock" | "Unblock" )
            unblock_ip
            ;;
        6 | "vpn" | "VPN" )
            configure_vpn
            ;;
        7 | "interfaces" | "Interfaces" )
            view_interfaces
            ;;
        8 | "monitor" | "Monitor" )
            monitor_ip
            ;;
        9 | "save" | "Save" )
            save_config
            ;;
        10 | "load" | "Load" )
            load_config
            ;;
        11 | "exit" | "Exit" )
            echo -e "${RED}Exiting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
done
