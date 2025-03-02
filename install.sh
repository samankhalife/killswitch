#!/bin/bash
if ! command -v ifconfig &> /dev/null; then
    echo "ifconfig could not be found. Installing net-tools package..."

    # Check if the user is using a Debian-based system
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y net-tools

    # Check if the user is using an RHEL-based system
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y net-tools
    else
        echo "Unsupported Linux distribution. Please install net-tools manually."
        exit 1
    fi
else
    echo "ifconfig is already installed."
fi
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="killswitch"
sudo curl -Ls https://raw.githubusercontent.com/samankhalife/killswitch/main/killswitch.sh -o "$INSTALL_DIR/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
"$INSTALL_DIR/$SCRIPT_NAME"

# Delete the install.sh script after execution
rm -- "$0"
