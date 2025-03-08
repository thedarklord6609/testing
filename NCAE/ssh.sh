#!/bin/bash

# 1. Disable root login via SSH
echo "Disabling root login via SSH..."
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config

# 2. Disable passwordless login via SSH (disabling empty passwords)
echo "Disabling passwordless SSH login..."
sed -i '/^PermitEmptyPasswords/s/yes/no/' /etc/ssh/sshd_config

# 3. Restart SSH service to apply changes
echo "Restarting SSH service..."
systemctl restart sshd

echo "SSH configuration has been updated."
