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

# Export terraform output variables
export PUBLIC_CLIENT_IP_ADDR=$(terraform output public_client_ip_addr)
export PUBLIC_SERVER_IP_ADDR=$(terraform output public_server_ip_addr)

# Wait for VMs to start
for IP in $PUBLIC_SERVER_IP_ADDR $PUBLIC_CLIENT_IP_ADDR
do
    until timeout 30 ssh -i aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$IP exit; do sleep 5 ; done
done