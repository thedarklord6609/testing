#!/bin/bash

# List of files to revert in /mnt/files
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

# Reverting the file protection settings
echo "Reverting file protection settings..."

for file in "${files[@]}"; do
    full_path="$directory/$file"

    # Check if the file exists
    if [ -f "$full_path" ]; then
        # Remove the immutable flag to allow modifications
        sudo chattr -i "$full_path"

        # Restore the file permissions to 644 (readable by all, writable by owner)
        sudo chmod 644 "$full_path"  # Restores read-only to others, writable to owner (root)

        # Restore ownership if necessary
        sudo chown root:root "$full_path"  # You can change this back if a different owner is needed

        echo "File $full_path is reverted. Modifications allowed now."
    else
        echo "File $full_path does not exist."
    fi
done

echo "Reversion complete. Files are now modifiable by root or sudo users."
