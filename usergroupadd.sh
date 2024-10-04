#!/bin/bash

# Uses admin permissions to create the docker group and add the user to it

username="$1"

sudo addgroup docker
chgrp docker /var/run/docker.sock
newgrp docker
usermod -aG docker "$username"
