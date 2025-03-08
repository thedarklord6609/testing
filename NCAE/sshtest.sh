#!/bin/bash

# Step 1: Re-generate the RSA and ED25519 keys
echo "Re-generating SSH RSA and ED25519 keys..."

# Backup existing keys if they exist
if [ -f /etc/ssh/ssh_host_rsa_key ]; then
    cp /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.bak
fi
if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
    cp /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key.bak
fi

rm -f /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# Step 2: Enable the ED25519 and RSA HostKey directives in sshd_config
echo -e "\nEnabling ED25519 and RSA keys in /etc/ssh/sshd_config..."

# Backup the sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

echo -e "\nHostKey /etc/ssh/ssh_host_ed25519_key\nHostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config

# Step 3: Remove small Diffie-Hellman moduli
echo "Removing small Diffie-Hellman moduli..."

# Backup moduli file
cp /etc/ssh/moduli /etc/ssh/moduli.bak

awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
mv -f /etc/ssh/moduli.safe /etc/ssh/moduli

# Step 4: Restrict supported key exchange, cipher, and MAC algorithms
echo -e "\nRestricting key exchange, cipher, and MAC algorithms..."

# Backup the current OpenSSH configuration file
cp /etc/crypto-policies/back-ends/opensshserver.config /etc/crypto-policies/back-ends/opensshserver.config.bak

echo -e "# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com\n# hardening guide.\nKexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,gss-curve25519-sha256-,diffie-hellman-group16-sha512,gss-group16-sha512-,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256\n\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr\n\nMACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com\n\nHostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nRequiredRSASize 3072\n\nCASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nGSSAPIKexAlgorithms gss-curve25519-sha256-,gss-group16-sha512-\n\nHostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256\n\nPubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\n" > /etc/crypto-policies/back-ends/opensshserver.config

# Step 5: Restart OpenSSH service
echo "Restarting OpenSSH service..."
systemctl restart sshd

# Step 6: Implement connection rate throttling to protect against DoS attacks
echo "Implementing connection rate throttling..."
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p tcp --dport 22 -m state --state NEW -m recent --set
firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP

# Reload firewall to apply the new rules
echo "Reloading firewalld..."
systemctl reload firewalld

echo "SSH hardening completed successfully."
