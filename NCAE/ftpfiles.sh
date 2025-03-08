#!/bin/bash

# List of files to protect in /mnt/files
files=(
    "iron_cross.data"
    "3_point_molly.data"
    "dark_side.data"
    "come_dont_come.data"
    "odds.data"
    ".house_secrets.data"
    "pass_line.data"
    "risky_roller.data"
    "covered_call.data"
    "married_put.data"
    "bull_call.data"
    "protective_collar.data"
    "long_straddle.data"
    "long_strangle.data"
    "long_call_butterfly.data"
    "iron_condor.data"
    "iron_butterfly.data"
    "short_put.data"
    "data_dump_1.bin"
    "data_dump_2.bin"
    "data_dump_3.bin"
    "datadump.bin"
)

# Directory where the files are located
directory="/mnt/files"

# Ensure sudo users can modify, and everyone can read
echo "Making files read-only for everyone and writeable only by sudo users..."

for file in "${files[@]}"; do
    full_path="$directory/$file"

    # Check if the file exists
    if [ -f "$full_path" ]; then
        # Change file permissions:
        # - Readable by everyone (444)
        # - Writable by root or sudo users (600 for root only)
        sudo chmod 644 "$full_path"   # Set read-only permissions for everyone

        # Set ownership to root (make root the owner)
        sudo chown root:root "$full_path"

        # Set the immutable flag to prevent accidental deletion/modification
        sudo chattr +i "$full_path"

        # Ensure only root can modify the files
        echo "File $full_path is now read-only for everyone and immutable."
    else
        echo "File $full_path does not exist."
    fi
done

echo "File protection complete. Only sudo/root can modify the files."
