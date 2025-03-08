#!/bin/bash

# Define the backup directory
BACKUP_DIR="/media/media"

# Check if the directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory at $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"
else
    echo "Backup directory already exists at $BACKUP_DIR"
fi

# Backup SSH Configuration
echo "Backing up SSH configurations..."
if [ ! -d "$BACKUP_DIR/ssh" ]; then
    sudo mkdir -p "$BACKUP_DIR/ssh"
fi
# Backup SSH host keys and configurations
sudo cp -r /etc/ssh/ssh_host_* "$BACKUP_DIR/ssh/"
sudo cp /etc/ssh/sshd_config "$BACKUP_DIR/ssh/sshd_config.bak"
sudo cp /etc/crypto-policies/back-ends/opensshserver.config "$BACKUP_DIR/ssh/opensshserver.config.bak"

# Backup firewall (iptables) configuration
echo "Backing up iptables configuration..."
if [ ! -d "$BACKUP_DIR/iptables" ]; then
    sudo mkdir -p "$BACKUP_DIR/iptables"
fi
sudo iptables-save > "$BACKUP_DIR/iptables/iptables.conf"

# Backup firewall (firewalld) configuration
echo "Backing up firewalld configuration..."
if [ ! -d "$BACKUP_DIR/firewalld" ]; then
    sudo mkdir -p "$BACKUP_DIR/firewalld"
fi
# Save all firewalld rules
sudo firewall-cmd --permanent --list-all > "$BACKUP_DIR/firewalld/firewall_rules.txt"
sudo firewall-cmd --permanent --direct --list-all > "$BACKUP_DIR/firewalld/firewall_direct_rules.txt"

# Backup FTP (vsftpd) configuration
echo "Backing up vsftpd configuration..."
if [ ! -d "$BACKUP_DIR/vsftpd" ]; then
    sudo mkdir -p "$BACKUP_DIR/vsftpd"
fi
# Backup vsftpd config
sudo cp /etc/vsftpd/vsftpd.conf "$BACKUP_DIR/vsftpd/vsftpd.conf.bak"

# Notify the user that the backup is complete
echo "Backup complete. All important configurations have been copied to $BACKUP_DIR."
