#!/bin/bash

# Step 1: Uninstall Python and cron
echo "Uninstalling Python..."
sudo apt-get remove --purge -y python3 python

echo "Uninstalling cron..."
sudo apt-get remove --purge -y cron

# Step 2: List suspicious programs or processes
echo -e "\nListing suspicious programs or processes..."
# Check for programs running by themselves or with high privileges
ps aux --sort=-%cpu | head -n 20

# Check for network activity (communicating to the outside)
echo -e "\nChecking for processes with network activity..."
netstat -tulnp

# List open ports to check for suspicious services
echo -e "\nListing open ports..."
ss -tuln

# Step 3: Check for files that may be harmful or modified without permission
echo -e "\nChecking for unusual files or directories..."
find / -name "*.sh" -exec ls -l {} \; 2>/dev/null

echo -e "\nChecking for files with unusual permissions or owners..."
find / -type f -exec ls -l {} \; | grep -E "^-rwxrwxrwx|^-rwsrwsrwt" 2>/dev/null

# Step 4: Check for cron jobs or tasks that could be restoring permissions automatically
echo -e "\nChecking for suspicious cron jobs..."
crontab -l
sudo cat /etc/crontab
sudo ls /etc/cron.d/

# Check for scripts with setuid, which might be used for privilege escalation
echo -e "\nChecking for setuid files..."
find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null

# Step 5: Output any warnings
echo -e "\nWARNING: Check for the following processes that could be suspicious:"
ps aux | grep -iE "python|cron|wget|curl|nc|perl|bash|python3|sh|nc|java|php|ruby"  # Common scripts or backdoor tools

echo -e "\nScript completed. Please review suspicious programs, open ports, and cron jobs."
