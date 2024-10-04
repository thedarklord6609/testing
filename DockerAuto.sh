#!/bin/bash

sudo apt update -y
sudo addgroup docker
sudo chgrp docker /var/run/docker.sock
sudo usermod -aG docker "$whoami"

mkdir minecraft
cd minecraft
wget "https://raw.githubusercontent.com/itzg/docker-minecraft-server/refs/heads/master/docker-compose.yml"

docker compose up -d
