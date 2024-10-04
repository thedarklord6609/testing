#!/bin/bash

username="$1"

sudo apt update -y
sudo -i
sudo addgroup docker
sudo chgrp docker /var/run/docker.sock
sudo usermod -aG docker "$username"

mkdir minecraft
cd minecraft
wget "https://raw.githubusercontent.com/itzg/docker-minecraft-server/refs/heads/master/docker-compose.yml"

docker compose up -d
