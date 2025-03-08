#!/bin/bash

# List of allowed users
expected_users=(
    "camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt"
    "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford"
    "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery"
    "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas"
    "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb"
    "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner"
    "kitty_oneil" "jessi_combs" "andy_green" "root"
)

# Get a list of all system users (UID >= 1000)
all_users=$(awk -F: '($3 >= 1000) {print $1}' /etc/passwd)

# Loop through users and remove unwanted ones
for user in $all_users; do
    if [[ ! " ${expected_users[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo userdel -r "$user" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "User $user deleted."
        else
            echo "Failed to delete user $user."
        fi
    fi
done

echo "User cleanup complete!"
