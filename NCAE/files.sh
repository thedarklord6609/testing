#!/bin/bash

# Base URL of the GitHub repository's raw files
BASE_URL="https://raw.githubusercontent.com/thedarklord6609/testing/refs/heads/main/NCAE"

# List of shell script files
FILES=(
    "SSHmonitor.sh"
    "backup.sh"
    "check.sh"
    "checkusers.sh"
    "ftp.sh"
    "ftpTOftps.sh"
    "ftpfiles.sh"
    "ftpfilesREVERT.sh"
    "ftpsTOftp.sh"
    "nobrute.sh"
    "restore.sh"
    "silly.sh"
    "sillyssh.sh"
    "ssh.sh"
    "sshdetect.sh"
    "sshmonitor2.sh"
    "sshtest.sh"
    "sshtestrevert.sh"
    "testmonitor.sh"
    "testmonitor2.sh"
    "teto1.sh"
    "teto2.sh"
    "users.sh"
    "add.sh"
    "deluser.sh"
)

# Loop through each file and download it using wget
for FILE in "${FILES[@]}"; do
    URL="$BASE_URL/$FILE"

    echo "Downloading $URL..."
    wget -q -O "$FILE" "$URL"

    if [ $? -eq 0 ]; then
        echo "Saved: $FILE"
    else
        echo "Failed to download: $URL"
    fi
done

echo "Download complete."
