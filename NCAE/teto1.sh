#!/bin/bash
# This script downloads the image from the provided URL and saves it to /mnt/files

# Create the target directory if it doesn't exist
mkdir -p /mnt/files

# Download the image using wget
wget -O /mnt/files/image.png "https://cdn.discordapp.com/attachments/1288291953443606569/1347871642520518717/image.png?ex=67cd66c9&is=67cc1549&hm=96d9e70e32b69589238ca6f0ea93c8336df2921b1c735c26896869346bfbda30&"

echo "Image downloaded to /mnt/files/image.png"
