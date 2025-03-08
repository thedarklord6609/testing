#!/bin/bash

# Define the backup directory
BACKUP_DIR="/media/media"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR does not exist. Please ensure backup is present."
    exit 1
fi

# Step 1: Restore SSH configurations
echo "Restoring SSH configurations..."
if [ -d "$BACKUP_DIR/ssh" ]; then
    sudo cp -r "$BACKUP_DIR/ssh/ssh_host_*" /etc/ssh/
    sudo cp "$BACKUP_DIR/ssh/sshd_config.bak" /etc/ssh/sshd_config
    sudo cp "$BACKUP_DIR/ssh/opensshserver.config.bak" /etc/crypto-policies/back-ends/opensshserver.config
else
    echo "No SSH backup found!"
fi

# Step 2: Restore iptables configuration
echo "Restoring iptables configuration..."
if [ -f "$BACKUP_DIR/iptables/iptables.conf" ]; then
    sudo iptables-restore < "$BACKUP_DIR/iptables/iptables.conf"
else
    echo "No iptables backup found!"
fi

# Step 3: Restore firewalld configuration
echo "Restoring firewalld configuration..."
if [ -d "$BACKUP_DIR/firewalld" ]; then
    # Restore the firewalld rules
    sudo firewall-cmd --permanent --remove-all-rules
    sudo firewall-cmd --permanent --direct --remove-all-rules
    sudo firewall-cmd --permanent --add-rich-rule="$BACKUP_DIR/firewalld/firewall_rules.txt"
    sudo firewall-cmd --permanent --direct --add-rich-rule="$BACKUP_DIR/firewalld/firewall_direct_rules.txt"
    sudo systemctl reload firewalld
else
    echo "No firewalld backup found!"
fi

# Step 4: Restore vsftpd configuration
echo "Restoring vsftpd configuration..."
if [ -d "$BACKUP_DIR/vsftpd" ]; then
    sudo cp "$BACKUP_DIR/vsftpd/vsftpd.conf.bak" /etc/vsftpd/vsftpd.conf
else
    echo "No vsftpd backup found!"
fi

# Notify the user that the restore is complete
echo "Restore process complete. All important configurations have been restored."
