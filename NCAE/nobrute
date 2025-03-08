#!/bin/bash

# Adding firewall rules for limiting SSH connections (IPv4 and IPv6)

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Add the rule for IPv4 (SSH connection limiting)
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP

# Add the rule for IPv6 (SSH connection limiting)
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP

# Reload firewall to apply changes
firewall-cmd --reload

# Notify user of completion
echo "Firewall rules added and reloaded successfully."
