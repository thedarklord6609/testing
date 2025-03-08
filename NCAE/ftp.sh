#!/bin/bash

# Define the list of FTP scoring users
users=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

# Step 1: Disable anonymous FTP login
echo "Disabling anonymous FTP login..."
sudo sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf

# Step 2: Restrict FTP users to /mnt/files only (chroot)
echo "Restricting FTP users to /mnt/files..."
sudo sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
sudo sed -i 's/^#allow_writeable_chroot=YES/allow_writeable_chroot=YES/' /etc/vsftpd/vsftpd.conf
echo "local_root=/mnt/files" | sudo tee -a /etc/vsftpd/vsftpd.conf

# Step 3: Ensure /mnt/files exists and set permissions
echo "Setting permissions for /mnt/files..."

# Ensure /mnt/files exists
sudo mkdir -p /mnt/files

# Remove execute permissions for everyone
sudo chmod -R a-x /mnt/files

# Apply read and write permission for FTP scoring users
for user in "${users[@]}"; do
  sudo setfacl -m u:$user:rw /mnt/files/*
done

# Ensure the directory itself has read and write permissions, but no execute permissions
sudo chmod 664 /mnt/files/*

# Ensure no execute permissions on files and directories
sudo find /mnt/files/ -type f -exec chmod 644 {} \;
sudo find /mnt/files/ -type d -exec chmod 755 {} \;

# Step 4: Prevent executable files from being created in /mnt/files
echo "Setting umask to prevent executables from being created..."
echo "umask 0022" | sudo tee -a /etc/profile

# Step 5: Restart vsftpd service
echo "Restarting vsftpd service..."
sudo systemctl restart vsftpd

# Step 6: Verify the FTP setup
echo "Configuration complete. Verifying the FTP setup..."
sudo systemctl status vsftpd

# End of script
echo "FTP configuration and permission setup completed."
