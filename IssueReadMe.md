 For Docker without SUDO
 # 1. Create the docker group (if it doesn't exist)
sudo groupadd docker
# 2. Add your current user to the docker group
sudo usermod -aG docker $USER
# 3. Apply the group changes to your current terminal session
newgrp docker