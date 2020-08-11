#!/bin/bash
set -x

# Enter script-located dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Add ssh key.
eval $(ssh-agent)
ssh-add ../aws-infrastructure/aws_ssh_key

# Start AWS infrastructure
../aws-infrastructure/start.sh

# Setup env variables with VMm's ip
source ../aws-infrastructure/set-env.sh

# Copy executable script
scp ./upload.py ubuntu@$PUBLIC_CLIENT_IP_ADDR:/home/ubuntu/upload.py
scp ./upload.py ubuntu@$PUBLIC_SERVER_IP_ADDR:/home/ubuntu/upload.py

# Pull images and tag them on client VM
ssh ubuntu@$PUBLIC_CLIENT_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py pull"

# Benchmark artipie
ssh ubuntu@$PUBLIC_SERVER_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py start_artipie"
ssh ubuntu@$PUBLIC_CLIENT_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py benchmark_artipie"
ssh ubuntu@$PUBLIC_SERVER_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py stop_artipie"

# Benchmark registry
ssh ubuntu@$PUBLIC_SERVER_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py start_registry"
ssh ubuntu@$PUBLIC_CLIENT_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py benchmark_registry"
ssh ubuntu@$PUBLIC_SERVER_IP_ADDR "source instance-env.sh; /home/ubuntu/upload.py stop_registry"

# Download results
scp ubuntu@$PUBLIC_SERVER_IP_ADDR:/home/ubuntu/*.json ./

# Stop AWS infrastructure
../aws-infrastructure/stop.sh