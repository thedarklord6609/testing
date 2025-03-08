#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Set the banner message
BANNER_MESSAGE="Server refused to allocate pty"

# Define the path to the banner file
BANNER_FILE="/etc/ssh/sshd_banner.txt"

# Write the message to the banner file
echo "$BANNER_MESSAGE" > "$BANNER_FILE"

# Ensure that the Banner directive in sshd_config is pointing to the correct banner file
SSHD_CONFIG="/etc/ssh/sshd_config"

# Check if the Banner directive is already set
if grep -q "^Banner" "$SSHD_CONFIG"; then
  # Update the Banner directive
  sed -i "s|^Banner.*|Banner $BANNER_FILE|" "$SSHD_CONFIG"
else
  # Add the Banner directive at the end of the file
  echo "Banner $BANNER_FILE" >> "$SSHD_CONFIG"
fi

# Restart the SSH service to apply changes
systemctl restart sshd

# Output a success message
echo "SSH banner has been set to '$BANNER_MESSAGE'. SSH service restarted."
