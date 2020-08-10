#!/bin/bash
set -x

# Enter aws-infrastructure dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Generate RSA key for ssh access if not exists
if [ ! -f "aws_ssh_key" ]
then
    ssh-keygen -t rsa -b 4096 -f aws_ssh_key -N ""
fi

# Start AWS infrotructure
terraform init
terraform apply -input=false -auto-approve

# Setup env variables with VMm's ip
source set-env.sh

# Prepare env file for aws instances
cat <<EOT >> instance-env.sh
export PRIVATE_CLIENT_IP_ADDR=$PRIVATE_CLIENT_IP_ADDR
export PRIVATE_SERVER_IP_ADDR=$PRIVATE_SERVER_IP_ADDR
export PUBLIC_CLIENT_IP_ADDR=$PUBLIC_CLIENT_IP_ADDR
export PUBLIC_SERVER_IP_ADDR=$PUBLIC_SERVER_IP_ADDR
EOT
chmod +x instance-env.sh

# Wait for VMs to start
for IP in $PUBLIC_SERVER_IP_ADDR $PUBLIC_CLIENT_IP_ADDR
do
    until timeout 30 ssh -i aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$IP exit; do sleep 5 ; done
done

# Install required software on each VM
for IP in $PUBLIC_SERVER_IP_ADDR $PUBLIC_CLIENT_IP_ADDR
do
scp -i aws_ssh_key -oStrictHostKeyChecking=no ./instance-env.sh ubuntu@$PUBLIC_CLIENT_IP_ADDR:/home/ubuntu
ssh -i aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$IP <<'ENDSSH'
set -x
set -e
echo "source /home/ubuntu/instance-env.sh" >> /home/ubuntu/.bashrc
sudo apt-get update
sudo apt-get install -y \
    python3 \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
# Running docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
ENDSSH
done