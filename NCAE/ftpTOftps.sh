#!/bin/bash

# Variables
FTP_USER="ftpuser"  # Define a username for FTP login
FTP_PASS="ftppassword"  # Define a password for FTP login
SSL_DIR="/etc/ssl"
SSL_CERT="$SSL_DIR/certs/ftps_server.crt"
SSL_KEY="$SSL_DIR/private/ftps_server.key"
VSFTPD_CONF="/etc/vsftpd.conf"

# Update system packages
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install vsftpd and openssl (if not already installed)
echo "Installing vsftpd and OpenSSL..."
sudo apt install -y vsftpd openssl ufw

# Generate SSL certificate
echo "Generating SSL certificate..."
sudo mkdir -p $SSL_DIR/certs $SSL_DIR/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $SSL_KEY -out $SSL_CERT \
    -subj "/C=US/ST=State/L=City/O=Company/OU=IT/CN=localhost"

# Configure vsftpd for FTPS (Explicit FTPS)
echo "Configuring vsftpd for FTPS..."

# Backup the original vsftpd.conf
sudo cp $VSFTPD_CONF $VSFTPD_CONF.bak

# Modify the vsftpd.conf file for FTPS
sudo tee $VSFTPD_CONF > /dev/null <<EOL
# Enable SSL
ssl_enable=YES
rsa_cert_file=$SSL_CERT
rsa_private_key_file=$SSL_KEY

# Allow FTPS connections on port 21 (Explicit FTPS)
listen=YES
listen_ipv6=NO

# Enable explicit FTPS (default)
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH:MEDIUM

# Set FTP to use secure connections
local_enable=YES
write_enable=YES
chroot_local_user=YES

# Allow anonymous login (disable if you don't need this)
anonymous_enable=NO

# Set the user for FTP login (create user if needed)
user_sub_token=\$USER
local_root=/home/\$USER/ftp
EOL

# Create FTP user (if not already existing)
echo "Creating FTP user '$FTP_USER'..."
sudo useradd -m -s /bin/bash $FTP_USER
echo "$FTP_USER:$FTP_PASS" | sudo chpasswd

# Create FTP home directory for the user
sudo mkdir -p /home/$FTP_USER/ftp
sudo chown root:root /home/$FTP_USER
sudo chmod 755 /home/$FTP_USER
sudo chown $FTP_USER:$FTP_USER /home/$FTP_USER/ftp

# Enable vsftpd to start on boot
echo "Enabling vsftpd to start on boot..."
sudo systemctl enable vsftpd

# Restart vsftpd service
echo "Restarting vsftpd service..."
sudo systemctl restart vsftpd

# Allow FTPS through firewall (ports 21 and 990 for FTPS)
echo "Configuring firewall..."
sudo ufw allow 21/tcp
sudo ufw allow 990/tcp
sudo ufw reload

# Show status of vsftpd service
echo "Checking vsftpd service status..."
sudo systemctl status vsftpd

# Done
echo "FTPS server setup complete. You can now connect to FTPS on port 21 (Explicit FTPS)."
