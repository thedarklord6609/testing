#!/bin/bash

# Step 1: Restore RSA and ED25519 keys if they were backed up
echo "Restoring RSA and ED25519 SSH keys..."

if [ -f /etc/ssh/ssh_host_rsa_key.bak ]; then
    mv -f /etc/ssh/ssh_host_rsa_key.bak /etc/ssh/ssh_host_rsa_key
fi
if [ -f /etc/ssh/ssh_host_ed25519_key.bak ]; then
    mv -f /etc/ssh/ssh_host_ed25519_key.bak /etc/ssh/ssh_host_ed25519_key
fi

# Step 2: Restore sshd_config file
echo "Restoring /etc/ssh/sshd_config..."
if [ -f /etc/ssh/sshd_config.bak ]; then
    mv -f /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
fi

# Step 3: Restore moduli file
echo "Restoring /etc/ssh/moduli..."
if [ -f /etc/ssh/moduli.bak ]; then
    mv -f /etc/ssh/moduli.bak /etc/ssh/moduli
fi

# Step 4: Restore OpenSSH configuration
echo "Restoring OpenSSH configuration..."
if [ -f /etc/crypto-policies/back-ends/opensshserver.config.bak ]; then
    mv -f /etc/crypto-policies/back-ends/opensshserver.config.bak /etc/crypto-policies/back-ends/opensshserver.config
fi

# Step 5: Restart OpenSSH service
echo "Restarting OpenSSH service..."
systemctl restart sshd

# Step 6: Remove connection rate throttling
echo "Removing connection rate throttling..."
firewall-cmd --permanent --direct --remove-rule ipv4 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --remove-rule ipv4 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP
firewall-cmd --permanent --direct --remove-rule ipv6 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --remove-rule ipv6 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP

# Reload firewall to apply the old rules
echo "Reloading firewalld..."
systemctl reload firewalld

echo "SSH configuration has been reverted."
