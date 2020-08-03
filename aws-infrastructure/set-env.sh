#!/bin/bash

# Enter script-located dir, whaterver the script is called from
cd "$( dirname "${BASH_SOURCE[0]}" )"

export PRIVATE_CLIENT_IP_ADDR=$(terraform output private_client_ip_addr)
export PRIVATE_SERVER_IP_ADDR=$(terraform output private_server_ip_addr)
export PUBLIC_CLIENT_IP_ADDR=$(terraform output public_client_ip_addr)
export PUBLIC_SERVER_IP_ADDR=$(terraform output public_server_ip_addr)

# Get back to the caller directory
cd -