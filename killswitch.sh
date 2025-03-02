#!/bin/bash
activate_killswitch() {
    echo "Activating killswitch..."
    MY_IP=$(curl -s ifconfig.me)
    if [ -z "$MY_IP" ]; then
        echo "Error: Could not retrieve the current IP address."
        exit 1
    fi
    echo "Your current IP address is: $MY_IP"
    iptables -I OUTPUT ! -s $MY_IP -j DROP
    echo "Killswitch activated: Only traffic from IP address $MY_IP is allowed."
    iptables-save > /etc/iptables/rules.v4
}

deactivate_killswitch() {
    echo "Deactivating killswitch..."
    iptables -D OUTPUT ! -s $MY_IP -j DROP
    iptables-save > /etc/iptables/rules.v4
    echo "Killswitch deactivated."
}

view_rules() {
    echo "Current iptables rules:"
    iptables -L
}

block_ip() {
    read -p "Enter the IP address to block: " ip_to_block
    iptables -A OUTPUT -d $ip_to_block -j DROP
    echo "Blocked traffic to $ip_to_block"
    iptables-save > /etc/iptables/rules.v4
}

unblock_ip() {
    read -p "Enter the IP address to unblock: " ip_to_unblock
    iptables -D OUTPUT -d $ip_to_unblock -j DROP
    echo "Unblocked traffic to $ip_to_unblock"
    iptables-save > /etc/iptables/rules.v4
}

configure_vpn() {
    read -p "Enter your VPN interface name (e.g., tun0): " vpn_interface
    iptables -I OUTPUT -o $vpn_interface -j ACCEPT
    echo "VPN traffic through $vpn_interface is now allowed."
    iptables-save > /etc/iptables/rules.v4
}

view_interfaces() {
    echo "Available network interfaces:"
    ifconfig -a | awk '/^[a-zA-Z0-9]/ {print $1}'
}

save_config() {
    echo "Saving configuration to killswitch.conf..."
    echo "MY_IP=$MY_IP" > killswitch.conf
    echo "Configuration saved."
}

load_config() {
    if [ -f killswitch.conf ]; then
        echo "Loading configuration from killswitch.conf..."
        source killswitch.conf
        echo "Configuration loaded."
    else
        echo "No configuration file found."
    fi
}

monitor_ip() {
    while true; do
        current_ip=$(curl -s ifconfig.me)
        if [ "$current_ip" != "$MY_IP" ]; then
            echo "IP has changed from $MY_IP to $current_ip. Activating killswitch..."
            activate_killswitch
        fi
        sleep 2
    done
}

# Main menu
while true; do
    echo "==== Killswitch Menu ===="
    echo "1) Activate killswitch"
    echo "2) Deactivate killswitch"
    echo "3) View iptables rules"
    echo "4) Block an IP"
    echo "5) Unblock an IP"
    echo "6) Configure VPN interface"
    echo "7) View available network interfaces"
    echo "8) Monitor IP changes"
    echo "9) Save current configuration"
    echo "10) Load saved configuration"
    echo "11) Exit"
    
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
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
