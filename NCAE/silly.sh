#!/bin/bash

# Set the base directory
BASE_DIR="/important"

# Create /important directory and set permission
sudo mkdir -p $BASE_DIR
sudo chmod 700 $BASE_DIR
sudo chown root:root $BASE_DIR

# Function to generate random content and encrypt it
generate_random_encrypted_files() {
    folder_name=$1
    num_files=$((RANDOM % 8 + 2))  # Random number of files between 2 and 9
    for ((i = 1; i <= $num_files; i++)); do
        # Create a random text content
        random_content=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 200)
        
        # Create the .txt or .sh file
        filename=$(mktemp "$folder_name/randomfile_XXXXXX.txt")
        echo "$random_content" > "$filename"
        
        # Encrypt the file with a strong password
        openssl enc -aes-256-cbc -salt -in "$filename" -out "$filename.enc" -pass pass:"$(openssl rand -base64 32)"
        
        # Remove the original unencrypted file
        rm "$filename"
        
        # Move the encrypted file to the folder
        mv "$filename.enc" "$folder_name/"
    done
}

# List of folder names, including "plans" and "passwords"
folder_names=("plans" "passwords")
for i in $(seq 1 8); do
    # Generate random folder names
    folder_names+=($(openssl rand -base64 12 | tr -dc A-Za-z0-9))
done

# Create directories and add encrypted files
for folder_name in "${folder_names[@]}"; do
    folder_path="$BASE_DIR/$folder_name"
    sudo mkdir -p "$folder_path"
    
    # Generate random encrypted files in each folder
    generate_random_encrypted_files "$folder_path"
    
    # Set the permissions so only root can access the folders
    sudo chmod 700 "$folder_path"
    sudo chown -R root:root "$folder_path"
done
