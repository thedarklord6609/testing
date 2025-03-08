#!/bin/bash

# Define the list of expected scoringusers (update this list as per your requirement)
expected_users=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

# List of users in the scoringusers group
group_users=$(getent group scoringusers | cut -d: -f4)

# Check for any users in scoringusers who are not in the expected list
echo "Users in scoringusers that don't match the expected list:"
for user in $group_users; do
    if [[ ! " ${expected_users[@]} " =~ " $user " ]]; then
        echo "$user"
    fi
done

# List users who are not in the scoringusers group
echo -e "\nUsers not in the scoringusers group:"
for user in $(getent passwd | cut -d: -f1); do
    if ! echo "$group_users" | grep -qw "$user"; then
        echo "$user"
    fi
done

# Check for duplicate usernames
echo -e "\nDuplicate usernames:"
getent passwd | cut -d: -f1 | sort | uniq -d
