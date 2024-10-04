#!/bin/bash

# Uses admin permissions to create the docker group and add the user to it


chmod +x groupuser.sh
username="$1"

cd /home/"$username"
groupadd docker
chgrp docker /var/run/docker.sock
newgrp docker
usermod -aG docker "$username"
exit
