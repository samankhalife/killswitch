# Killswitch Script

This tool provides an IP-based killswitch using `iptables` to block outgoing traffic if your public IP changes. It also allows you to configure VPN traffic, block or unblock specific IP addresses, and monitor real-time IP changes. The script is customizable and can save/load configurations for easy use.

## Installation

To install and run the killswitch tool, execute the following command in your terminal:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/samankhalife/killswitch/refs/heads/main/install.sh)
```

> **Note**: Make sure that `curl` is installed on your system. If not, you can install it using the following command:
> 
> - On Ubuntu/Debian: `sudo apt-get install curl`
> - On CentOS/RedHat: `sudo yum install curl`

## Features and Usage

The script provides an interactive menu where you can choose the following options:

1. **Activate killswitch**:  
   Activate the killswitch and block all traffic if your public IP changes.

2. **Deactivate killswitch**:  
   Remove the killswitch and allow traffic as normal.

3. **View iptables rules**:  
   Display the current `iptables` rules to see active traffic restrictions.

4. **Block an IP**:  
   Manually block outgoing traffic to a specific IP address.

5. **Unblock an IP**:  
   Remove the block for a specific IP address.

6. **Configure VPN interface**:  
   Set your VPN interface (e.g., `tun0`) to allow VPN traffic while the killswitch is active.

7. **View available network interfaces**:  
   List all available network interfaces on your system.

8. **Monitor IP changes**:  
   Monitor real-time IP changes and activate the killswitch automatically if your public IP changes.

9. **Save current configuration**:  
   Save the current IP and VPN interface settings to a configuration file (`killswitch.conf`).

10. **Load saved configuration**:  
    Load a previously saved configuration to restore your killswitch settings.

11. **Exit**:  
    Exit the script.

## Commands via Menu

You can choose options either by typing the number or by entering the associated keyword:
- **Example**: Type `1` or `activate` to activate the killswitch.

### Example Use Case

1. **Activate the killswitch**:  
   Run the script:
   ```bash
   killswitch
   ```
   Select option `1` or type `activate`.

2. **Block a specific IP**:  
   Choose option `4`, then enter the IP address you want to block.

3. **Monitor IP changes**:  
   Enable real-time monitoring by selecting option `8`. If your public IP changes, the killswitch will automatically engage.

4. **Save the configuration**:  
   Use option `9` to save your current IP and VPN interface settings for future use.

## Configuration

The script saves the following settings in the `killswitch.conf` file:
- **MY_IP**: Your current public IP address, used for blocking traffic if it changes.
- **VPN_INTERFACE**: The VPN interface to allow traffic when the killswitch is active.

### Loading Saved Configuration

To load the saved configuration:
```bash
killswitch
```
Then select option `10` or type `load` to apply the previously saved settings.

## Troubleshooting

If you encounter any issues with the killswitch, ensure that:
- Your `iptables` is properly configured.
- The `killswitch.conf` file has been correctly saved.
- You have the necessary permissions to execute the script (use `chmod +x killswitch.sh` if needed).
