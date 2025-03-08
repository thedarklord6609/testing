#!/bin/bash

# Define the list of FTP scoring users
users=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

# Step 1: Configure vsftpd to restrict users to /mnt/files/
echo "Configuring vsftpd..."

# Backup the original vsftpd.conf
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

# Modify vsftpd.conf to restrict to /mnt/files
sudo sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
sudo sed -i 's/^#allow_writeable_chroot=YES/allow_writeable_chroot=YES/' /etc/vsftpd/vsftpd.conf
echo "local_root=/mnt/files" | sudo tee -a /etc/vsftpd/vsftpd.conf

# Step 2: Set up the /mnt/files/ directory and permissions
echo "Setting permissions on /mnt/files..."

# Ensure /mnt/files exists
sudo mkdir -p /mnt/files

# Remove execute permissions for the directory and its contents
sudo chmod -R a-x /mnt/files

# Apply read and write permission for the FTP scoring users
for user in "${users[@]}"; do
  sudo setfacl -m u:$user:rw /mnt/files/*
done

# Ensure the directory itself has read and write permission, but no execute permission
sudo chmod 664 /mnt/files/*

# Ensure that no files or directories under /mnt/files have execute permissions
sudo find /mnt/files/ -type d -exec chmod 755 {} \;
sudo find /mnt/files/ -type f -exec chmod 644 {} \;

# Step 3: Remove the ability to set executable permissions on files in /mnt/files
# This step removes execute permissions for everyone, including future files.
echo "Restricting file creation to prevent executable files..."

# Apply the umask (to disallow execute permissions on new files)
# Set default umask to 0022, which prevents executable files for new files.
echo "umask 0022" | sudo tee -a /etc/profile

# Step 4: Restart vsftpd service
echo "Restarting vsftpd service..."
sudo systemctl restart vsftpd

# Step 5: Verify the setup
echo "Configuration complete. Verifying the FTP setup..."
sudo systemctl status vsftpd
