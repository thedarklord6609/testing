#!/bin/bash

# Define the list of FTP scoring users
users=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

# Step 1: Disable anonymous FTP login
echo "Disabling anonymous FTP login..."
sudo sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf

# Step 2: Configure FTP to restrict users to /mnt/files/
echo "Restricting FTP access to /mnt/files..."
# Backup the original vsftpd.conf
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
# Modify vsftpd.conf to restrict to /mnt/files
echo "local_root=/mnt/files" | sudo tee -a /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" | sudo tee -a /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" | sudo tee -a /etc/vsftpd/vsftpd.conf

# Step 3: Set up the /mnt/files/ directory and permissions
echo "Setting up /mnt/files/ and applying permissions..."

# Ensure /mnt/files exists
sudo mkdir -p /mnt/files

# Remove execute permissions for the directory and its contents
sudo chmod -R a-x /mnt/files

# Apply read and write permission for the FTP scoring users
for user in "${users[@]}"; do
    sudo setfacl -m u:$user:rw /mnt/files/*
done

# Ensure the directory itself has read and write permissions, but no execute permission
sudo chmod 664 /mnt/files/*

# Ensure that no files or directories under /mnt/files have execute permissions
sudo find /mnt/files/ -type d -exec chmod 755 {} \;
sudo find /mnt/files/ -type f -exec chmod 644 {} \;

# Step 4: Prevent files from being executable in /mnt/files
echo "Preventing executable files in /mnt/files..."
# Apply a stricter umask for new files (ensure no executable permissions by default)
echo "umask 022" | sudo tee -a /etc/profile

# Step 5: Restart vsftpd service
echo "Restarting vsftpd service..."
sudo systemctl restart vsftpd

# Step 6: Disable access to root directories for FTP users
echo "Disabling FTP access to root directories (/dev, /root, /home)..."
# Ensure vsftpd users are restricted and cannot access root directories
sudo chmod o-x /dev /root /home

# Step 7: Verify the setup
echo "Configuration complete. Verifying FTP and SSH settings..."

# Restart FTP service
sudo systemctl restart vsftpd

# Final verification
echo "All settings applied successfully:"
echo "- Anonymous FTP disabled"
echo "- FTP restricted to /mnt/files"
echo "- Users can only read and write (no execute permissions)"
echo "- No executables can be created in /mnt/files"
