#!/bin/bash

apt update -y
addgroup docker
chgrp docker /var/run/docker.sock
usermod -aG docker "$whoami"

mkdir minecraft
cd minecraft
wget "https://raw.githubusercontent.com/itzg/docker-minecraft-server/refs/heads/master/docker-compose.yml"

docker compose up -d
