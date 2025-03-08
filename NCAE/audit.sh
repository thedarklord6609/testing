#!/bin/bash

# Define the audit rules file
AUDIT_RULES_FILE="/etc/audit/rules.d/audit.rules"

echo "Setting up audit rules for critical system monitoring..."

# Ensure auditd is enabled and running
echo "Enabling and starting auditd..."
sudo systemctl enable --now auditd

# Add audit rules to the rules file
echo "Configuring audit rules..."
sudo bash -c "cat > $AUDIT_RULES_FILE" <<EOL
# Monitor user & group modifications
-w /etc/passwd -p wa -k user_modifications
-w /etc/shadow -p wa -k user_modifications
-w /etc/group -p wa -k group_modifications
-w /etc/gshadow -p wa -k group_modifications

# Monitor sudo command usage
-w /var/log/sudo.log -p wa -k sudo_activity
-a always,exit -F arch=b64 -S execve -C uid!=euid -k privilege_escalation

# Monitor critical system files
-w /etc/ssh/sshd_config -p wa -k ssh_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/systemd/system/ -p wa -k systemd_changes
-w /etc/cron* -p wa -k cron_jobs

# Monitor login attempts
-w /var/log/secure -p wa -k auth_attempts
EOL

# Restart auditd to apply changes
echo "Restarting auditd..."
sudo systemctl restart auditd

# Verify the rules are applied
echo "Verifying applied rules..."
sudo auditctl -l

# Display search instructions
echo -e "\n=== Audit Rules & Search Commands ==="
echo "1. New User & Group Modifications: sudo ausearch -k user_modifications"
echo "2. Sudo Command Usage: sudo ausearch -k sudo_activity"
echo "3. Privilege Escalation Attempts: sudo ausearch -k privilege_escalation"
echo "4. SSH Configuration Changes: sudo ausearch -k ssh_changes"
echo "5. Sudoers File Modifications: sudo ausearch -k sudoers_changes"
echo "6. Systemd Service Modifications: sudo ausearch -k systemd_changes"
echo "7. Cron Job Modifications: sudo ausearch -k cron_jobs"
echo "8. Authentication Attempts: sudo ausearch -k auth_attempts"

echo -e "\nAudit setup completed successfully! 🚀"
