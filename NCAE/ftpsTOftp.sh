#!/bin/bash

# Variables
FTP_USER="ftpuser"  # FTP user to remove
SSL_DIR="/etc/ssl"
SSL_CERT="$SSL_DIR/certs/ftps_server.crt"
SSL_KEY="$SSL_DIR/private/ftps_server.key"
VSFTPD_CONF="/etc/vsftpd.conf"
VSFTPD_SERVICE="vsftpd"

# Stop and disable vsftpd service
echo "Stopping and disabling vsftpd service..."
sudo systemctl stop $VSFTPD_SERVICE
sudo systemctl disable $VSFTPD_SERVICE

# Restore the original vsftpd.conf file (from backup)
echo "Restoring the original vsftpd.conf file..."
if [ -f "$VSFTPD_CONF.bak" ]; then
    sudo mv $VSFTPD_CONF.bak $VSFTPD_CONF
else
    echo "Backup of vsftpd.conf not found, skipping restoration."
fi

# Remove the FTP user and its files
echo "Removing FTP user and home directory..."
sudo userdel -r $FTP_USER

# Remove SSL certificates
echo "Removing SSL certificates..."
if [ -f "$SSL_CERT" ]; then
    sudo rm -f $SSL_CERT
else
    echo "SSL certificate not found, skipping removal."
fi

if [ -f "$SSL_KEY" ]; then
    sudo rm -f $SSL_KEY
else
    echo "SSL private key not found, skipping removal."
fi

# Uninstall vsftpd and OpenSSL
echo "Uninstalling vsftpd and OpenSSL..."
sudo apt remove --purge -y vsftpd openssl

# Revert firewall changes
echo "Reverting firewall changes..."
sudo ufw delete allow 21/tcp
sudo ufw delete allow 990/tcp
sudo ufw reload

# Done
echo "Reversion of FTPS setup is complete."
