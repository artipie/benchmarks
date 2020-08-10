#!/bin/bash
set -x

# Enter script-located dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Start AWS infrastructure
../aws-infrastructure/start.sh

# Setup env variables with VMm's ip
source ../aws-infrastructure/set-env.sh

# Copy executable script
scp -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ./upload.py ubuntu@$PUBLIC_CLIENT_IP_ADDR:/home/ubuntu/upload.py
scp -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ./upload.py ubuntu@$PUBLIC_SERVER_IP_ADDR:/home/ubuntu/upload.py

# Pull images and tag them on client VM
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_CLIENT_IP_ADDR bash -c "/home/ubuntu/upload.py pull"

# Benchmark artipie
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_SERVER_IP_ADDR bash -c "/home/ubuntu/upload.py start_artipie"
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_CLIENT_IP_ADDR bash -c "/home/ubuntu/upload.py benchmark_artipie"
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_SERVER_IP_ADDR bash -c "/home/ubuntu/upload.py stop_artipie"

# Benchmark registry
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_SERVER_IP_ADDR bash -c "/home/ubuntu/upload.py start_registry"
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_CLIENT_IP_ADDR bash -c "/home/ubuntu/upload.py benchmark_registry"
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_SERVER_IP_ADDR bash -c "/home/ubuntu/upload.py stop_registry"

# Download results
scp -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_SERVER_IP_ADDR:/home/ubuntu/*.json ./

# Stop AWS infrastructure
../aws-infrastructure/stop.sh