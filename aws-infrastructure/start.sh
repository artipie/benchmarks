#!/bin/bash
set -x
set -e

# Enter aws-infrastructure dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Generate RSA key for ssh access if not exists
if [ ! -f "aws_ssh_key" ]
then
    ssh-keygen -t rsa -b 4096 -f aws_ssh_key -N ""
fi

eval $(ssh-agent)
ssh-add ../aws-infrastructure/aws_ssh_key

# Start AWS infrotructure
terraform init
terraform apply -input=false -auto-approve

# Setup env variables with VMm's ip
source set-env.sh

# Prepare env file for aws instances
rm -f instance-env.sh
cat <<EOT >> instance-env.sh
export PRIVATE_CLIENT_IP_ADDR=$PRIVATE_CLIENT_IP_ADDR
export PRIVATE_SERVER_IP_ADDR=$PRIVATE_SERVER_IP_ADDR
export PUBLIC_CLIENT_IP_ADDR=$PUBLIC_CLIENT_IP_ADDR
export PUBLIC_SERVER_IP_ADDR=$PUBLIC_SERVER_IP_ADDR
export ARTIPIE_VERSION=$ARTIPIE_VERSION
EOT
chmod +x instance-env.sh

# Wait for VMs to start
for IP in $PUBLIC_SERVER_IP_ADDR $PUBLIC_CLIENT_IP_ADDR
do
    until timeout 30 ssh -oStrictHostKeyChecking=no ubuntu@$IP exit; do sleep 5 ; done
done

# Install required software on each VM
for IP in $PUBLIC_SERVER_IP_ADDR $PUBLIC_CLIENT_IP_ADDR
do
scp ./instance-env.sh ubuntu@$IP:/home/ubuntu
ssh ubuntu@$IP <<'ENDSSH'
set -x
echo "source /home/ubuntu/instance-env.sh" >> /home/ubuntu/.bashrc
source /home/ubuntu/instance-env.sh
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
echo "{\"insecure-registries\" : [\"$PUBLIC_SERVER_IP_ADDR:5000\",\"$PUBLIC_SERVER_IP_ADDR:8080\"]}" > daemon.json
sudo mv daemon.json /etc/docker/daemon.json
sudo service docker restart
docker run hello-world
ENDSSH
done