#!/bin/bash
set -x

# Enter script-located dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Start AWS infrastructure
../aws-infrastructure/start.sh

# Setup env variables with VMm's ip
source ../aws-infrastructure/set-env.sh

# Pull images and tag them on client VM
scp -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ./upload.py ubuntu@$PUBLIC_CLIENT_IP_ADDR:/home/ubuntu/upload.py
ssh -i ../aws-infrastructure/aws_ssh_key -oStrictHostKeyChecking=no ubuntu@$PUBLIC_CLIENT_IP_ADDR <<'ENDSSH'
set -x
/home/ubuntu/upload.py
ENDSSH

# Stop AWS infrastructure
../aws-infrastructure/stop.sh