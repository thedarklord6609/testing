#!/bin/bash

# Define the list of FTP scoring users
users=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

# Step 1: Install necessary packages
echo "Installing vsftpd..."
sudo apt-get update
sudo apt-get install -y vsftpd acl nano

# Step 2: Disable anonymous FTP login
echo "Disabling anonymous FTP login..."
sudo sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf

# Step 3: Create scoringusers group and add users
echo "Creating scoringusers group and adding users..."
sudo groupadd scoringusers
for user in "${users[@]}"; do
    # Create user without home directory and with no login shell
    sudo useradd -m -s /bin/bash -G scoringusers $user
    # Set a default password for the users (change it as needed)
    echo "$user:password" | sudo chpasswd
    # Remove any other groups the user might be in
    sudo usermod -G scoringusers $user
done

# Step 4: Set up /mnt/files and its permissions
echo "Setting up /mnt/files directory..."
sudo mkdir -p /mnt/files
sudo chown root:scoringusers /mnt/files
sudo chmod 770 /mnt/files

# Apply read and write permissions for all users in scoringusers group
for user in "${users[@]}"; do
    sudo setfacl -m u:$user:rwX /mnt/files  # rwX allows read/write and cd, but not execution
done

# Prevent executable files in /mnt/files
echo "Preventing executable files in /mnt/files..."
sudo find /mnt/files -type f -exec chmod 664 {} \;  # Files: rw-rw-r-- (No Execute)
sudo find /mnt/files -type d -exec chmod 770 {} \;  # Directories: rwxrwx--- (Users can cd)

# Step 5: Set umask to prevent execution on new files
echo "Setting umask to prevent executable files..."
echo "umask 0027" | sudo tee -a /etc/profile

# Step 6: Configure vsftpd to restrict users to /mnt/files
echo "Configuring vsftpd..."
# Backup the original vsftpd.conf
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
# Set up local_root to /mnt/files and restrict users to that directory
echo "local_root=/mnt/files" | sudo tee -a /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" | sudo tee -a /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" | sudo tee -a /etc/vsftpd/vsftpd.conf
# Disable anonymous login
echo "anonymous_enable=NO" | sudo tee -a /etc/vsftpd/vsftpd.conf

# Step 7: Restart vsftpd service to apply changes
echo "Restarting vsftpd..."
sudo systemctl restart vsftpd

# Step 8: Ensure users can modify, create, touch, nano, ls in /mnt/files
echo "Ensuring users can modify, create, touch, use nano, and ls in /mnt/files..."
# Grant read, write, and execute permissions on /mnt/files (only for the users)
sudo chmod 770 /mnt/files
for user in "${users[@]}"; do
    sudo setfacl -m u:$user:rwx /mnt/files
    sudo setfacl -m u:$user:rwX /mnt/files/*  # Allow file modifications without execution
done

# Ensure nano and touch are executable for users
echo "Ensuring nano and touch are executable..."
sudo chmod +x /usr/bin/nano
sudo chmod +x /usr/bin/touch

# Step 9: Verify that users are in the correct group and have necessary permissions
echo "Verifying users in the scoringusers group and permissions..."
for user in "${users[@]}"; do
    groups $user
    ls -ld /mnt/files
    ls -l /mnt/files
done

echo "FTP server setup complete. Only the users in scoringusers group can read/write in /mnt/files, and no executables are allowed in that directory. Users can modify, create, and touch files, use nano, and ls."
