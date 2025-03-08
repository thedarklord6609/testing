# List non-system users (UID >= 1000)
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Add a few blank lines
echo -e "\n\n"

# List users not in the scoringusers group
comm -23 <(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | sort) <(getent group scoringusers | cut -d: -f4 | tr ',' '\n' | sort)
